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

  /// Creates a Crypt from a Laravel APP_KEY string.
  /// Automatically handles the `base64:` prefix.
  factory Crypt.fromAppKey(String appKey, {int keySize = 256}) {
    String raw = appKey;
    if (raw.startsWith('base64:')) {
      raw = raw.substring(7);
    }

    // Normalize Base64 (handle base64url and missing padding)
    raw = raw.replaceAll('-', '+').replaceAll('_', '/');
    while (raw.length % 4 != 0) {
      raw += '=';
    }

    try {
      final decoded = base64Decode(raw);
      return Crypt.fromBytes(Uint8List.fromList(decoded), keySize: keySize);
    } catch (e) {
      // If it's not a valid base64 key, use it as a raw string (UTF-8)
      // but ensure it's padded/trimmed to the correct size.
      final utf8Bytes = utf8.encode(raw);
      final keyBytes = Uint8List(keySize ~/ 8);
      for (var i = 0; i < keyBytes.length; i++) {
        if (i < utf8Bytes.length) keyBytes[i] = utf8Bytes[i];
      }
      return Crypt.fromBytes(keyBytes, keySize: keySize);
    }
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
