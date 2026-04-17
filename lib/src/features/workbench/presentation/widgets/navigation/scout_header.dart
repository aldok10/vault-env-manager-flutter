import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

class ScoutHeader extends StatelessWidget {
  const ScoutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SeraphineSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SeraphineColors.of(context).primary,
                  SeraphineColors.of(context).accent,
                ],
              ),
              shape: SeraphineShapes.squircle(radius: 12),
              shadows: [
                BoxShadow(
                  color: SeraphineColors.of(
                    context,
                  ).primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.antenna_radiowaves_left_right,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: SeraphineSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VAULT ASSISTANT',
                style: SeraphineTypography.h4.copyWith(
                  fontSize: 13,
                  letterSpacing: 1.2,
                  color: SeraphineColors.of(context).textPrimary,
                ),
              ),
              Text(
                'INFRASTRUCTURE SCOUT',
                style: SeraphineTypography.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: SeraphineColors.of(context).textDetail,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.back(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SeraphineColors.of(
              context,
            ).textPrimary.withValues(alpha: 0.05),
          ),
          child: Icon(
            CupertinoIcons.xmark,
            size: 16,
            color: SeraphineColors.of(context).textDetail,
          ),
        ),
      ),
    );
  }
}
