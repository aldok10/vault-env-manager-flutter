import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/utils/crypt_helpers.dart';

void main() {
  group('CryptHelpers', () {
    group('serializeString', () {
      test('serializes empty string correctly', () {
        expect(CryptHelpers.serializeString(''), 's:0:"";');
      });

      test('serializes ascii string correctly', () {
        expect(CryptHelpers.serializeString('hello'), 's:5:"hello";');
      });

      test('serializes utf8 string correctly', () {
        // "👋" is 4 bytes
        expect(CryptHelpers.serializeString('👋'), 's:4:"👋";');
      });

      test('serializes string with quotes correctly', () {
        expect(CryptHelpers.serializeString('he"llo'), 's:6:"he"llo";');
      });
    });

    group('unserializeString', () {
      test('returns original if not matching s: prefix', () {
        expect(CryptHelpers.unserializeString('hello'), 'hello');
      });

      test('extracts value correctly via quotes', () {
        expect(CryptHelpers.unserializeString('s:5:"hello";'), 'hello');
      });

      test('extracts empty string correctly', () {
        expect(CryptHelpers.unserializeString('s:0:"";'), '');
      });

      test('extracts value with quotes inside', () {
        expect(CryptHelpers.unserializeString('s:6:"he"llo";'), 'he"llo');
      });

      test('returns original string if missing quotes', () {
        expect(CryptHelpers.unserializeString('s:5:hello;'), 's:5:hello;');
      });
    });

    group('calculateMac', () {
      test('generates expected deterministic mac', () {
        final key = Uint8List.fromList([1, 2, 3, 4, 5]);
        final ivBase64 = base64Encode(utf8.encode('iv'));
        final valueBase64 = base64Encode(utf8.encode('value'));

        final result1 = CryptHelpers.calculateMac(ivBase64, valueBase64, key);
        final result2 = CryptHelpers.calculateMac(ivBase64, valueBase64, key);

        expect(result1, result2);
        expect(result1.length, 64); // SHA256 hex string is 64 chars
      });

      test('different inputs produce different macs', () {
        final key = Uint8List.fromList([1, 2, 3, 4, 5]);
        final ivBase64 = base64Encode(utf8.encode('iv'));
        final valueBase64_1 = base64Encode(utf8.encode('value1'));
        final valueBase64_2 = base64Encode(utf8.encode('value2'));

        final result1 = CryptHelpers.calculateMac(ivBase64, valueBase64_1, key);
        final result2 = CryptHelpers.calculateMac(ivBase64, valueBase64_2, key);

        expect(result1, isNot(equals(result2)));
      });
    });

    group('constantTimeEquals', () {
      test('returns true for identical strings', () {
        expect(CryptHelpers.constantTimeEquals('hello', 'hello'), isTrue);
        expect(CryptHelpers.constantTimeEquals('', ''), isTrue);
      });

      test('returns false for different length strings', () {
        expect(CryptHelpers.constantTimeEquals('hello', 'hell'), isFalse);
      });

      test('returns false for same length different strings', () {
        expect(CryptHelpers.constantTimeEquals('hello', 'hollo'), isFalse);
      });
    });

    group('generateSecureRandom', () {
      test('generates bytes of correct length', () {
        final result = CryptHelpers.generateSecureRandom(16);
        expect(result.length, 16);

        final result2 = CryptHelpers.generateSecureRandom(0);
        expect(result2.length, 0);
      });

      test('generates different bytes each time', () {
        final result1 = CryptHelpers.generateSecureRandom(32);
        final result2 = CryptHelpers.generateSecureRandom(32);

        // Assuming high entropy, collisions are astronomically unlikely
        expect(result1, isNot(equals(result2)));
      });
    });
  });
}
