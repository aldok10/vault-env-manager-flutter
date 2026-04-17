import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/core/utils/json_validator_mixin.dart';

import '../../domain/entities/secret_config.dart';
import '../../domain/value_objects/encryption_algorithm.dart';
import '../../domain/value_objects/label.dart';
import '../../domain/value_objects/secret_key.dart';

class SecretConfigModel with JsonValidatorMixin {
  final String id;
  final String label;
  final String key;
  final String algorithm;

  SecretConfigModel({
    required this.id,
    required this.label,
    required this.key,
    required this.algorithm,
  });

  /// Converts the model to a Domain Entity.
  SecretConfig toDomain() {
    return SecretConfig(
      id: id,
      label: Label(label),
      key: SecretKey(key),
      algorithm: EncryptionAlgorithm(algorithm),
    );
  }

  /// Creates a model from a Domain Entity.
  factory SecretConfigModel.fromDomain(SecretConfig entity) {
    return SecretConfigModel(
      id: entity.id,
      label: entity.label.value,
      key: entity.key.value,
      algorithm: entity.algorithm.value,
    );
  }

  /// Secure factory that returns Either a Failure or a Validated Model.
  static Either<Failure, SecretConfigModel> fromMapSecure(
    Map<String, dynamic> map,
  ) {
    final validator = _SecretConfigValidator();
    final result = validator.validate(map, ['id', 'label', 'key']);

    return result.map(
      (validMap) => SecretConfigModel(
        id: validMap['id'],
        label: validMap['label'],
        key: validMap['key'],
        algorithm: validMap['algorithm'] ?? 'aes-256-cbc',
      ),
    );
  }

  /// JSON Serialization logic (Infrastructure concern).
  Map<String, dynamic> toMap() {
    return {'id': id, 'label': label, 'key': key, 'algorithm': algorithm};
  }

  factory SecretConfigModel.fromMap(Map<String, dynamic> map) {
    return SecretConfigModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      key: map['key'] ?? '',
      algorithm: map['algorithm'] ?? 'aes-256-cbc',
    );
  }

  String toJson() => json.encode(toMap());

  factory SecretConfigModel.fromJson(String source) =>
      SecretConfigModel.fromMap(json.decode(source));
}

class _SecretConfigValidator with JsonValidatorMixin {}
