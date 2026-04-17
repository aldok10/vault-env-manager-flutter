import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

/// Mixin used by Mappers to validate JSON structure before data instantiation.
///
/// This prevents "Null check operator used on a null value" and type mismatch
/// errors in the UI by validating the contract at the Data Layer.
mixin JsonValidatorMixin {
  /// Validates that all [requiredKeys] exist in the [json] and are of expected types.
  ///
  /// Returns [Left(DataFailure)] if validation fails, otherwise [Right(json)].
  Either<Failure, Map<String, dynamic>> validate(
    Map<String, dynamic> json,
    List<String> requiredKeys,
  ) {
    for (final key in requiredKeys) {
      if (!json.containsKey(key)) {
        return Left(
          ParseFailure("Missing required key: '$key' in data contract."),
        );
      }
      if (json[key] == null) {
        return Left(
          ParseFailure("Required key: '$key' is null in data contract."),
        );
      }
    }
    return Right(json);
  }

  /// Specialized validation for specific field types.
  Either<Failure, T> getField<T>(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return Left(ParseFailure("Field '$key' is null."));
    }
    if (value is! T) {
      return Left(
        ParseFailure(
          "Field '$key' is of type ${value.runtimeType}, expected $T.",
        ),
      );
    }
    return Right(value);
  }
}
