import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';

/// 🌓 ThemeSelectorWidget
/// Migrated to SeraphineUI for 2026.
class ThemeSelectorWidget extends GetView<SettingsController> {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APPEARANCE MODE',
          style: SeraphineTypography.label.copyWith(
            fontSize: 10,
            color: colors.textDetail,
            fontWeight: FontWeight.w700,
          ),
        ),
        SeraphineSpacing.mdV,
        const Row(
          children: [
            _ThemeOption(
              label: 'DARK NEBULA',
              themeValue: 'dark',
              color: Color(0xFF0F172A),
            ),
            SeraphineSpacing.mdH,
            _ThemeOption(
              label: 'LIGHT QUARTZ',
              themeValue: 'light',
              color: Color(0xFFF8FAFC),
            ),
          ],
        ),
        SeraphineSpacing.xlV,
        Text(
          'DYNAMIC ACCENT',
          style: SeraphineTypography.label.copyWith(
            fontSize: 10,
            color: colors.textDetail,
            fontWeight: FontWeight.w700,
          ),
        ),
        SeraphineSpacing.mdV,
        _PaletteSelector(),
      ],
    );
  }
}

class _PaletteSelector extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    final palettes = [
      {'id': 'default', 'name': 'COBALT', 'color': const Color(0xFF007AFF)},
      {'id': 'emerald', 'name': 'EMERALD', 'color': const Color(0xFF10B981)},
      {'id': 'rose', 'name': 'ROSE', 'color': const Color(0xFFF43F5E)},
      {'id': 'amber', 'name': 'AMBER', 'color': const Color(0xFFF59E0B)},
    ];

    return Obx(() {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: palettes.map((p) {
          final isSelected =
              controller.colorTheme.value.toLowerCase() == p['id'];
          return InkWell(
            onTap: () => controller.setColorTheme(p['id'] as String),
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: SeraphineMotion.fast,
              curve: SeraphineMotion.smooth,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: ShapeDecoration(
                color: isSelected
                    ? (p['color'] as Color).withValues(alpha: 0.15)
                    : Colors.transparent,
                shape: StadiumBorder(
                  side: BorderSide(
                    color:
                        isSelected ? (p['color'] as Color) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: p['color'] as Color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (p['color'] as Color).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  SeraphineSpacing.smH,
                  Text(
                    p['name'] as String,
                    style: SeraphineTypography.label.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? (p['color'] as Color)
                          : SeraphineColors.of(context).textDetail,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _ThemeOption extends GetView<SettingsController> {
  final String label;
  final String themeValue;
  final Color color;

  const _ThemeOption({
    required this.label,
    required this.themeValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Expanded(
      child: Obx(() {
        final isSelected = controller.themeMode.value == themeValue;
        return InkWell(
          onTap: () => controller.setTheme(themeValue),
          borderRadius: BorderRadius.circular(colors.cardRadius),
          child: AnimatedContainer(
            duration: SeraphineMotion.fast,
            curve: SeraphineMotion.smooth,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: SeraphineShapes.squircle(
                side: BorderSide(
                  color: isSelected
                      ? colors.primary
                      : colors.border.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                SeraphineSpacing.mdH,
                Text(
                  label,
                  style: SeraphineTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? colors.textPrimary : colors.textDetail,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: colors.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
