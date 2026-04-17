import 'package:get/get.dart';

import '../../../../shared/mixins/hydrated_mixin.dart';
import '../services/appearance_config_service.dart';

mixin AppearanceFacadeMixin on GetxService, HydratedMixin {
  AppearanceConfigService get appearance => AppearanceConfigService.to;

  Future<void> setTheme(String themeMode) async {
    await appearance.setThemeMode(themeMode);
    await updateHydrated();
  }

  Future<void> setOsStyle(String style) async {
    await appearance.setOsStyle(style);
    await updateHydrated();
  }

  Future<void> setScale(double scale) async {
    await appearance.setScale(scale);
    await updateHydrated();
  }
}
