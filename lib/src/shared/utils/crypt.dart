import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:vault_env_manager/src/shared/exceptions/crypt_exception.dart';
import 'package:vault_env_manager/src/shared/utils/crypt_helpers.dart';

/// Crypt provides 100% compatibility with Laravel (Go/PHP) encryption.
///
/// Supports AES-CBC and AES-GCM (128/256) encryption/decryption with
/// Laravel-standard JSON payloads: base64(json({ iv, value, mac, tag }))
///
/// Compatible with Go's `encrypt_env.go` and PHP's `Illuminate\Encryption`.
class Crypt {
  final Uint8List _key;
  final int keySize; // 128 or 256

  Crypt.fromBytes(this._key, {required this.keySize}) {
    final expectedLength = keySize ~/ 8;
    if (_key.length != expectedLength) {
      throw ArgumentError(
        'AES-$keySize requires a $expectedLength-byte key, '
        'got ${_key.length} bytes.',
      );
    }
  }

  /// Creates a [Crypt] from a Laravel `APP_KEY` string.
  ///
  /// Accepted formats:
  ///
  /// * `base64:<key>` — the Laravel canonical form (what `php artisan
  ///   key:generate` emits). Padding and base64url (`-`/`_`) variants are
  ///   tolerated before decoding.
  /// * Raw base64 / base64url of a key that decodes to *exactly*
  ///   `keySize / 8` bytes.
  ///
  /// **Intentionally rejected**:
  ///
  /// * Any input whose decoded byte length does not match `keySize / 8`.
  /// * Any input that is not valid base64 after the optional prefix is
  ///   stripped.
  ///
  /// Previous revisions of this factory attempted to salvage a key by
  /// either (a) treating non-base64 input as a UTF-8 string and zero-
  /// padding or truncating it to `keySize / 8` bytes, or (b) silently
  /// decoding a base64 payload of the wrong length. Both produced an
  /// `AES-256` context from attacker-controllable, low-entropy input
  /// (e.g. the string `password` zero-padded to 32 bytes has 8 bytes of
  /// entropy, not 32). That defeats the whole point of using a 256-bit
  /// key. A Laravel `APP_KEY` is always a base64-encoded CSPRNG key of
  /// the correct length — any deviation is a misconfiguration that must
  /// surface as an explicit error rather than be silently weakened.
  factory Crypt.fromAppKey(String appKey, {int keySize = 256}) {
    if (keySize != 128 && keySize != 256) {
      throw ArgumentError.value(
        keySize,
        'keySize',
        'AES key size must be 128 or 256 bits.',
      );
    }

    String raw = appKey;
    if (raw.startsWith('base64:')) {
      raw = raw.substring(7);
    }
    if (raw.isEmpty) {
      throw const CryptException(
        'APP_KEY is empty. Expected a base64-encoded key of '
        '16 or 32 bytes (Laravel `php artisan key:generate` output).',
      );
    }

    // Normalise base64url alphabet and pad to a multiple of 4 — callers
    // occasionally paste a key without the trailing `=` padding, which
    // is legal per RFC 4648 §3.2.
    raw = raw.replaceAll('-', '+').replaceAll('_', '/');
    while (raw.length % 4 != 0) {
      raw += '=';
    }

    final Uint8List decoded;
    try {
      decoded = Uint8List.fromList(base64Decode(raw));
    } on FormatException catch (e) {
      throw CryptException(
        'APP_KEY is not valid base64: ${e.message}. '
        'Expected `base64:<...>` produced by '
        '`php artisan key:generate`.',
      );
    }

    final expectedBytes = keySize ~/ 8;
    if (decoded.length != expectedBytes) {
      throw CryptException(
        'APP_KEY decodes to ${decoded.length} bytes but AES-$keySize '
        'requires exactly $expectedBytes bytes. Regenerate the key '
        'with `php artisan key:generate` (or set APP_KEY to a '
        'base64-encoded CSPRNG key of the correct length).',
      );
    }

    return Crypt.fromBytes(decoded, keySize: keySize);
  }

  /// Encrypts [plainText] into a Laravel-compatible Base64 payload.
  ///
  /// The output format matches the Go/Laravel standard:
  /// `base64(json({ iv, value, mac, tag }))`
  String encrypt(String plainText, {String algorithm = 'aes-256-cbc'}) {
    final isGcm = algorithm.contains('gcm');

    // 1. Serialize using PHP format (Laravel standard)
    final serialized = CryptHelpers.serializeString(plainText);

    final ivBytes = CryptHelpers.generateSecureRandom(isGcm ? 12 : 16);
    final iv = IV(ivBytes);
    final ivBase64 = base64Encode(ivBytes);

    String valueBase64;
    String mac = '';
    String tag = '';

    if (isGcm) {
      // AES-GCM
      final encrypter = Encrypter(AES(Key(_key), mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(serialized, iv: iv);

      // Laravel/Go GCM format: value is ciphertext WITHOUT tag, tag is separate.
      final fullBytes = encrypted.bytes;
      final cipherBytes = fullBytes.sublist(0, fullBytes.length - 16);
      final tagBytes = fullBytes.sublist(fullBytes.length - 16);

      valueBase64 = base64Encode(cipherBytes);
      tag = base64Encode(tagBytes);
    } else {
      // AES-CBC
      final encrypter = Encrypter(AES(Key(_key), mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(serialized, iv: iv);
      valueBase64 = encrypted.base64;

      // MAC is required for CBC to prevent padding oracle attacks
      mac = CryptHelpers.calculateMac(ivBase64, valueBase64, _key);
    }

    final jsonPayload = jsonEncode({
      'iv': ivBase64,
      'value': valueBase64,
      'mac': mac,
      'tag': tag,
    });

    return base64Encode(utf8.encode(jsonPayload));
  }

  /// Decrypts a Laravel/Go encrypted Base64 payload.
  String decrypt(
    String encryptedPayloadBase64, {
    String algorithm = 'aes-256-cbc',
  }) {
    try {
      final isGcm = algorithm.contains('gcm');
      final jsonString = utf8.decode(base64Decode(encryptedPayloadBase64));
      final Map<String, dynamic> payload = jsonDecode(jsonString);

      final String ivBase64 = payload['iv'];
      final String valueBase64 = payload['value'];
      final String macInPayload = payload['mac'] ?? '';
      final String tagInPayload = payload['tag'] ?? '';

      final iv = IV(base64Decode(ivBase64));

      String serialized;
      if (isGcm) {
        // AES-GCM
        final cipherBytes = base64Decode(valueBase64);
        final tagBytes = base64Decode(tagInPayload);

        // Combine for 'encrypt' package which expects [ciphertext + tag]
        final combined = Uint8List(cipherBytes.length + tagBytes.length);
        combined.setAll(0, cipherBytes);
        combined.setAll(cipherBytes.length, tagBytes);

        final encrypter = Encrypter(AES(Key(_key), mode: AESMode.gcm));
        serialized = encrypter.decrypt(Encrypted(combined), iv: iv);
      } else {
        // AES-CBC
        final calculatedMac = CryptHelpers.calculateMac(
          ivBase64,
          valueBase64,
          _key,
        );
        if (!CryptHelpers.constantTimeEquals(calculatedMac, macInPayload)) {
          throw const MacInvalidException();
        }

        final encrypter = Encrypter(AES(Key(_key), mode: AESMode.cbc));
        serialized = encrypter.decrypt64(valueBase64, iv: iv);
      }

      // 2. Unserialize (PHP format)
      return CryptHelpers.unserializeString(serialized);
    } on MacInvalidException {
      rethrow;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
