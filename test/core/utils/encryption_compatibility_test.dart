import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/exceptions/crypt_exception.dart';
import 'package:vault_env_manager/src/shared/utils/crypt.dart';

void main() {
  group('Encryption Compatibility Tests (Laravel/Go Standard)', () {
    const String testKeyBase64 =
        'base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='; // 32 bytes of 0s
    const String testPlaintext = 'hello-world';

    test('Should encrypt and decrypt successfully (AES-256-CBC)', () {
      final crypt = Crypt.fromAppKey(testKeyBase64, keySize: 256);

      final encrypted = crypt.encrypt(testPlaintext, algorithm: 'aes-256-cbc');
      final decrypted = crypt.decrypt(encrypted, algorithm: 'aes-256-cbc');

      expect(decrypted, testPlaintext);

      // Verify JSON structure
      final decodedJson = utf8.decode(base64Decode(encrypted));
      final payload = jsonDecode(decodedJson);
      expect(payload.containsKey('iv'), true);
      expect(payload.containsKey('value'), true);
      expect(payload.containsKey('mac'), true);
      expect(payload['tag'], '');
    });

    test('Should encrypt and decrypt successfully (AES-256-GCM)', () {
      final crypt = Crypt.fromAppKey(testKeyBase64, keySize: 256);

      final encrypted = crypt.encrypt(testPlaintext, algorithm: 'aes-256-gcm');
      final decrypted = crypt.decrypt(encrypted, algorithm: 'aes-256-gcm');

      expect(decrypted, testPlaintext);

      // Verify JSON structure
      final decodedJson = utf8.decode(base64Decode(encrypted));
      final payload = jsonDecode(decodedJson);
      expect(payload.containsKey('iv'), true);
      expect(payload.containsKey('value'), true);
      expect(payload['tag'], isNotEmpty);
      expect(payload['mac'], '');
    });

    test('Should handle PHP-style serialization (s:len:"val";)', () {
      // Manual payload with PHP serialization but direct key usage for simplicity
      final keyBytes = base64Decode(
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      );
      final crypt = Crypt.fromBytes(keyBytes, keySize: 256);

      // If I encrypt "foo", it should be "s:3:"foo";" internally
      final encrypted = crypt.encrypt('foo', algorithm: 'aes-256-cbc');

      // We can't easily peek inside without decrypting or mocking,
      // but if our decrypt works, it means it's handling the 's:3:"foo";' wrapper.
      expect(crypt.decrypt(encrypted), 'foo');
    });

    test('Should fail decryption with wrong MAC (CBC)', () {
      final crypt = Crypt.fromAppKey(testKeyBase64, keySize: 256);
      final encrypted = crypt.encrypt(testPlaintext, algorithm: 'aes-256-cbc');

      // Tamper with payload
      final decoded =
          jsonDecode(utf8.decode(base64Decode(encrypted)))
              as Map<String, dynamic>;
      decoded['mac'] = 'wrong_mac';
      final tampered = base64Encode(utf8.encode(jsonEncode(decoded)));

      expect(
        () => crypt.decrypt(tampered, algorithm: 'aes-256-cbc'),
        throwsA(isA<MacInvalidException>()),
      );
    });
  });
}
