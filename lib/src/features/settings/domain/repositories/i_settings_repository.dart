import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

abstract class ISettingsRepository {
  Future<Either<Failure, void>> saveSettings({
    required String themeMode,
    required String osStyle,
    required double uiScale,
  });
}
