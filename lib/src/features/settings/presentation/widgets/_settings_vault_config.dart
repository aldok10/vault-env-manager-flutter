import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_workbench_widget.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/vault_management_dialog.dart';

/// ⚙️ SettingsVaultConfig
/// Migrated to SeraphineUI for 2026 "Zero-Legacy" initiative.
class SettingsVaultConfig extends GetView<SettingsController> {
  const SettingsVaultConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = SeraphineColors.of(context);
      final activeProfile = controller.vaultProfiles.firstWhere(
        (p) => p.id == controller.activeProfileId.value,
        orElse: () => controller.vaultProfiles.first,
      );
      final color = activeProfile.accentColor != null
          ? Color(activeProfile.accentColor!)
          : colors.primary;
      final icon = activeProfile.iconData != null
          ? IconData(
              activeProfile.iconData!,
              fontFamily: 'CupertinoIcons',
              fontPackage: 'cupertino_icons',
            )
          : CupertinoIcons.cloud_fill;

      return SeraphineWorkbenchWidget(
        title: 'Vault Infrastructure',
        icon: CupertinoIcons.cloud_fill,
        isCollapsible: true,
        initialCollapsed: false,
        child: Padding(
          padding: const EdgeInsets.all(SeraphineSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ACTIVE TENANT HEADER
              _buildTenantHeader(context, activeProfile, color, icon),
              SeraphineSpacing.xlV,

              // SERVER CONFIGURATION
              SeraphineInputField(
                label: 'Server Origin',
                controller: controller.vaultOriginController,
                hint: 'https://vault.internal.io',
                prefixIcon: CupertinoIcons.antenna_radiowaves_left_right,
              ),
              SeraphineSpacing.lgV,
              SeraphineInputField(
                label: 'Access Token',
                controller: controller.vaultTokenController,
                hint: 'hvs.root_token_here',
                obscureText: true,
                prefixIcon: CupertinoIcons.lock,
              ),
              SeraphineSpacing.lgV,
              Row(
                children: [
                  Expanded(
                    child: SeraphineInputField(
                      label: 'KV Mount',
                      controller: controller.scrapingUrlController,
                      hint: 'secret',
                      prefixIcon: CupertinoIcons.layers_alt_fill,
                    ),
                  ),
                  SeraphineSpacing.mdH,
                  Expanded(
                    child: SeraphineInputField(
                      label: 'Namespace',
                      controller: controller.vaultNamespaceController,
                      hint: 'root',
                      prefixIcon: CupertinoIcons.rectangle_grid_2x2_fill,
                    ),
                  ),
                ],
              ),
              SeraphineSpacing.lgV,
              SeraphineInputField(
                label: 'Discovery Path',
                controller: controller.vaultDiscoveryPathController,
                hint: 'e.g. SAM/ or project/',
                prefixIcon: CupertinoIcons.folder_fill,
              ),
              SeraphineSpacing.lgV,

              // BRANDING SECTION
              _buildBrandingSection(context, color),
              SeraphineSpacing.xlV,

              // SSL TOGGLE
              _buildSslToggle(context, color),
              SeraphineSpacing.xlV,

              // ACTION BUTTON
              SeraphineButton(
                text: 'PERSIST & SYNC ${activeProfile.name.toUpperCase()}',
                variant: SeraphineButtonVariant.solid,
                onPressed: controller.isScraping.value
                    ? null
                    : () => controller.handleSaveVaultConfig(),
                isLoading: controller.isScraping.value,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTenantHeader(
    BuildContext context,
    dynamic activeProfile,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(SeraphineSpacing.md),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.1),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SeraphineSpacing.mdH,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE ENVIRONMENT',
                  style: SeraphineTypography.label.copyWith(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  activeProfile.name,
                  style: SeraphineTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SeraphineButton.glass(
            text: 'MANAGE ALL',
            onPressed: () => VaultManagementDialog.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context, Color color) {
    final colors = [
      0xFF007AFF,
      0xFF5856D6,
      0xFFFF2D55,
      0xFFFF9500,
      0xFF34C759,
      0xFF5AC8FA,
      0xFFE67E22,
      0xFF2ECC71,
    ];

    final icons = [
      CupertinoIcons.cloud_fill,
      CupertinoIcons.shield_fill,
      CupertinoIcons.lock_fill,
      CupertinoIcons.bolt_fill,
      CupertinoIcons.flame_fill,
      CupertinoIcons.ant_fill,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ENVIRONMENT BRANDING',
              style: SeraphineTypography.label.copyWith(fontSize: 10),
            ),
            Text(
              'HEX: ${color.toARGB32().toRadixString(16).toUpperCase()}',
              style: SeraphineTypography.caption.copyWith(fontSize: 9),
            ),
          ],
        ),
        SeraphineSpacing.smV,
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: colors.map((c) {
                    final isSelected = (controller.accentColor.value ??
                            SeraphineColors.of(context).primary.toARGB32()) ==
                        c;
                    return GestureDetector(
                      onTap: () => controller.setAccentColor(c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(c).withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SeraphineSpacing.lgH,
            Row(
              children: icons.map((icon) {
                final isSelected = (controller.iconData.value ??
                        CupertinoIcons.cloud_fill.codePoint) ==
                    icon.codePoint;
                return IconButton(
                  onPressed: () => controller.setIconData(icon.codePoint),
                  icon: Icon(icon),
                  color: isSelected
                      ? color
                      : SeraphineColors.of(context).textDetail,
                  iconSize: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  constraints: const BoxConstraints(),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSslToggle(BuildContext context, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SSL VERIFICATION',
                style: SeraphineTypography.label.copyWith(fontSize: 10),
              ),
              Text(
                controller.verifySsl.value ? 'ENFORCED' : 'BYPASSED',
                style: SeraphineTypography.bodySmall.copyWith(
                  color: controller.verifySsl.value
                      ? SeraphineColors.of(context).primary
                      : SeraphineColors.of(context).primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: controller.verifySsl.value,
          onChanged: (val) => controller.setVerifySsl(val),
          activeTrackColor: color.withValues(alpha: 0.5),
          activeThumbColor: color,
        ),
      ],
    );
  }
}
