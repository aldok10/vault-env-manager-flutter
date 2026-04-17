import 'package:vault_env_manager/src/core/domain/value_object.dart';

class Label extends ValueObject<String> {
  const Label(super.value);

  /// Validates that the label is not empty.
  bool get isValid => value.trim().isNotEmpty;

  /// Returns the trimmed label value.
  String get displayValue => value.trim();

  @override
  String toString() => displayValue;
}
