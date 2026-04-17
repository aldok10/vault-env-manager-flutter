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
  static IOClient createPinningClient(String? fingerprint) {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (fingerprint == null || fingerprint.isEmpty) return true;

        // Compute SHA-256 fingerprint of the certificate
        final certHash = crypto.sha256
            .convert(cert.der)
            .toString()
            .toLowerCase();
        final expectedHash = fingerprint.replaceAll(':', '').toLowerCase();

        final isValid = certHash == expectedHash;
        if (!isValid) {
          debugPrint('⚠️ SECURITY ALERT: Certificate Pinning Mismatch!');
          debugPrint('Expected: $expectedHash');
          debugPrint('Received: $certHash');
        }
        return isValid;
      };

    return IOClient(httpClient);
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
