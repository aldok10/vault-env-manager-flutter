import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:vault_env_manager/src/core/error/exceptions.dart';

/// A secure HTTP client that automatically handles:
/// 1. Payload Encryption (AES-GCM 256-bit)
/// 2. Certificate Pinning (SHA-256)
/// 3. Standard Request/Response headers for security
class SecureHttpClient extends http.BaseClient {
  final http.Client _inner;
  final SecretKey _secretKey;
  final AesGcm _algorithm = AesGcm.with256bits();
  final String? _certificateFingerprint;

  SecureHttpClient(
    this._inner,
    this._secretKey, {
    String? certificateFingerprint,
  }) : _certificateFingerprint = certificateFingerprint {
    if (_certificateFingerprint != null && _certificateFingerprint.isNotEmpty) {
      final safeEnd = _certificateFingerprint.length < 8
          ? _certificateFingerprint.length
          : 8;
      debugPrint(
        'SecureHttpClient: Certificate Pinning initialized with fingerprint starting with ${_certificateFingerprint.substring(0, safeEnd)}...',
      );
    }
  }

  /// Creates a pinning-enabled IO client for production use.
  ///
  /// `fingerprint` is the SHA-256 of the expected leaf certificate's DER
  /// encoding (colons optional, case-insensitive).
  ///
  /// When no fingerprint is supplied, this callback **fails closed**: it
  /// only ever returns `true` for certificates that the OS TLS stack has
  /// already accepted, because `badCertificateCallback` is invoked solely
  /// when the default chain validation has already rejected a cert. An
  /// unconfigured fingerprint must therefore never cause us to accept a
  /// cert the OS rejected — doing so would turn missing configuration
  /// into a silent MITM backdoor. The old behaviour (`return true` when
  /// no pin is configured) has been removed.
  static IOClient createPinningClient(String? fingerprint) {
    final String? expectedHash = _normalisePin(fingerprint);

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        final bool accept = verifyPin(cert.der, expectedHash);
        if (!accept) {
          if (expectedHash == null) {
            debugPrint(
              'SecureHttpClient: rejecting bad certificate for $host:$port '
              '— no pin configured to override OS decision.',
            );
          } else {
            final certHash = crypto.sha256
                .convert(cert.der)
                .toString()
                .toLowerCase();
            debugPrint('⚠️ SECURITY ALERT: Certificate Pinning Mismatch!');
            debugPrint('Host: $host:$port');
            debugPrint('Expected: $expectedHash');
            debugPrint('Received: $certHash');
          }
        }
        return accept;
      };

