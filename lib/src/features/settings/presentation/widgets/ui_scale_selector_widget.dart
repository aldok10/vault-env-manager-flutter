import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';

/// 📏 UiScaleSelectorWidget
/// Migrated to SeraphineUI for 2026.
class UiScaleSelectorWidget extends GetView<SettingsController> {
  const UiScaleSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    // Defines available scale factors
    final scales = {
      0.5: '50%',
      0.75: '75%',
      0.85: '85%',
      1.0: '100%',
      1.1: '110%',
      1.25: '125%',
      1.5: '150%',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UI SCALING ALGORITHM',
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
            children: scales.entries.map((entry) {
              final scaleValue = entry.key;
              final label = entry.value;
              final isSelected =
                  (controller.uiScale.value - scaleValue).abs() < 0.01;

              return _buildScalePill(context, label, isSelected, scaleValue);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScalePill(
    BuildContext context,
    String label,
    bool isSelected,
    double scaleValue,
  ) {
    final colors = SeraphineColors.of(context);
    return InkWell(
      onTap: () => controller.setScale(scaleValue),
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
          label,
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
