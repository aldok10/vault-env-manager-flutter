import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';

/// 📱 OsStyleSelectorWidget
/// Migrated to SeraphineUI for 2026.
class OsStyleSelectorWidget extends GetView<SettingsController> {
  const OsStyleSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    final styles = ['glass', 'flat', 'neumorphic'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OS DESIGN LANGUAGE',
          style: SeraphineTypography.label.copyWith(
            fontSize: 10,
            color: colors.textDetail,
            fontWeight: FontWeight.w700,
          ),
        ),
        SeraphineSpacing.mdV,
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: styles.map((style) {
              final isSelected = controller.osStyle.value == style;
              return _buildStylePill(context, style, isSelected);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStylePill(BuildContext context, String style, bool isSelected) {
    final colors = SeraphineColors.of(context);
    return InkWell(
      onTap: () => controller.setOsStyle(style),
      borderRadius: BorderRadius.circular(colors.cardRadius),
      child: AnimatedContainer(
        duration: SeraphineMotion.fast,
        curve: SeraphineMotion.smooth,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: ShapeDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceHighlight.withValues(alpha: 0.1),
          shape: SeraphineShapes.squircle(
            radius: colors.cardRadius,
            side: BorderSide(
              color: isSelected
                  ? colors.primary
                  : colors.border.withValues(alpha: 0.3),
            ),
          ),
          shadows: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Text(
          style.toUpperCase(),
          style: SeraphineTypography.label.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
