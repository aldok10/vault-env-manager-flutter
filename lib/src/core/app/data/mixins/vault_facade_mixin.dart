import 'package:get/get.dart';
import '../../../../shared/mixins/hydrated_mixin.dart';
import '../services/vault_config_service.dart';

mixin VaultFacadeMixin on GetxService, HydratedMixin {
  VaultConfigService get vault => VaultConfigService.to;

  Future<void> switchVault(String profileId) async {
    await vault.switchProfile(profileId);
    await updateHydrated();
  }

  Future<void> createVault(String name, String path) async {
    await vault.createProfile(name, path);
    await updateHydrated();
  }

  Future<void> deleteVault(String profileId) async {
    await vault.deleteProfile(profileId);
    await updateHydrated();
  }
}
