import 'package:get/get.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}
