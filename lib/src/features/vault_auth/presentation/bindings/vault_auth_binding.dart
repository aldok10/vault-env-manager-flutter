import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/local_auth_service.dart';
import 'package:vault_env_manager/src/features/vault_auth/data/repositories/vault_auth_repository_impl.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/repositories/i_vault_auth_repository.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';

class VaultAuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use permanent http.Client from InitialBinding — do NOT create a new one
    Get.lazyPut<IVaultAuthRepository>(
      () => VaultAuthRepositoryImpl(
        Get.find<http.Client>(),
        Get.find<AppConfigService>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => VaultAuthController(
        Get.find<IVaultAuthRepository>(),
        Get.find<AppConfigService>(),
        Get.find<LocalAuthService>(),
      ),
      fenix: true,
    );
  }
}
