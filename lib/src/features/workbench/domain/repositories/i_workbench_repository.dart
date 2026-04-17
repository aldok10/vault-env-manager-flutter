import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

import '../value_objects/encryption_algorithm.dart';
import '../value_objects/secret_key.dart';

abstract class IWorkbenchRepository {
  Future<Either<Failure, List<String>>> fetchEnvKeys({
    required String origin,
    required String token,
    required String scrapingUrl,
  });

  Future<Either<Failure, String>> encrypt(
    String plaintext,
    SecretKey key, {
    EncryptionAlgorithm? algorithm,
  });
  Future<Either<Failure, String>> decrypt(
    String ciphertext,
    SecretKey key, {
    EncryptionAlgorithm? algorithm,
  });
}
