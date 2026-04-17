import 'dart:convert';
import 'dart:typed_data';

/// Utility to normalize Vault Master Keys for encryption logic parity.
/// Handles base64url conversion and key padding.
class KeyNormalizationUtil {
  /// Normalizes a String key to a Base64-encoded bytes string.
  /// 1. Decodes base64url if needed.
  /// 2. Pads to targetLength or nearest (AES-128/256 compatible).
  static String normalize(String key, {int? targetLength}) {
    if (key.isEmpty) return "";

    final bool isExplicitBase64 = key.startsWith('base64:');
    final String cleanKey = isExplicitBase64 ? key.substring(7) : key;

    // 1. Convert base64url to base64
    String normalized = cleanKey.replaceAll('-', '+').replaceAll('_', '/');

    // 2. Add padding for base64 decoding
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }

    try {
      // Only attempt decode if it was explicit OR if it was already valid base64 with signs
      // Actually, to match Svelte parity we might need more criteria.
      // But for now, let's protect raw strings.
      if (!isExplicitBase64 &&
          !cleanKey.contains('-') &&
          !cleanKey.contains('_')) {
        throw Exception("Treat as raw");
      }

      final bytes = base64Decode(normalized);
      final padded = padTo(bytes, targetLength: targetLength);
      return base64Encode(padded);
    } catch (_) {
      // If not valid base64 or forced raw, treat as raw string and pad
      final bytes = utf8.encode(cleanKey);
      final padded = padTo(
        Uint8List.fromList(bytes),
        targetLength: targetLength,
      );
      return base64Encode(padded);
    }
  }

  /// Pads byte list to targetLength or nearest power of 16.
  static Uint8List padTo(Uint8List bytes, {int? targetLength}) {
    final int target = targetLength ?? (bytes.length > 16 ? 32 : 16);

    if (bytes.length >= target) {
      return bytes.sublist(0, target);
    }

    final padded = Uint8List(target);
    padded.setRange(0, bytes.length, bytes);
    return padded;
  }
}
