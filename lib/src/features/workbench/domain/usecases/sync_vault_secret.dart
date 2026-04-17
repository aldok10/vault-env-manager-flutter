import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_vault_repository.dart';

class SyncVaultSecret {
  final IVaultRepository _repository;

  SyncVaultSecret(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String path, {
    int? version,
  }) async {
    if (path.isEmpty) {
      return const Left(VaultPathFailure('Vault path must not be empty.'));
    }

    return _repository.getSecret(path, version: version);
  }
}
