import 'package:get/get.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

/// Initial Binding — only registers truly global dependencies
/// that have ZERO dependency on async-initialized services.
///
/// Services like AppConfigService, StorageService, etc. are registered
/// by InitialLoaderController via Get.putAsync() during app bootstrap.
/// Route-level dependencies (repositories, controllers) are registered
/// in their respective feature bindings.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Zero-dependency globals only.
    Get.lazyPut<LogService>(() => LogService(), fenix: true);
  }
}
