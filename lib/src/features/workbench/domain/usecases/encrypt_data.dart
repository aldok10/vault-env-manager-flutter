import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_workbench_repository.dart';
import 'package:vault_env_manager/src/shared/utils/key_normalization_util.dart';

import '../value_objects/encryption_algorithm.dart';
import '../value_objects/secret_key.dart';

class EncryptData {
  final IWorkbenchRepository _repository;

  EncryptData(this._repository);

  Future<Either<Failure, String>> call(
    String plaintext,
    SecretKey rawKey,
    EncryptionAlgorithm algorithm,
  ) async {
    if (rawKey.value.isEmpty) {
      return const Left(SecurityFailure('Master Key undefined.'));
    }

    final normalizedKey = _normalizeKey(rawKey.value, algorithm.value);
    return _repository.encrypt(
      plaintext,
      SecretKey(normalizedKey),
      algorithm: algorithm,
    );
  }

  String _normalizeKey(String key, String algorithm) {
    final len = algorithm.contains('128') ? 16 : 32;
    return KeyNormalizationUtil.normalize(key, targetLength: len);
  }
}
