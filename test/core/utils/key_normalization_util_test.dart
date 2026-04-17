import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/utils/key_normalization_util.dart';

void main() {
  group('KeyNormalizationUtil Tests', () {
    test('Should normalize raw string to 16 bytes (AES-128)', () {
      const input = 'hello';
      final result = KeyNormalizationUtil.normalize(input, targetLength: 16);

      final decoded = base64Decode(result);
      expect(decoded.length, 16);
      expect(utf8.decode(decoded.sublist(0, 5)), 'hello');
      expect(decoded[5], 0); // Zero padding
    });

    test('Should normalize raw string to 32 bytes (AES-256)', () {
      const input = 'SuperSecretKey123';
      final result = KeyNormalizationUtil.normalize(input, targetLength: 32);

      final decoded = base64Decode(result);
      expect(decoded.length, 32);
      expect(utf8.decode(decoded.sublist(0, 17)), 'SuperSecretKey123');
      expect(decoded[17], 0);
    });

    test('Should handle base64url conversion and padding', () {
      // '_-79' is base64url for [255, 238, 253]
      // Normalizes to '/+79'
      const input = '_-79';
      final result = KeyNormalizationUtil.normalize(input, targetLength: 16);

      final decoded = base64Decode(result);
      expect(decoded.length, 16);
      expect(decoded[0], 255);
      expect(decoded[1], 238);
      expect(decoded[2], 253);
    });

    test('Should slice long strings to target length', () {
      // Use something that is NOT valid base64 to hit the catch block
      final input = '!' * 50;
      final result = KeyNormalizationUtil.normalize(input, targetLength: 32);

      final decoded = base64Decode(result);
      expect(decoded.length, 32);
      expect(decoded.every((b) => b == utf8.encode('!')[0]), true);
    });

    test('Should handle empty string', () {
      expect(KeyNormalizationUtil.normalize(''), '');
    });

    test('Should auto-detect target length if not provided', () {
      // 'abcde' (not valid b64 with 5 chars) -> utf8 encode (5 bytes) -> pads to 16
      expect(base64Decode(KeyNormalizationUtil.normalize('abcde')).length, 16);

      // 'a' * 20 (not valid b64) -> utf8 encode (20 bytes) -> pads to 32
      expect(base64Decode(KeyNormalizationUtil.normalize('!' * 20)).length, 32);
    });
  });
}
