import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/core/app/data/services/encryption_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionService();
  });

  group('EncryptionService Logic Parity & Security Tests', () {
    const testKey = 'master-secure-key-123';
    const testPlaintext = 'SECRET_PAYLOAD_DATA';

    test('should encrypt and decrypt successfully with Right(value)', () async {
      final encryptResult = await encryptionService.encryptAsync(
        testPlaintext,
        testKey,
      );
      expect(encryptResult.isRight(), true);

      final ciphertext = encryptResult.getOrElse(
        () => fail('Should have value'),
      );
      expect(ciphertext.isNotEmpty, true);
      // Valid Base64 check
      expect(() => base64Decode(ciphertext), returnsNormally);

      final decryptResult = await encryptionService.decryptAsync(
        ciphertext,
        testKey,
      );
      expect(decryptResult.isRight(), true);
      expect(decryptResult.getOrElse(() => ''), testPlaintext);
    });

    test('should return SecurityFailure when key is empty', () async {
      final result = await encryptionService.encryptAsync(testPlaintext, "");
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<SecurityFailure>()),
        (_) => fail('Should fail'),
      );
    });

    test('Logic Parity: should handle base64url keys (Svelte sync)', () async {
      // '_-79' is base64url for [255, 238, 253]. Standard is '/+79'
      const base64UrlKey = '_-79';
      final encryptResult = await encryptionService.encryptAsync(
        testPlaintext,
        base64UrlKey,
      );
      expect(encryptResult.isRight(), true);

      final ciphertext = encryptResult.getOrElse(() => '');
      final decryptResult = await encryptionService.decryptAsync(
        ciphertext,
        base64UrlKey,
      );
      expect(decryptResult.getOrElse(() => ''), testPlaintext);
    });

    test('Logic Parity: should handle unpadded base64 keys', () async {
      // 'YWJj' is 'abc' in base64.
      // If we provided 'YWJj' (3 chars, needs padding to 4), Normalization Protocol handles it.
      const unpaddedKey = 'YWJj';
      final result = await encryptionService.encryptAsync(
        testPlaintext,
        unpaddedKey,
      );
      expect(result.isRight(), true);
    });

    test(
      'should return SecurityFailure for invalid ciphertext format',
      () async {
        final result = await encryptionService.decryptAsync(
          "invalid_data",
          testKey,
        );
        expect(result.isLeft(), true);
      },
    );

    test('should fail decryption if key is incorrect', () async {
      final encryptResult = await encryptionService.encryptAsync(
        testPlaintext,
        testKey,
      );
      final ciphertext = encryptResult.getOrElse(() => "");

      final decryptResult = await encryptionService.decryptAsync(
        ciphertext,
        "WRONG_KEY",
      );
      expect(decryptResult.isLeft(), true);
    });
  });
}
