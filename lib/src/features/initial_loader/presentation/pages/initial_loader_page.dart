import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/initial_loader/presentation/controllers/initial_loader_controller.dart';

/// 🚀 InitialLoaderPage
/// First-contact experience reimagined with 2026 Liquid Glass optics.
class InitialLoaderPage extends GetView<InitialLoaderController> {
  const InitialLoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // 💎 Background Refractive Glow
          Positioned(
            top: -200,
            left: -200,
            child:
                Container(
                      width: 600,
                      height: 600,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeOut(
                      duration: const Duration(seconds: 4),
                      curve: Curves.easeInOut,
                    ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🛡️ Seraphine "Secure Core" Shield
                Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(32),
                      decoration: ShapeDecoration(
                        shape: SeraphineShapes.squircle(
                          radius: 36,
                          side: BorderSide(
                            color: colors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        color: colors.surface.withValues(alpha: 0.5),
                        shadows: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 60,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [colors.primary, colors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Icon(
                          CupertinoIcons.shield_fill,
                          size: 76,
                          color: Colors.white,
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: -8,
                      end: 8,
                      duration: const Duration(seconds: 3),
                      curve: Curves.easeInOut,
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: const Duration(seconds: 3),
                    ),

                const SizedBox(height: 80),

                // 🏛️ Branding
                Text(
                      'VAULT WORKBENCH',
                      style: SeraphineTypography.label.copyWith(
                        color: colors.primary,
                        fontSize: 16,
                        letterSpacing: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: SeraphineMotion.slow)
                    .shimmer(
                      delay: const Duration(seconds: 1),
                      duration: const Duration(seconds: 3),
                    ),

                const SizedBox(height: 48),

                // 🔄 Real-time Status Engine
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      Obx(
                        () => Text(
                          controller.status.value.toUpperCase(),
                          style: SeraphineTypography.caption.copyWith(
                            color: colors.textSecondary,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 16),
                      // Adaptive Progress Bar (Liquid Glass)
                      Container(
                        height: 2,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.divider.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: Stack(
                          children: [
                            Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [colors.primary, colors.accent],
                                    ),
                                  ),
                                )
                                .animate(onPlay: (c) => c.repeat())
                                .moveX(
                                  begin: -80,
                                  end: 280,
                                  duration: const Duration(milliseconds: 2000),
                                  curve: Curves.easeInOutCubic,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📡 Foundation ID at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SERAPHINE SYSTEM KERNEL // 2026.4',
                style: SeraphineTypography.caption.copyWith(
                  color: colors.textDetail,
                  fontSize: 10,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ).animate().fadeIn(delay: const Duration(seconds: 1)),
        ],
      ),
    );
  }
}
