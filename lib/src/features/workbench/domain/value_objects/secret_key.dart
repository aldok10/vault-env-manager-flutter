import 'package:vault_env_manager/src/core/domain/value_object.dart';

class SecretKey extends ValueObject<String> {
  const SecretKey(super.value);

  /// Validates the key length (32 chars standard for AES-256).
  bool get isValid => value.length == 32;

  /// Returns a masked version of the key for UI display.
  String get masked => value.length > 8
      ? '${value.substring(0, 4)}****${value.substring(value.length - 4)}'
      : '********';

  @override
  String toString() => masked;
}
