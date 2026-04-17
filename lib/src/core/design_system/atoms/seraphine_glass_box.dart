import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';

/// ⚛️ SeraphineGlassBox Atom
/// The structural foundation for "Weightless" UI.
class SeraphineGlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? blur;
  final double? cornerRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadow;

  const SeraphineGlassBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.blur,
    this.cornerRadius,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final style = SeraphineColors.of(context);
    final effectiveBlur = blur ?? style.glassBlur;
    final effectiveRadius = cornerRadius ?? style.cardRadius;
    final isFlat = style.designStyle == 'flat';
    final isNeumorphic = style.designStyle == 'neumorphic';

    final effectiveColor =
        color ??
        style.surface.withValues(alpha: isFlat ? 1.0 : style.glassOpacity);
    final effectiveBorder = borderColor ?? style.border;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow:
            shadow ??
            (isNeumorphic
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(-4, -4),
                    ),
                  ]
                : SeraphineColors.softShadow),
      ),
      child: ClipPath(
        clipper: _SquircleClipper(cornerRadius: effectiveRadius),
        child: effectiveBlur > 0 && !isFlat
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: _buildInnerContainer(
                  effectiveRadius,
                  effectiveColor,
                  effectiveBorder,
                  isFlat,
                ),
              )
            : _buildInnerContainer(
                effectiveRadius,
                effectiveColor,
                effectiveBorder,
                isFlat,
              ),
      ),
    );
  }

  Widget _buildInnerContainer(
    double radius,
    Color color,
    Color borderColor,
    bool isFlat,
  ) {
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: color,
        shape: SeraphineShapes.squircle(
          radius: radius,
          side: isFlat ? BorderSide(color: borderColor) : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

class _SquircleClipper extends CustomClipper<Path> {
  final double cornerRadius;
  _SquircleClipper({required this.cornerRadius});

  @override
  Path getClip(Size size) {
    return SeraphineShapes.squircle(
      radius: cornerRadius,
    ).getOuterPath(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant _SquircleClipper oldClipper) =>
      oldClipper.cornerRadius != cornerRadius;
}
