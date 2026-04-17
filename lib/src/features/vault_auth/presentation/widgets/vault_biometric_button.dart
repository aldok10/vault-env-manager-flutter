import 'package:flutter/cupertino.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';

class VaultBiometricButton extends StatefulWidget {
  final VoidCallback onPressed;

  const VaultBiometricButton({super.key, required this.onPressed});

  @override
  State<VaultBiometricButton> createState() => _VaultBiometricButtonState();
}

class _VaultBiometricButtonState extends State<VaultBiometricButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : (_isHovered ? 1.05 : 1.0),
          duration: SeraphineMotion.fast,
          curve: SeraphineMotion.smooth,
          child: AnimatedContainer(
            duration: SeraphineMotion.fast,
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: _isHovered
                  ? colors.primary.withValues(alpha: 0.15)
                  : colors.background.withValues(alpha: 0.4),
              shape: SeraphineShapes.squircle(
                radius: 16,
                side: BorderSide(
                  color: _isHovered
                      ? colors.primary
                      : colors.border.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              shadows: _isHovered
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              CupertinoIcons.viewfinder_circle_fill,
              color: _isHovered ? colors.primary : colors.textPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
