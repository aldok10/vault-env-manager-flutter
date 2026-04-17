import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vault_env_manager/src/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:vault_env_manager/src/features/auth/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IAuthRepository>(
      () => AuthRepositoryImpl(Get.find<AppConfigService>()),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<IAuthRepository>()),
      fenix: true,
    );
  }
}
