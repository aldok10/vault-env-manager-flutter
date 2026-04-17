import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🏛️ SettingsHeader
/// Reimagined for SeraphineUI with 2026 Liquid Glass tokens.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SeraphineSpacing.xl,
        SeraphineSpacing.xl,
        SeraphineSpacing.xl,
        SeraphineSpacing.md,
      ),
      child: Row(
        children: [
          _buildBackAction(context),
          SeraphineSpacing.mdH,
          _buildPillLabel(context),
        ],
      ),
    );
  }

  Widget _buildBackAction(BuildContext context) {
    return IconButton(
      onPressed: () => Get.back(),
      icon: const Icon(CupertinoIcons.left_chevron, size: 18),
      color: SeraphineColors.of(context).textPrimary,
      splashRadius: 24,
    );
  }

  Widget _buildPillLabel(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return SeraphineGlassBox(
      padding: const EdgeInsets.symmetric(
        horizontal: SeraphineSpacing.md,
        vertical: SeraphineSpacing.sm,
      ),
      color: colors.surface.withValues(alpha: 0.1),
      borderColor: colors.border.withValues(alpha: 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.slider_horizontal_3,
            size: 16,
            color: colors.accent,
          ),
          SeraphineSpacing.mdH,
          Text(
            'SYSTEM PREFERENCES',
            style: SeraphineTypography.label.copyWith(
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
