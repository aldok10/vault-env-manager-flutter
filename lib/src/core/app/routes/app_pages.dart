import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/routes/app_routes.dart';
import 'package:vault_env_manager/src/features/auth/presentation/bindings/auth_binding.dart';
import 'package:vault_env_manager/src/features/auth/presentation/pages/auth_page.dart';
import 'package:vault_env_manager/src/features/initial_loader/presentation/bindings/initial_loader_binding.dart';
import 'package:vault_env_manager/src/features/initial_loader/presentation/pages/initial_loader_page.dart';
import 'package:vault_env_manager/src/features/settings/presentation/bindings/settings_binding.dart';
import 'package:vault_env_manager/src/features/settings/presentation/pages/settings_page.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/bindings/vault_auth_binding.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/pages/vault_auth_page.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/bindings/workbench_binding.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/pages/workbench_page.dart';

class AppPages {
  static const initial = AppRoutes.loader;

  static final routes = [
    GetPage(
      name: AppRoutes.loader,
      page: () => const InitialLoaderPage(),
      binding: InitialLoaderBinding(),
    ),
    GetPage(
      name: AppRoutes.initial,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.workbench,
      page: () => const WorkbenchPage(),
      binding: WorkbenchBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.vaultAuth,
      page: () => const VaultAuthPage(),
      binding: VaultAuthBinding(),
    ),
  ];
}
