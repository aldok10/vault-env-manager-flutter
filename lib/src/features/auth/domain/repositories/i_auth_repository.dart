import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

abstract class IAuthRepository {
  /// Check if a master password has already been set.
  bool isSetup();

  /// Register a new master password.
  Future<Either<Failure, bool>> setupMasterPassword(String password);

  /// Unlock the workbench using the master password.
  Future<Either<Failure, bool>> unlock(String password);

  /// Clear the local session.
  Future<void> lock();
}
