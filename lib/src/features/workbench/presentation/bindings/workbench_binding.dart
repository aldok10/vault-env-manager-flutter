import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/encryption_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/laravel_env_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_service.dart';
import 'package:vault_env_manager/src/features/workbench/data/repositories/vault_repository_impl.dart';
import 'package:vault_env_manager/src/features/workbench/data/repositories/workbench_repository_impl.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/encryption_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/vault_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_vault_repository.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_workbench_repository.dart';
import 'package:vault_env_manager/src/features/workbench/domain/services/vault_scout_service.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/decrypt_data.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/encrypt_data.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/scout_vault_path.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/sync_vault_secret.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

class WorkbenchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IVaultRepository>(
      () => VaultRepositoryImpl(
        Get.find<http.Client>(),
        Get.find<AppConfigService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<IWorkbenchRepository>(
      () => WorkbenchRepositoryImpl(
        Get.find<VaultService>(),
        Get.find<EncryptionService>(),
      ),
      fenix: true,
    );

    // Domain Services
    Get.lazyPut(
      () => VaultScoutService(Get.find<IVaultRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => EncryptData(Get.find<IWorkbenchRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => DecryptData(Get.find<IWorkbenchRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SyncVaultSecret(Get.find<IVaultRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ScoutVaultPath(Get.find<VaultScoutService>()),
      fenix: true,
    );

    // Logic Managers
    Get.lazyPut(
      () => VaultLogicManager(
        Get.find<SyncVaultSecret>(),
        Get.find<IVaultRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => EncryptionLogicManager(
        Get.find<EncryptData>(),
        Get.find<DecryptData>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => WorkbenchController(
        Get.find<VaultLogicManager>(),
        Get.find<EncryptionLogicManager>(),
        Get.find<LaravelEnvService>(),
        Get.find<AppConfigService>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => DiscoveryController(Get.find<ScoutVaultPath>()),
      fenix: true,
    );
  }
}
