import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/auth/presentation/controllers/auth_controller.dart';

class AuthIcon extends StatelessWidget {
  const AuthIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SeraphineColors.of(context).primary,
            SeraphineColors.of(context).accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: SeraphineSpacing.radiusLG,
        boxShadow: [
          BoxShadow(
            color: SeraphineColors.of(context).primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Center(
        child:
            const Icon(CupertinoIcons.lock_fill, size: 44, color: Colors.white)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -2,
                  end: 2,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),
      ),
    ).animate().shimmer(
      delay: const Duration(seconds: 1),
      duration: const Duration(seconds: 2),
    );
  }
}

class AuthHeader extends GetView<AuthController> {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Vault Env Manager',
          style: SeraphineTypography.h1.copyWith(fontSize: 28),
        ),
        SeraphineSpacing.xsV,
        Obx(
          () => Text(
            controller.isNew
                ? 'SERAPHINE CLOUD SETUP'
                : 'ENTER CREDENTIALS TO CONTINUE',
            style: SeraphineTypography.label.copyWith(
              color: SeraphineColors.of(context).textSecondary,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1.5,
          width: 32,
          decoration: BoxDecoration(
            color: SeraphineColors.of(context).border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SeraphineSpacing.mdV,
        Text(
          'SERAPHINE SECURE PROTOCOL V4.0\nAES-256 GCM ENCRYPTION',
          textAlign: TextAlign.center,
          style: SeraphineTypography.label.copyWith(
            fontSize: 9,
            color: SeraphineColors.of(context).textDetail,
            height: 1.8,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
