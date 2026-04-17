import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';

/// ⚛️ SeraphineBackground Atom
/// Premium cosmic mesh gradient background for the SeraphineUI system.
class SeraphineBackground extends StatelessWidget {
  const SeraphineBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Deep Space
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.background,
                  isDark ? const Color(0xFF020408) : const Color(0xFFF1F5F9),
                ],
              ),
            ),
          ),
        ),

        // Deep Hyper Blue Glow (Top Left)
        _MeshBlob(
          color: colors.primary.withValues(alpha: 0.15),
          size: 800,
          alignment: const Alignment(-1.2, -1.2),
        ),

        // Subtle Cyan Glow (Bottom Right)
        _MeshBlob(
          color: colors.accent.withValues(alpha: 0.08),
          size: 600,
          alignment: const Alignment(1.2, 1.2),
        ),

        // Floating Surface Glow (Center)
        _MeshBlob(
          color: colors.syntaxFunction.withValues(alpha: 0.05),
          size: 1000,
          alignment: const Alignment(0, 0.5),
        ),

        // Noise Texture (Subtle Grain)
        Positioned.fill(
          child: Opacity(
            opacity: 0.015,
            child: Image.asset(
              'assets/textures/grain.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MeshBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;

  const _MeshBlob({
    required this.color,
    required this.size,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 0.8],
          ),
        ),
      ),
    );
  }
}
