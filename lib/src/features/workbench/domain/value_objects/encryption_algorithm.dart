import 'package:vault_env_manager/src/core/domain/value_object.dart';

class EncryptionAlgorithm extends ValueObject<String> {
  const EncryptionAlgorithm(super.value);

  /// Standard AES GCM for high security.
  static const aes256gcm = 'aes-256-gcm';

  /// Standard AES CBC (legacy support).
  static const aes256cbc = 'aes-256-cbc';

  static const supported = [aes256gcm, aes256cbc];

  /// Validates that the algorithm is supported.
  bool get isSupported => supported.contains(value);

  @override
  String toString() => value;
}
