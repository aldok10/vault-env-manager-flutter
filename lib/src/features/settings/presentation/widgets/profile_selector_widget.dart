import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_dropdown.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';

/// 🏢 ProfileSelectorWidget
/// Environment switcher reimagined for SeraphineUI.
class ProfileSelectorWidget extends GetView<SettingsController> {
  const ProfileSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVE ENVIRONMENT',
              style: SeraphineTypography.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: SeraphineColors.of(context).textDetail,
              ),
            ),
            _buildActions(context),
          ],
        ),
        SeraphineSpacing.smV,
        _buildDropdownSelector(),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => controller.vaultProfiles.length > 1
              ? IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(
                    CupertinoIcons.trash_fill,
                    color: SeraphineColors.of(context).primary,
                    size: 16,
                  ),
                  tooltip: 'Delete Profile',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : const SizedBox.shrink(),
        ),
        SeraphineSpacing.mdH,
        IconButton(
          onPressed: () => controller.createNewProfile(),
          icon: Icon(
            CupertinoIcons.add_circled_solid,
            color: SeraphineColors.of(context).primary,
            size: 20,
          ),
          tooltip: 'New Environment',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildDropdownSelector() {
    return Obx(() {
      final profiles = controller.vaultProfiles;
      final activeId = controller.activeProfileId.value;
      final names = profiles.map((p) => p.name).toList();
      final activeProfile = profiles.firstWhereOrNull((p) => p.id == activeId);

      return SeraphineDropdown(
        label: '', // Label handled by parent column
        value: (activeProfile?.name ?? '').obs,
        items: names,
        onChanged: (val) {
          final profile = profiles.firstWhereOrNull((p) => p.name == val);
          if (profile != null && profile.id != activeId) {
            controller.switchProfile(profile.id);
          }
        },
      );
    });
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Environment'),
        content: const Text(
          'Are you sure you want to permanently delete this environment? This will erase the API token.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteActiveProfile();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
