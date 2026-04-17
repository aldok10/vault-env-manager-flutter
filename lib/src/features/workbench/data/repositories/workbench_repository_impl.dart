import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/app/data/services/encryption_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_workbench_repository.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/encryption_algorithm.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/secret_key.dart';

class WorkbenchRepositoryImpl implements IWorkbenchRepository {
  final VaultService _vaultService;
  final EncryptionService _encryptionService;

  WorkbenchRepositoryImpl(this._vaultService, this._encryptionService);

  @override
  Future<Either<Failure, List<String>>> fetchEnvKeys({
    required String origin,
    required String token,
    required String scrapingUrl,
  }) async {
    return _vaultService.getEnvKeys(origin, token, scrapingUrl);
  }

  @override
  Future<Either<Failure, String>> encrypt(
    String plaintext,
    SecretKey key, {
    EncryptionAlgorithm? algorithm,
  }) {
    return _encryptionService.encryptAsync(
      plaintext,
      key.value,
      algorithm: algorithm?.value ?? 'aes-256-cbc',
    );
  }

  @override
  Future<Either<Failure, String>> decrypt(
    String ciphertext,
    SecretKey key, {
    EncryptionAlgorithm? algorithm,
  }) {
    return _encryptionService.decryptAsync(
      ciphertext,
      key.value,
      algorithm: algorithm?.value ?? 'aes-256-cbc',
    );
  }
}