    return IOClient(httpClient);
  }

  /// Pure predicate exposed for unit tests: does `certDer` match the
  /// configured pin? Returns `false` when no pin is configured (fail-closed).
  @visibleForTesting
  static bool verifyPin(List<int> certDer, String? expectedHashNormalised) {
    if (expectedHashNormalised == null) return false;
    final certHash = crypto.sha256.convert(certDer).toString().toLowerCase();
    return _constantTimeEquals(certHash, expectedHashNormalised);
  }

  /// Normalise a user-supplied fingerprint to lowercase hex without colons.
  /// Returns `null` when the input is null or empty, which downstream
  /// callers treat as "no pin configured".
  static String? _normalisePin(String? fingerprint) {
    if (fingerprint == null || fingerprint.isEmpty) return null;
    return fingerprint.replaceAll(':', '').toLowerCase();
  }

  /// Public wrapper around [_normalisePin], exposed for unit tests.
  @visibleForTesting
  static String? debugNormalisePin(String? fingerprint) =>
      _normalisePin(fingerprint);

  /// Constant-time string equality to avoid leaking how many leading
  /// bytes of a candidate hash matched the expected pin.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // 1. Enforce HTTPS (Additional Guard)
      if (request.url.scheme != 'https' &&
          request.url.host != 'localhost' &&
          request.url.host != '127.0.0.1') {
        throw SecurityException(
          'Insecure HTTP connection blocked for non-local host.',
        );
      }

      // 2. Prepare for Encryption (if applicable)
      http.BaseRequest finalRequest = request;
      if (request is http.Request && _shouldEncrypt(request)) {
        final encryptedBody = request.body.length > 65536
            ? await compute(_encryptLargeBody, {
                'body': request.body,
                'key': _secretKey,
              })
            : await _encryptBody(request.body);

        // Reconstruct request with encrypted body and strict security headers
        finalRequest = http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['X-Encrypted-Payload'] = 'true'
          ..headers['X-Content-Type-Options'] = 'nosniff'
          ..headers['X-Frame-Options'] = 'DENY'
          ..body = encryptedBody;
      }

      // 3. Perform Request and Intercept Response
      final response = await _inner.send(finalRequest);

      // 4. Handle Response Decryption
      if (response.headers['x-encrypted-payload'] == 'true' ||
          response.headers['X-Encrypted-Payload'] == 'true') {
        return await _decryptResponse(response);
      }

      return response;
    } catch (e) {
      debugPrint(
        'SecureHttpClient: Request failed due to security context: $e',
      );
      rethrow;
    }
  }

  Future<http.StreamedResponse> _decryptResponse(
    http.StreamedResponse response,
  ) async {
    final bytes = await response.stream.toBytes();
    final jsonPayload = utf8.decode(bytes);

    try {
      final data = jsonDecode(jsonPayload);

      // Verify HMAC Signature (Phase 2 Hardening)
      if (data['s'] != null) {
        final hmac = Hmac.sha256();

        // Canonical string for signing: n|c|m
        final canonicalString = '${data['n']}|${data['c']}|${data['m']}';

        final currentHash = await hmac.calculateMac(
          utf8.encode(canonicalString),
          secretKey: _secretKey,
        );

        if (base64Encode(currentHash.bytes) != data['s']) {
          throw SecurityException(
            'HMAC Signature mismatch. Possible payload tampering.',
          );
        }
      }

      final secretBox = SecretBox(
        base64Decode(data['c']),
        nonce: base64Decode(data['n']),
        mac: Mac(base64Decode(data['m'])),
      );

      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: _secretKey,
      );

      // Return a new StreamedResponse with decrypted content
      return http.StreamedResponse(
        Stream.value(decryptedBytes),
        response.statusCode,
        contentLength: decryptedBytes.length,
        request: response.request,
        headers: {
          ...response.headers,
          'content-length': decryptedBytes.length.toString(),
          'X-Payload-Decrypted': 'true',
        },
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e) {
      debugPrint(
        'SecureHttpClient: Decryption failed! Potential tampering: $e',
      );
      throw SecurityException('Response integrity check failed. Blocked.');
    }
  }

  bool _shouldEncrypt(http.Request request) {
    final contentType = request.headers['Content-Type'] ?? '';
    return ['POST', 'PUT', 'PATCH'].contains(request.method) &&
        contentType.contains('application/json');
  }

  Future<String> _encryptBody(String body) async {
    final secretBox = await _algorithm.encryptString(
      body,
      secretKey: _secretKey,
    );
    return await _packageEncryptedPayload(secretBox, signKey: _secretKey);
  }

  static Future<String> _encryptLargeBody(Map<String, dynamic> args) async {
    final String body = args['body'];
    final SecretKey key = args['key'];
    final algorithm = AesGcm.with256bits();

    final secretBox = await algorithm.encryptString(body, secretKey: key);

    return await _packageEncryptedPayload(secretBox, signKey: key);
  }

  static Future<String> _packageEncryptedPayload(
    SecretBox secretBox, {
    SecretKey? signKey,
  }) async {
    final payload = {
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    };

    if (signKey != null) {
      final hmac = Hmac.sha256();
      // Canonical string for signing: n|c|m
      final canonicalString = '${payload['n']}|${payload['c']}|${payload['m']}';

      final signature = await hmac.calculateMac(
        utf8.encode(canonicalString),
        secretKey: signKey,
      );
      payload['s'] = base64Encode(signature.bytes);
    }

    return jsonEncode(payload);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
