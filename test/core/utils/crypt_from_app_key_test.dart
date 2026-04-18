import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/exceptions/crypt_exception.dart';
import 'package:vault_env_manager/src/shared/utils/crypt.dart';

/// Tests for the input-validation hardening on `Crypt.fromAppKey`.
///
/// Before this PR, the factory silently salvaged a key by either
/// zero-padding a short UTF-8 string to the cipher's key size, or
/// accepting a base64 payload of any length. Both constructed an
/// `AES-256` context from low-entropy material (`'password'` padded to
/// 32 bytes has ≈8 bytes of real entropy, not 32). These tests pin the
/// new, stricter contract.
void main() {
  // 32 random-looking bytes → 256-bit key. Using `List.generate` instead
  // of an inline literal so a future refactor cannot silently truncate
  // the constant.
  final validKeyBytes = Uint8List.fromList(
    List.generate(32, (i) => (i * 7) & 0xff),
  );
  final validAppKey = 'base64:${base64Encode(validKeyBytes)}';

  group('Crypt.fromAppKey — happy paths (preserved behaviour)', () {
    test('accepts a Laravel-style `base64:` key of the correct length', () {
      final crypt = Crypt.fromAppKey(validAppKey);
      expect(crypt.keySize, 256);
      // Round-trip proves the key bytes were preserved.
      final enc = crypt.encrypt('hello', algorithm: 'aes-256-cbc');
      expect(crypt.decrypt(enc, algorithm: 'aes-256-cbc'), 'hello');
    });

    test('accepts a raw base64 key without the `base64:` prefix', () {
      final crypt = Crypt.fromAppKey(base64Encode(validKeyBytes));
      expect(crypt.keySize, 256);
    });

    test('accepts base64url alphabet (`-`/`_`) and missing padding', () {
      // 32-byte key whose standard base64 contains at least one `+` and
      // `/` so the alphabet substitution actually exercises both.
      final key = Uint8List.fromList(
        List.generate(32, (i) => (i * 31 + 17) & 0xff),
      );
      final b64 = base64Encode(key);
      final b64url = b64
          .replaceAll('+', '-')
          .replaceAll('/', '_')
          .replaceAll('=', '');
      // Sanity-check the fixture actually exercises the substitution.
      expect(b64 == b64url, isFalse);
      final crypt = Crypt.fromAppKey(b64url);
      expect(crypt.keySize, 256);
    });

    test('accepts a 16-byte key when keySize: 128 is requested', () {
      final key16 = Uint8List.fromList(List.generate(16, (i) => i));
      final crypt = Crypt.fromAppKey(
        'base64:${base64Encode(key16)}',
        keySize: 128,
      );
      expect(crypt.keySize, 128);
    });
  });

  group('Crypt.fromAppKey — hardening (new rejections)', () {
    test('empty string after the `base64:` prefix is rejected', () {
      expect(() => Crypt.fromAppKey('base64:'), throwsA(isA<CryptException>()));
    });

    test('completely empty APP_KEY is rejected', () {
      expect(() => Crypt.fromAppKey(''), throwsA(isA<CryptException>()));
    });

    test('short UTF-8 string is NOT silently zero-padded', () {
      // "password" is 8 bytes. Before the fix this returned a Crypt
      // whose key was `70 61 73 73 77 6f 72 64 00 00 00 ...` — an
      // AES-256 context with 8 bytes of real entropy. Must now throw.
      expect(
        () => Crypt.fromAppKey('password'),
        throwsA(isA<CryptException>()),
      );
    });

    test('long UTF-8 string is NOT silently truncated', () {
      // 64 ASCII bytes: previously the first 32 would have been used
      // verbatim. Now the factory must refuse.
      expect(() => Crypt.fromAppKey('A' * 64), throwsA(isA<CryptException>()));
    });

    test('base64 input of the wrong byte length is rejected', () {
      // Valid base64, but decodes to 24 bytes — not 32.
      final short = Uint8List.fromList(List.generate(24, (i) => i));
      expect(
        () => Crypt.fromAppKey('base64:${base64Encode(short)}'),
        throwsA(isA<CryptException>()),
      );
    });

    test(
      'base64 input that decodes to 16 bytes is rejected for keySize 256',
      () {
        // A 16-byte (AES-128) key passed into a 256-bit context used to
        // succeed (the factory accepted the decoded bytes as-is because
        // it only checked "can we decode?"). Must now throw.
        final key16 = Uint8List.fromList(List.generate(16, (i) => i));
        expect(
          () => Crypt.fromAppKey('base64:${base64Encode(key16)}'),
          throwsA(isA<CryptException>()),
        );
      },
    );

    test(
      'base64 input that decodes to 32 bytes is rejected for keySize 128',
      () {
        expect(
          () => Crypt.fromAppKey(validAppKey, keySize: 128),
          throwsA(isA<CryptException>()),
        );
      },
    );

    test('non-base64 garbage is rejected with a clear message', () {
      // `=` is only legal as padding; a bare `!@#` is invalid alphabet
      // which `base64Decode` rejects with FormatException.
      try {
        Crypt.fromAppKey('base64:!@#not-valid');
        fail('Should have thrown CryptException.');
      } on CryptException catch (e) {
        expect(e.message, contains('not valid base64'));
      }
    });

    test('unsupported keySize argument is rejected with ArgumentError', () {
      expect(
        () => Crypt.fromAppKey(validAppKey, keySize: 192),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => Crypt.fromAppKey(validAppKey, keySize: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('no prefix + raw UTF-8 of length 32 bytes is still rejected', () {
      // Subtle edge case: 32 ASCII characters happen to decode from
      // base64 to 24 bytes (every 4 chars → 3 bytes). The factory must
      // NOT fall back to "interpret as UTF-8" even when the length
      // mismatch is off by a single alignment — the only sanctioned
      // path is "valid base64 that decodes to exactly keySize/8 bytes".
      final thirtyTwoAscii = 'A' * 32;
      expect(
        () => Crypt.fromAppKey(thirtyTwoAscii),
        throwsA(isA<CryptException>()),
      );
    });
  });

  group('Crypt.fromAppKey — error messages are actionable', () {
    test('wrong-length error mentions the expected byte count', () {
      try {
        final short = Uint8List.fromList(List.generate(24, (i) => i));
        Crypt.fromAppKey('base64:${base64Encode(short)}');
        fail('Should have thrown.');
      } on CryptException catch (e) {
        expect(e.message, contains('24 bytes'));
        expect(e.message, contains('32 bytes'));
        expect(e.message, contains('php artisan key:generate'));
      }
    });

    test('empty-key error points operator at key:generate', () {
      try {
        Crypt.fromAppKey('base64:');
        fail('Should have thrown.');
      } on CryptException catch (e) {
        expect(e.message, contains('php artisan key:generate'));
      }
    });
  });
}
