import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Helper class for PHP serialization/deserialization and security utilities.
class CryptHelpers {
  /// PHP string serialization: `s:<byte_length>:"<value>";`
  static String serializeString(String value) {
    final bytes = utf8.encode(value);
    return 's:${bytes.length}:"$value";';
  }

  /// Robustly extracts value from PHP serialized string.
  /// PHP format: `s:<len>:"<value>";`
  static String unserializeString(String serialized) {
    if (!serialized.startsWith('s:')) return serialized;

    final firstQuoteIndex = serialized.indexOf('"');
    final lastQuoteIndex = serialized.lastIndexOf('"');

    if (firstQuoteIndex != -1 &&
        lastQuoteIndex != -1 &&
        firstQuoteIndex != lastQuoteIndex) {
      return serialized.substring(firstQuoteIndex + 1, lastQuoteIndex);
    }

    // Fallback regex if index search fails
    final match = RegExp(
      r'^s:\d+:"(.*)";$',
      dotAll: true,
    ).firstMatch(serialized);
    return match?.group(1) ?? serialized;
  }

  /// HMAC-SHA256: hash_hmac('sha256', ivBase64 + valueBase64, rawKey)
  /// Returns lowercase hex string (matches Go/Laravel's output).
  static String calculateMac(
    String ivBase64,
    String valueBase64,
    Uint8List key,
  ) {
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(ivBase64 + valueBase64));
    return digest.toString();
  }

  /// Constant-time comparison to prevent timing attacks.
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Securely generate random bytes.
  static Uint8List generateSecureRandom(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }
}
