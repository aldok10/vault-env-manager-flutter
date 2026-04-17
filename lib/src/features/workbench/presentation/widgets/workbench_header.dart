import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/routes/app_routes.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_status_badge.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_tenant_switcher.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

class WorkbenchHeader extends GetView<WorkbenchController> {
  const WorkbenchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        16,
      ), // Reduced paddings for more compact header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ Top System Row (Minimalist)
          Row(
            children: [
              _buildBranding(context),
              const Spacer(),
              const SeraphineTenantSwitcher(),
              SeraphineSpacing.smH,
              _buildSettingsButton(),
            ],
          ),

          const SizedBox(height: 16), // Reduced spacer
          // 💎 Reachable Title (Keep essence, less space)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Workbench',
                style: SeraphineTypography.h1.copyWith(
                  height: 1.0,
                  fontSize: 32, // Slightly smaller title
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

              const Spacer(),

              // 📡 Status & Indicators Row (Integrated into the same row for space efficiency)
              _buildStatusMessage(context),
              _buildStatusIndicators(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Obx(() {
      final config = AppConfigService.to;
      final activeId = config.activeProfileId.value;
      final profile = config.vaultProfiles.firstWhere(
        (p) => p.id == activeId,
        orElse: () => config.vaultProfiles.first,
      );

      final color = profile.accentColor != null
          ? Color(profile.accentColor!)
          : SeraphineColors.of(context).primary;

      final icon = profile.iconData != null
          ? IconData(
              profile.iconData!,
              fontFamily: 'CupertinoIcons',
              fontPackage: 'cupertino_icons',
            )
          : CupertinoIcons.shield_fill;

      return SeraphineGlassBox(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: color.withValues(alpha: 0.12),
        borderColor: color.withValues(alpha: 0.3),
        child: Semantics(
          label: 'App Title',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
                semanticLabel: 'Branding Icon',
              ),
              SeraphineSpacing.smH,
              Text(
                profile.name.toUpperCase(),
                style: SeraphineTypography.caption.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSettingsButton() {
    return _SeraphineIconButton(
      onPressed: () => Get.toNamed(AppRoutes.settings),
      icon: CupertinoIcons.settings,
      tooltip: 'Settings',
    );
  }

  Widget _buildStatusMessage(BuildContext context) {
    return Obx(
      () => controller.statusMessage.value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child:
                  Text(
                    controller.statusMessage.value.toUpperCase(),
                    style: SeraphineTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                      letterSpacing: 0.5,
                      color: controller.statusMessage.value.contains('FAILURE')
                          ? SeraphineColors.of(context).error
                          : SeraphineColors.of(context).textDetail,
                    ),
                  ).animate().fadeIn().shimmer(
                    duration: const Duration(milliseconds: 2000),
                  ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildStatusIndicators(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => SeraphineStatusBadge(
            label: 'ACTIVE SESSION',
            isVisible: controller.isVaultConnected.value,
          ),
        ),
        SeraphineSpacing.mdH,
        _buildConnectionChip(context),
      ],
    );
  }

  Widget _buildConnectionChip(BuildContext context) {
    return SeraphineGlassBox(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        borderRadius: BorderRadius.circular(14),
        child: Semantics(
          button: true,
          label: 'Vault Connection Details',
          onTapHint: 'Open connection drawer',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.antenna_radiowaves_left_right,
                  size: 16,
                  color: SeraphineColors.of(context).primary,
                  semanticLabel: 'Connection Status Icon',
                ),
                SeraphineSpacing.mdH,
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: SeraphineColors.of(context).textDetail,
                  semanticLabel: 'Open',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeraphineIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const _SeraphineIconButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  @override
  State<_SeraphineIconButton> createState() => _SeraphineIconButtonState();
}

class _SeraphineIconButtonState extends State<_SeraphineIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) {
          if (_isHovered) return;
          setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (!_isHovered) return;
          setState(() => _isHovered = false);
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: SeraphineMotion.fast,
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: _isHovered
                  ? SeraphineColors.of(
                      context,
                    ).surfaceHighlight.withValues(alpha: 0.5)
                  : Colors.transparent,
              shape: const CircleBorder(),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _isHovered
                  ? SeraphineColors.of(context).primary
                  : SeraphineColors.of(context).textDetail,
            ),
          ),
        ),
      ),
    );
  }
}
