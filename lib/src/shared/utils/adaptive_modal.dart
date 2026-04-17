import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_breakpoints.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 📱 AdaptiveModal
/// Refined for 2026 Liquid Glass ergonomics.
abstract class AdaptiveModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    // Note: context.isMobile is a GetX extension
    if (context.isMobile) {
      return Get.bottomSheet<T>(
        Container(
          decoration: ShapeDecoration(
            color: SeraphineColors.of(context).surface,
            shape: SeraphineShapes.squircle(
              radius: 32,
              side: BorderSide(
                color: SeraphineColors.of(context).glassBorder,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SeraphineColors.of(
                    context,
                  ).textDetail.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Text(
                    title.toUpperCase(),
                    style: SeraphineTypography.label.copyWith(
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              Flexible(child: child),
              const SizedBox(height: 32),
            ],
          ),
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enterBottomSheetDuration: const Duration(milliseconds: 400),
      );
    } else {
      return Get.dialog<T>(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 840),
            child: child,
          ),
        ),
        transitionCurve: Curves.easeOutQuart,
      );
    }
  }
}
