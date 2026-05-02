import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/encryption_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/shared/utils/env_parser.dart';

/// A service to specifically handle Laravel .env encryption and decryption.
/// This matches the behavior of php artisan env:encrypt and env:decrypt.
class LaravelEnvService extends GetxService {
  late final EncryptionService _encryptionService;

  void onInit() {
    super.onInit();
    _encryptionService = Get.find<EncryptionService>();
  }

  /// Encrypts the entire raw string content of a .env file.
  ///
  /// Equivalent to `php artisan env:encrypt`
  Future<Either<Failure, String>> encryptEnv(
    String content,
    String key, {
    String algorithm = 'aes-256-cbc',
  }) async {
    // Encrypt the entire string as a single payload
    return _encryptionService.encryptAsync(content, key, algorithm: algorithm);
  }

  /// Decrypts a Laravel .env.encrypted payload.
  ///
  /// Equivalent to `php artisan env:decrypt`
  Future<Either<Failure, String>> decryptEnv(
    String encryptedContent,
    String key, {
    String algorithm = 'aes-256-cbc',
  }) async {
    return _encryptionService.decryptAsync(
      encryptedContent,
      key,
      algorithm: algorithm,
    );
  }

  /// Extracts key-value pairs from a .env string.
  Map<String, String> parse(String content) {
    return EnvParser.parse(content);
  }

  /// Converts key-value pairs back to a .env string.
  String stringify(Map<String, String> data) {
    return EnvParser.stringify(data);
  }
}
