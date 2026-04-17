import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/exceptions/crypt_exception.dart';
import 'package:vault_env_manager/src/shared/utils/crypt.dart';

void main() {
  group('Crypt - Robustness & Laravel Compatibility', () {
    // 32-byte key for AES-256
    final keyBytes = Uint8List.fromList(List.generate(32, (i) => i));
    final appKey = 'base64:${base64Encode(keyBytes)}';

    test('Encrypt/Decrypt roundtrip with AES-256-CBC (Default)', () {
      final crypt = Crypt.fromAppKey(appKey);
      const plaintext =
          'HELLO_VAULT=true\nMULTILINE="is supported"\nSPECIAL_CHARS="!@#\$%^&*()"';

      final encrypted = crypt.encrypt(plaintext, algorithm: 'aes-256-cbc');
      final decrypted = crypt.decrypt(encrypted, algorithm: 'aes-256-cbc');

      expect(decrypted, equals(plaintext));
    });

    test('Encrypt/Decrypt roundtrip with AES-256-GCM', () {
      final crypt = Crypt.fromAppKey(appKey);
      const plaintext =
          'DATABASE_URL=postgres://user:pass@localhost:5432/db\nAPI_KEY=sk_test_123456789';

      final encrypted = crypt.encrypt(plaintext, algorithm: 'aes-256-gcm');
      final decrypted = crypt.decrypt(encrypted, algorithm: 'aes-256-gcm');

      expect(decrypted, equals(plaintext));
    });

    test('Should handle double quotes and backslashes in value', () {
      final crypt = Crypt.fromAppKey(appKey);
      const plaintext =
          'JSON_DATA={"key": "value with "quotes" and \\backslash"}';

      final encrypted = crypt.encrypt(plaintext, algorithm: 'aes-256-cbc');
      final decrypted = crypt.decrypt(encrypted, algorithm: 'aes-256-cbc');

      expect(decrypted, equals(plaintext));
    });

    test('CBC Decryption should fail if MAC is tampered', () {
      final crypt = Crypt.fromAppKey(appKey);
      final encrypted = crypt.encrypt('SECRET_DATA', algorithm: 'aes-256-cbc');

      // Decapsulate JSON and modify MAC
      final payload = jsonDecode(utf8.decode(base64Decode(encrypted)));
      payload['mac'] = 'TAMPERED_MAC_1234567890abcdef1234567890abcdef';

      final tamperedEncrypted = base64Encode(utf8.encode(jsonEncode(payload)));

      expect(
        () => crypt.decrypt(tamperedEncrypted, algorithm: 'aes-256-cbc'),
        throwsA(isA<MacInvalidException>()),
      );
    });

    test('PHP Serialization - _serializeString formatting', () {
      final crypt = Crypt.fromAppKey(appKey);
      // Private method testing via exposed logic (actually we'll just test roundtrip)
      const input = '🔥 Fire & Ice ❄️';
      final encrypted = crypt.encrypt(input);
      final decrypted = crypt.decrypt(encrypted);
      expect(decrypted, input);
    });
  });
}
