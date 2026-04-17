import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/bindings/initial_binding.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/routes/app_pages.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_background.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_theme.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';
import 'package:vault_env_manager/src/shared/i18n/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  debugPrint('Starting services...');

  try {
    // Initialize storage first as it's a dependency for AppConfigService
    await Get.putAsync(() => StorageService().init(), permanent: true);

    // Initialize ComputeService (Missing Dependency)
    await Get.putAsync(() => ComputeService().init(), permanent: true);

    // Initialize AppConfigService facade
    await Get.putAsync(() => AppConfigService().init(), permanent: true);
  } catch (e) {
    debugPrint('Error during initialization: $e');
    // Rethrow to ensure we don't proceed with broken state if critical
    rethrow;
  }

  debugPrint('All services started.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Safety check: If services haven't finished registering, show a loading indicator
    // This prevents "Service not found" errors on the first frame.
    final bool isReady = Get.isRegistered<AppConfigService>();

    if (!isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SeraphineTheme.createTheme(
          colorTheme: 'default',
          osStyle: 'hyperos',
          isDark: true,
        ),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: SeraphineColors.primary),
                const SizedBox(height: 20),
                Text(
                  'INITIALIZING SECURE CORE...',
                  style: SeraphineTypography.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Obx(() {
      final config = AppConfigService.to;
      final modeStr = config.themeMode.value;
      final colorTheme = config.colorTheme.value;
      final osStyle = config.osStyle.value;

      ThemeMode mode = ThemeMode.dark;
      if (modeStr == 'light') {
        mode = ThemeMode.light;
      } else if (modeStr == 'system') {
        mode = ThemeMode.system;
      }

      return GetMaterialApp(
        title: 'Vault Master Workbench',
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        theme: SeraphineTheme.createTheme(
          colorTheme: colorTheme,
          osStyle: osStyle,
          isDark: false,
        ),
        darkTheme: SeraphineTheme.createTheme(
          colorTheme: colorTheme,
          osStyle: osStyle,
          isDark: true,
        ),
        themeMode: mode,
        translations: AppTranslations(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        builder: (context, child) =>
            _MainLayout(child: child ?? const SizedBox()),
      );
    });
  }
}

class _MainLayout extends StatelessWidget {
  final Widget child;
  const _MainLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            const SeraphineBackground(),
            _ScalingWrapper(constraints: constraints, child: child),
          ],
        );
      },
    );
  }
}

class _ScalingWrapper extends StatelessWidget {
  final BoxConstraints constraints;
  final Widget child;

  const _ScalingWrapper({required this.constraints, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final scale = AppConfigService.to.uiScale.value;
      
      if (scale == 1.0) return child;

      final baseData = MediaQuery.of(context);
      final targetWidth = constraints.maxWidth / scale;
      final targetHeight = constraints.maxHeight / scale;

      return OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: targetWidth,
        maxWidth: targetWidth,
        minHeight: targetHeight,
        maxHeight: targetHeight,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: MediaQuery(
            // 🧠 Communicate the "logical" scaled size to the whole app tree.
            // This ensures responsive layouts like sidebars/grids stretch correctly.
            data: baseData.copyWith(
              size: Size(targetWidth, targetHeight),
              padding: baseData.padding / scale,
              viewInsets: baseData.viewInsets / scale,
              viewPadding: baseData.viewPadding / scale,
            ),
            child: child,
          ),
        ),
      );
    });
  }
}
