import 'package:get/get.dart';
import 'package:vault_env_manager/src/features/initial_loader/presentation/controllers/initial_loader_controller.dart';

class InitialLoaderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InitialLoaderController(), fenix: true);
  }
}
