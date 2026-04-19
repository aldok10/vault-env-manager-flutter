import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<Either<Failure, void>> writeSecureData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return Right(null);
    } catch (e) {
      return Left(Failure('Failed to write secure data: $e'));
    }
  }

  Future<Either<Failure, String?>> readSecureData(String key) async {
    try {
      final value = await _storage.read(key: key);
      return Right(value);
    } catch (e) {
      return Left(Failure('Failed to read secure data: $e'));
    }
  }

  Future<Either<Failure, void>> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
      return Right(null);
    } catch (e) {
      return Left(Failure('Failed to delete secure data: $e'));
    }
  }

  Future<Either<Failure, void>> writeEncryptedEnvironmentVariables(Map<String, String> envVars) async {
    try {
      for (final entry in envVars.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }
      return Right(null);
    } catch (e) {
      return Left(Failure('Failed to write environment variables: $e'));
    }
  }

  Future<Either<Failure, Map<String, String>>> readAllEnvironmentVariables() async {
    try {
      final allKeys = await _storage.readAll();
      return Right(allKeys);
    } catch (e) {
      return Left(Failure('Failed to read all environment variables: $e'));
    }
  }

  Future<Either<Failure, void>> deleteAllEnvironmentVariables() async {
    try {
      await _storage.deleteAll();
      return Right(null);
    } catch (e) {
      return Left(Failure('Failed to delete all environment variables: $e'));
    }
  }
}

class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}