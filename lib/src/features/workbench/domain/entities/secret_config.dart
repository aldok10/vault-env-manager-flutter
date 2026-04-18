import 'package:equatable/equatable.dart';

import '../value_objects/encryption_algorithm.dart';
import '../value_objects/label.dart';
import '../value_objects/secret_key.dart';

class SecretConfig extends Equatable {
  final String id;
  final Label label;
  final SecretKey key;
  final EncryptionAlgorithm algorithm;

  const SecretConfig({
    required this.id,
    required this.label,
    required this.key,
    required this.algorithm,
  });

  /// Factory for creating a completely empty or default configuration.
  factory SecretConfig.empty(String id) => SecretConfig(
        id: id,
        label: const Label(''),
        key: const SecretKey(''),
        algorithm: const EncryptionAlgorithm(EncryptionAlgorithm.aes256gcm),
      );

  /// Business logic: Validates if the configuration is complete and usable.
  bool get isValid =>
      id.isNotEmpty && label.isValid && key.isValid && algorithm.isSupported;

  @override
  List<Object?> get props => [id, label, key, algorithm];

  SecretConfig copyWith({
    String? id,
    Label? label,
    SecretKey? key,
    EncryptionAlgorithm? algorithm,
  }) {
    return SecretConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      key: key ?? this.key,
      algorithm: algorithm ?? this.algorithm,
    );
  }
}
