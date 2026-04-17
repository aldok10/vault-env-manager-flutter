import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

abstract class IVaultRepository {
  /// Lists keys at a specific path.
  Future<Either<VaultFailure, List<String>>> listKeys(String path);

  /// Retrieves the raw data for a specific secret path.
  Future<Either<VaultFailure, Map<String, dynamic>>> getSecret(
    String path, {
    int? version,
  });

  /// Retrieves the metadata for a specific secret path.
  Future<Either<VaultFailure, Map<String, dynamic>>> getMetadata(String path);

  /// Saves or updates the raw data for a specific secret path.
  Future<Either<VaultFailure, void>> putSecret(
    String path,
    Map<String, dynamic> data,
  );
}
