import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/shared/utils/crypt.dart';
import '../../../../shared/exceptions/crypt_exception.dart';

final class EncryptionService extends GetxService {
  Future<EncryptionService> init() async {
    return this;
  }

  /// Non-blocking encryption using Isolates (compute).
  Future<Either<Failure, String>> encryptAsync(
    String plaintext,
    String key, {
    String algorithm = 'aes-256-cbc',
  }) async {
    try {
      return await compute(_encryptInternal, {
        'plaintext': plaintext,
        'key': key,
        'algorithm': algorithm,
      });
    } catch (e) {
      return Left(SecurityFailure("Isolate execution failed: $e"));
    }
  }

  /// Non-blocking decryption using Isolates (compute).
  Future<Either<Failure, String>> decryptAsync(
    String ciphertext,
    String key, {
    String algorithm = 'aes-256-cbc',
  }) async {
    try {
      return await compute(_decryptInternal, {
        'ciphertext': ciphertext,
        'key': key,
        'algorithm': algorithm,
      });
    } catch (e) {
      return Left(SecurityFailure("Isolate execution failed: $e"));
    }
  }

  // ─── Algorithm Router ──────────────────────────────────────────────────

  static Future<Either<Failure, String>> _encryptInternal(
    Map<String, dynamic> args,
  ) async {
    final String plaintext = args['plaintext'];
    final String key = args['key'];
    final String algorithm = args['algorithm'] ?? 'aes-256-cbc';

    if (plaintext.isEmpty) return const Right("");
    if (key.isEmpty) {
      return const Left(SecurityFailure("Encryption key cannot be empty."));
    }

    try {
      final keySize = algorithm.contains('128') ? 128 : 256;
      final crypt = Crypt.fromAppKey(key, keySize: keySize);

      final result = crypt.encrypt(plaintext, algorithm: algorithm);
      return Right(result);
    } catch (e) {
      return Left(SecurityFailure("Encryption failed: $e"));
    }
  }

  static Future<Either<Failure, String>> _decryptInternal(
    Map<String, dynamic> args,
  ) async {
    final String ciphertext = args['ciphertext'];
    final String key = args['key'];
    final String algorithm = args['algorithm'] ?? 'aes-256-cbc';

    if (ciphertext.isEmpty) return const Right("");
    if (key.isEmpty) {
      return const Left(SecurityFailure("Decryption key required."));
    }

    try {
      final keySize = algorithm.contains('128') ? 128 : 256;
      final crypt = Crypt.fromAppKey(key, keySize: keySize);

      final result = crypt.decrypt(ciphertext, algorithm: algorithm);
      return Right(result);
    } on MacInvalidException {
      return const Left(
        SecurityFailure(
          "Integrity check failed (MAC/Tag mismatch). Data may be tampered or key is wrong.",
        ),
      );
    } catch (e) {
      return Left(SecurityFailure("Decryption failed: $e"));
    }
  }
}
