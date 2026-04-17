import 'package:get/get.dart';

import '../../../../shared/mixins/hydrated_mixin.dart';
import '../services/workbench_config_service.dart';

mixin WorkbenchFacadeMixin on GetxService, HydratedMixin {
  WorkbenchConfigService get workbench => WorkbenchConfigService.to;

  Future<void> setEditorFont(String font) async {
    await workbench.setEditorFont(font);
    await updateHydrated();
  }

  Future<void> setTabSize(int size) async {
    await workbench.setTabSize(size);
    await updateHydrated();
  }

  Future<void> toggleAutoSave(bool value) async {
    await workbench.toggleAutoSave(value);
    await updateHydrated();
  }
}
