import 'package:get/get.dart';
import 'package:vault_env_manager/src/shared/mixins/hydrated_mixin.dart';

class AppearanceConfigService extends GetxService with HydratedMixin {
  static AppearanceConfigService get to => Get.find();

  final themeMode = 'system'.obs;
  final osStyle = 'hyperos'.obs;
  final uiScale = 1.0.obs;
  final colorTheme = 'default'.obs;

  @override
  String get storageKey => 'appearance_config';

  bool get isDark {
    if (themeMode.value == 'system') {
      return Get.isPlatformDarkMode;
    }
    return themeMode.value == 'dark';
  }

  Future<AppearanceConfigService> init(Map<String, String> envDefaults) async {
    // Initial values from env if not hydrated
    if (!isHydrated) {
      themeMode.value = envDefaults['THEME_MODE'] ?? 'system';
      osStyle.value = envDefaults['OS_STYLE'] ?? 'hyperos';
      uiScale.value = double.tryParse(envDefaults['UI_SCALE'] ?? '1.0') ?? 1.0;
      colorTheme.value = 'default';
    }
    return this;
  }

  @override
  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.value,
        'osStyle': osStyle.value,
        'uiScale': uiScale.value,
        'colorTheme': colorTheme.value,
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    themeMode.value = json['themeMode'] ?? 'system';
    osStyle.value = json['osStyle'] ?? 'hyperos';
    uiScale.value = (json['uiScale'] as num?)?.toDouble() ?? 1.0;
    colorTheme.value = json['colorTheme'] ?? 'default';
  }

  Future<void> setThemeMode(String mode) async {
    final normalized = mode.toLowerCase();
    if (themeMode.value == normalized) return;
    themeMode.value = normalized;
    await updateHydrated();
    // Theme rebuild is handled reactively by Obx in main.dart.
    // Do NOT call Get.changeThemeMode() or Get.forceAppUpdate() here —
    // they conflict with the Obx-driven GetMaterialApp rebuild.
  }

  Future<void> setOsStyle(String style) async {
    final normalized = style.toLowerCase();
    if (osStyle.value == normalized) return;
    osStyle.value = normalized;
    await updateHydrated();
  }

  Future<void> setScale(double scaleFactor) async {
    if (uiScale.value == scaleFactor) return;
    uiScale.value = scaleFactor;
    await updateHydrated();
  }

  Future<void> setColorTheme(String themeId) async {
    final normalized = themeId.toLowerCase();
    if (colorTheme.value == normalized) return;
    colorTheme.value = normalized;
    await updateHydrated();
  }
}
