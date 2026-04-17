import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/error/exceptions.dart';

/// Centralized service for Security concerns:
/// 1. Key Management
/// 2. Certificate Pinning (Future)
/// 3. Secure Random Generation
class SecurityService extends GetxService {
  static SecurityService get to => Get.find();

  late final SecretKey _payloadKey;
  SecretKey get payloadKey => _payloadKey;

  final AesGcm _algorithm = AesGcm.with256bits();

  Future<SecurityService> init() async {
    debugPrint('SecurityService: Initializing...');

    // In a real app, this key would be derived from a master password
    // or fetched from a secure enclave (Keychain/Keystore).
    // For this implementation, we'll use a deterministic key for the session.
    _payloadKey = SecretKey(List<int>.generate(32, (i) => i + 42));

    debugPrint('SecurityService: Key established.');
    return this;
  }

  /// Encrypts a string and returns a JSON string with 'n', 'c', 'm', 's'.
  Future<String> encrypt(String plainText) async {
    final secretBox = await _algorithm.encryptString(
      plainText,
      secretKey: _payloadKey,
    );

    final payload = {
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    };

    // Phase 2: HMAC-SHA256 Signature
    final hmac = Hmac.sha256();
    final canonicalString = '${payload['n']}|${payload['c']}|${payload['m']}';
    final signature = await hmac.calculateMac(
      utf8.encode(canonicalString),
      secretKey: _payloadKey,
    );
    payload['s'] = base64Encode(signature.bytes);

    return jsonEncode(payload);
  }

  /// Decrypts a JSON string containing 'n', 'c', 'm', 's'.
  Future<String> decrypt(String jsonPayload) async {
    try {
      final data = jsonDecode(jsonPayload);

      // Phase 2: Verify HMAC Signature
      if (data['s'] != null) {
        final hmac = Hmac.sha256();
        final canonicalString = '${data['n']}|${data['c']}|${data['m']}';
        final currentHash = await hmac.calculateMac(
          utf8.encode(canonicalString),
          secretKey: _payloadKey,
        );

        if (base64Encode(currentHash.bytes) != data['s']) {
          throw SecurityException(
            'HMAC Signature mismatch. Payload integrity compromised.',
          );
        }
      }

      final secretBox = SecretBox(
        base64Decode(data['c']),
        nonce: base64Decode(data['n']),
        mac: Mac(base64Decode(data['m'])),
      );

      return await _algorithm.decryptString(secretBox, secretKey: _payloadKey);
    } catch (e) {
      debugPrint('SecurityService: Decryption failed: $e');
      rethrow;
    }
  }
}
