import 'package:get/get.dart';

import '../../../../shared/mixins/hydrated_mixin.dart';
import '../services/security_config_service.dart';

mixin SecurityFacadeMixin on GetxService, HydratedMixin {
  SecurityConfigService get security => SecurityConfigService.to;

  Future<void> setCipherPass(String pass) async {
    await security.setCipherPass(pass);
    await updateHydrated();
  }
}
