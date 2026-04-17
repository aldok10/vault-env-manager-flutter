import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_dropdown.dart';

/// 💎 SeraphineTenantSwitcher
/// A premium vault switcher with refractive glass aesthetics.
class SeraphineTenantSwitcher extends StatelessWidget {
  const SeraphineTenantSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfigService.to;

    return Obx(() {
      final activeProfile = config.vaultProfiles.firstWhere(
        (p) => p.id == config.activeProfileId.value,
        orElse: () => config.vaultProfiles.first,
      );

      return SizedBox(
        width: 160, // Fixed width for header consistency
        child: SeraphineDropdown<VaultProfile>(
          items: config.vaultProfiles,
          value: Rx<VaultProfile>(activeProfile),
          isDense: true,
          isUppercase: true,
          prefixIcon: CupertinoIcons.cloud_fill,
          itemLabelBuilder: (profile) => profile.name,
          onChanged: (profile) {
            if (profile != null) {
              config.switchVault(profile.id);
            }
          },
        ),
      );
    });
  }
}
