import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_card.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 💊 SeraphineNowBar Molecule (2026 Edition)
/// An intelligent "Liquid Pill" status indicator that floats above the background.
class SeraphineNowBar extends StatelessWidget {
  final String status;
  final String? profileName;
  final IconData? icon;
  final List<Widget>? actions;

  const SeraphineNowBar({
    super.key,
    required this.status,
    this.profileName,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SeraphineGlassCard(
      cornerRadius: 100, // Pill shape
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      blur: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Adaptive Glow Indicator
          Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SeraphineColors.of(context).primary,
                  boxShadow: [
                    BoxShadow(
                      color: SeraphineColors.of(
                        context,
                      ).primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: const Duration(seconds: 2),
                color: Colors.white.withValues(alpha: 0.5),
              ),

          SeraphineSpacing.smH,

          // Identity Section
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.toUpperCase(),
                style: SeraphineTypography.label.copyWith(
                  fontSize: 8,
                  letterSpacing: 1.5,
                  color: SeraphineColors.of(context).textDetail,
                ),
              ),
              if (profileName != null)
                Text(
                  profileName!,
                  style: SeraphineTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          if (actions != null && actions!.isNotEmpty) ...[
            SeraphineSpacing.mdH,
            Container(height: 16, width: 1, color: SeraphineColors.of(context).divider),
            SeraphineSpacing.mdH,
            ...actions!,
          ],
        ],
      ),
    );
  }
}
