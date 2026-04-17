import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

abstract class IVaultAuthRepository {
  /// Validates a Vault token via /v1/auth/token/lookup-self
  Future<Either<VaultFailure, String>> loginWithToken(String token);

  /// Authenticates using LDAP credentials via /v1/auth/$mountPath/login/$username
  Future<Either<VaultFailure, String>> loginWithLdap({
    required String username,
    required String password,
    required String mountPath,
  });
}
