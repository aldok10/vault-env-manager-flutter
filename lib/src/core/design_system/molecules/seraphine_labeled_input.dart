import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 💎 SeraphineLabeledInput
/// A premium label wrapper for input fields with optimized tracking and typography.
class SeraphineLabeledInput extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;

  const SeraphineLabeledInput({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SeraphineSpacing.xxs,
            bottom: SeraphineSpacing.xxs,
          ),
          child: Row(
            children: [
              Text(
                label.toUpperCase(),
                style: SeraphineTypography.boldTracking.copyWith(
                  fontSize: 10,
                  color: SeraphineColors.of(
                    context,
                  ).textPrimary.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: SeraphineTypography.boldTracking.copyWith(
                    fontSize: 10,
                    color: SeraphineColors.of(context).primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }
}
