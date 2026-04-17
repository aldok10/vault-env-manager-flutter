import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AppConfigService _config;

  AuthRepositoryImpl(this._config);

  @override
  bool isSetup() {
    return _config.cipherPass.value.isNotEmpty;
  }

  @override
  Future<Either<Failure, bool>> setupMasterPassword(String password) async {
    try {
      final hash = _generateHash(password);
      await _config.setCipherPass(hash);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize security: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> unlock(String password) async {
    try {
      final inputHash = _generateHash(password);
      if (inputHash == _config.cipherPass.value) {
        return const Right(true);
      } else {
        return const Left(AuthFailure('Invalid master password'));
      }
    } catch (e) {
      return Left(ServerFailure('Authentication error: $e'));
    }
  }

  @override
  Future<void> lock() async {
    // Session-only lock, keep the cipherPass hash in config for next unlock
  }

  String _generateHash(String password) {
    // Parity with Go 'hash' function in encrypter/encryption/hash_helper.go
    // Note: In the reference, it uses IV + Value. For master password,
    // we use a fixed salt/nonce for the 'Security Protocol' hash.
    const salt = 'vault-env-manager-v1-salt';
    final key = utf8.encode('master-key-derivation-secret');
    final data = utf8.encode(salt + base64.encode(utf8.encode(password)));

    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(data);

    return digest.toString(); // hex string
  }
}
