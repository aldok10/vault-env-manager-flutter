import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';

/// 🧬 SeraphineCard Molecule
/// Floating, spatial, and premium.
class SeraphineCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isInteractive;
  final bool showTilt;
  final VoidCallback? onTap;

  const SeraphineCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.isInteractive = true,
    this.showTilt = true,
    this.onTap,
  });

  @override
  State<SeraphineCard> createState() => _SeraphineCardState();
}

class _SeraphineCardState extends State<SeraphineCard> {
  bool _isHovered = false;
  double _tiltX = 0;
  double _tiltY = 0;

  void _onHover(PointerEvent event) {
    if (!widget.showTilt) return;
    final size = context.size!;
    final center = Offset(size.width / 2, size.height / 2);
    final pos = event.localPosition;

    // Calculate normalized tilt (-1.0 to 1.0)
    setState(() {
      _tiltX = (pos.dy - center.dy) / center.dy;
      _tiltY = (center.dx - pos.dx) / center.dx;
      _isHovered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(_isHovered ? _tiltX * 0.1 : 0) // Subtle tilt
      ..rotateY(_isHovered ? _tiltY * 0.1 : 0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _tiltX = 0;
        _tiltY = 0;
      }),
      onHover: _onHover,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SeraphineMotion.fast,
          curve: Curves.easeOut,
          transformAlignment: FractionalOffset.center,
          transform: matrix,
          child: SeraphineGlassBox(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            color: _isHovered && widget.isInteractive
                ? colors.surfaceHighlight.withValues(alpha: 0.4)
                : colors.glassBackground,
            shadow: _isHovered
                ? SeraphineColors.floatingShadow
                : SeraphineColors.softShadow,
            borderColor: _isHovered && widget.isInteractive
                ? colors.primary.withValues(alpha: 0.3)
                : colors.glassBorder,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
