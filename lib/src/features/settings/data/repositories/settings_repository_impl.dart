import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/settings/domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final AppConfigService _configService;

  SettingsRepositoryImpl(this._configService);

  @override
  Future<Either<Failure, void>> saveSettings({
    required String themeMode,
    required String osStyle,
    required double uiScale,
  }) async {
    try {
      await _configService.setThemeMode(themeMode);
      await _configService.setOsStyle(osStyle);
      await _configService.setScale(uiScale);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
