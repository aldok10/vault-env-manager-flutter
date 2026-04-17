import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../../test_mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late AppConfigService mockConfig;

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    mockConfig = await setupTestConfig();
    repository = AuthRepositoryImpl(mockConfig);
  });

  group('AuthRepositoryImpl', () {
    test(
      'should return Right(true) when the correct password is provided',
      () async {
        await repository.setupMasterPassword('12345678');
        final result = await repository.unlock('12345678');
        expect(result.isRight(), true);
      },
    );

    test(
      'should return Left(AuthFailure) when an incorrect password is provided',
      () async {
        await repository.setupMasterPassword('12345678');
        final result = await repository.unlock('wrong-password');
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Should have failed'),
        );
      },
    );

    test('setupMasterPassword produces a v2-prefixed record', () async {
      await repository.setupMasterPassword('hunter2');
      final stored = mockConfig.cipherPass.value;
      final parts = stored.split(r'$');
      expect(parts[0], 'v2');
      expect(int.parse(parts[1]), greaterThanOrEqualTo(100000));
      // 32-byte salt → 44-char base64 (with padding) or 43 without.
      final salt = base64Decode(parts[2]);
      final dk = base64Decode(parts[3]);
      expect(salt.length, 32);
      expect(dk.length, 32);
    });

    test('hash salt is random across setups (not deterministic)', () async {
      await repository.setupMasterPassword('hunter2');
      final first = mockConfig.cipherPass.value;

      await repository.setupMasterPassword('hunter2');
      final second = mockConfig.cipherPass.value;

      expect(
        first,
        isNot(equals(second)),
        reason: 'Two setups with the same password must not collide.',
      );
    });

    test('empty master password is rejected at setup', () async {
      final result = await repository.setupMasterPassword('');
      expect(result.isLeft(), true);
    });

    test(
      'legacy v1 hash is accepted and transparently upgraded to v2',
      () async {
        // Recreate the old v1 hash algorithm exactly.
        const password = 'legacy-password';
        const salt = 'vault-env-manager-v1-salt';
        final key = utf8.encode('master-key-derivation-secret');
        final data = utf8.encode(salt + base64.encode(utf8.encode(password)));
        final legacyHash = Hmac(sha256, key).convert(data).toString();

        await mockConfig.setCipherPass(legacyHash);
        expect(mockConfig.cipherPass.value.startsWith('v2\$'), false);

        final unlocked = await repository.unlock(password);
        expect(unlocked.isRight(), true);

        // After a successful legacy unlock the record must be re-saved as v2.
        expect(
          mockConfig.cipherPass.value.startsWith('v2\$'),
          true,
          reason:
              'Legacy record should be upgraded to v2 on successful unlock.',
        );

        // Subsequent unlocks go through the v2 path.
        final again = await repository.unlock(password);
        expect(again.isRight(), true);
      },
    );

    test('legacy v1 hash with wrong password is rejected', () async {
      const password = 'legacy-password';
      const salt = 'vault-env-manager-v1-salt';
      final key = utf8.encode('master-key-derivation-secret');
      final data = utf8.encode(salt + base64.encode(utf8.encode(password)));
      final legacyHash = Hmac(sha256, key).convert(data).toString();

      await mockConfig.setCipherPass(legacyHash);

      final result = await repository.unlock('not-the-password');
      expect(result.isLeft(), true);
      // The stored record must NOT be changed on a failed unlock.
      expect(mockConfig.cipherPass.value, legacyHash);
    });

    test(
      'unlock on a fresh install (no master password set) fails cleanly',
      () async {
        final result = await repository.unlock('anything');
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<AuthFailure>()),
          (_) => fail('Should have failed'),
        );
      },
    );

    // Regression for Devin Review BUG_pr-review-job-..._0001:
    // A tampered v2 record with a blank derived-key field used to unlock
    // with ANY password because _pbkdf2(..., dkLen: 0) returned an empty
    // list and the constant-time compare of two empty lists was true.
    test('tampered v2 record with empty derived key is rejected', () async {
      // Valid salt (44 chars base64 = 32 bytes) but empty derived key.
      final tampered = 'v2\$100000\$${base64Encode(List<int>.filled(32, 7))}\$';
      await mockConfig.setCipherPass(tampered);

      final result = await repository.unlock('any-password-at-all');
      expect(
        result.isLeft(),
        true,
        reason: 'Empty derived-key field must not unlock.',
      );

      // And the record is not modified.
      expect(mockConfig.cipherPass.value, tampered);
    });

    test('tampered v2 record with empty salt is rejected', () async {
      // Empty salt, arbitrary derived-key bytes.
      final tampered = 'v2\$100000\$\$${base64Encode(List<int>.filled(32, 9))}';
      await mockConfig.setCipherPass(tampered);

      final result = await repository.unlock('any-password-at-all');
      expect(
        result.isLeft(),
        true,
        reason: 'Empty salt field must not unlock.',
      );
    });

    test('malformed v2 record (wrong segment count) is rejected', () async {
      await mockConfig.setCipherPass('v2\$100000\$onlytwoparts');

      final result = await repository.unlock('anything');
      expect(result.isLeft(), true);
    });

    test('v2 record with non-numeric iterations is rejected', () async {
      final tampered =
          'v2\$abc\$'
          '${base64Encode(List<int>.filled(32, 1))}\$'
          '${base64Encode(List<int>.filled(32, 2))}';
      await mockConfig.setCipherPass(tampered);

      final result = await repository.unlock('whatever');
      expect(result.isLeft(), true);
    });
  });

  // PBKDF2-HMAC-SHA256 correctness is the foundation of the v2 scheme: a
  // subtle bug here (wrong endianness, off-by-one on iterations, bad XOR
  // order) would silently produce a different derived key and lock every
  // install out of their vault on upgrade. These RFC 6070 / RFC 7914
  // adjacent test vectors pin the implementation to the standard output.
  group('pbkdf2HmacSha256 (RFC 6070-style vectors)', () {
    // Vector 1 — RFC 7914 appendix-style SHA-256 vector.
    //   P = "password", S = "salt", c = 1, dkLen = 32
    test('c=1, dkLen=32, password="password", salt="salt"', () {
      final out = pbkdf2HmacSha256(
        password: utf8.encode('password'),
        salt: utf8.encode('salt'),
        iterations: 1,
        dkLen: 32,
      );
      expect(
        _hex(out),
        '120fb6cffcf8b32c43e7225256c4f837'
        'a86548c92ccc35480805987cb70be17b',
      );
    });

    // Vector 2 — c=2 exercises the XOR accumulation path.
    test('c=2, dkLen=32', () {
      final out = pbkdf2HmacSha256(
        password: utf8.encode('password'),
        salt: utf8.encode('salt'),
        iterations: 2,
        dkLen: 32,
      );
      expect(
        _hex(out),
        'ae4d0c95af6b46d32d0adff928f06dd0'
        '2a303f8ef3c251dfd6e2d85a95474c43',
      );
    });

    // Vector 3 — multi-block output (dkLen=40 → two blocks).
    test('c=4096, dkLen=40 (multi-block)', () {
      final out = pbkdf2HmacSha256(
        password: utf8.encode('passwordPASSWORDpassword'),
        salt: utf8.encode('saltSALTsaltSALTsaltSALTsaltSALTsalt'),
        iterations: 4096,
        dkLen: 40,
      );
      expect(
        _hex(out),
        '348c89dbcbd32b2f32d814b8116e84cf'
        '2b17347ebc1800181c4e2a1fb8dd53e1'
        'c635518c7dac47e9',
      );
    });

    test('dkLen=0 returns an empty list (edge case)', () {
      // The implementation must not crash or produce non-empty output
      // when dkLen is 0. The auth repository guards against this at the
      // caller layer; this test documents the primitive's own behaviour.
      final out = pbkdf2HmacSha256(
        password: utf8.encode('password'),
        salt: utf8.encode('salt'),
        iterations: 10,
        dkLen: 0,
      );
      expect(out, isEmpty);
    });
  });
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
