import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';

/// 💎 SeraphineGlassCard Atom (2026 Edition)
/// Features "Refractive Prism" borders and "Liquid Glass" physics.
class SeraphineGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? blur;
  final double? cornerRadius;
  final bool isHoverable;
  final VoidCallback? onTap;

  const SeraphineGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.blur,
    this.cornerRadius,
    this.isHoverable = true,
    this.onTap,
  });

  @override
  State<SeraphineGlassCard> createState() => _SeraphineGlassCardState();
}

class _SeraphineGlassCardState extends State<SeraphineGlassCard>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);
  final ValueNotifier<Offset> _mousePositionNotifier = ValueNotifier(
    Offset.zero,
  );
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: SeraphineMotion.medium,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: SeraphineMotion.standardCurve,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _mousePositionNotifier.dispose();
    _isHovered.dispose();
    super.dispose();
  }

  void _onHover(bool hovering, [Offset? position]) {
    if (!widget.isHoverable) return;

    // 🛡️ State Guard: Only trigger update if state actually changed
    if (_isHovered.value != hovering) {
      _isHovered.value = hovering;
      if (hovering) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }

    if (position != null) {
      _mousePositionNotifier.value = position;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = SeraphineColors.of(context);
    final effectiveBlur = widget.blur ?? style.glassBlur;
    final effectiveRadius = widget.cornerRadius ?? style.cardRadius;
    final isFlat = style.designStyle == 'flat';
    final isNeumorphic = style.designStyle == 'neumorphic';

    return MouseRegion(
      onEnter: (event) => _onHover(true, event.localPosition),
      onExit: (_) => _onHover(false),
      onHover: (event) => _mousePositionNotifier.value = event.localPosition,
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_glowAnimation, _isHovered]),
          builder: (context, child) {
            final colors = SeraphineColors.of(context);

            // Generate shadows based on OS style
            List<BoxShadow> currentShadows;
            if (isNeumorphic) {
              currentShadows = [
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
              ];
            } else if (_isHovered.value) {
              currentShadows = SeraphineColors.floatingShadow;
            } else {
              currentShadows = [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: isFlat ? 4 : 40,
                  offset: Offset(0, isFlat ? 2 : 10),
                ),
              ];
            }

            Widget cardContent = Container(
              padding: widget.padding,
              decoration: ShapeDecoration(
                color: _isHovered.value
                    ? colors.surfaceHighlight.withValues(
                        alpha: isFlat ? 1.0 : (style.glassOpacity * 2),
                      )
                    : colors.surface.withValues(
                        alpha: isFlat ? 1.0 : style.glassOpacity,
                      ),
                shape: SeraphineShapes.squircle(
                  radius: effectiveRadius,
                  side: isFlat
                      ? BorderSide(color: colors.border)
                      : BorderSide.none,
                ),
              ),
              child: widget.child,
            );

            // Add Refractive Border for Glass/HyperOS (High Fidelity)
            if (!isFlat) {
              cardContent = Stack(
                children: [
                  cardContent,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _glowAnimation,
                            _mousePositionNotifier,
                          ]),
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _RefractiveBorderPainter(
                                radius: effectiveRadius,
                                glowIntensity: _glowAnimation.value,
                                mousePosition: _mousePositionNotifier.value,
                                primaryColor: colors.primary,
                                accentColor: colors.accent,
                                themeBorderColor: colors.border,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Apply Blur if supported by style
            if (effectiveBlur > 0 && !isFlat) {
              cardContent = ClipPath(
                clipper: _SeraphineSquircleClipper(
                  cornerRadius: effectiveRadius,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: effectiveBlur,
                    sigmaY: effectiveBlur,
                  ),
                  child: cardContent,
                ),
              );
            }

            return Container(
              width: widget.width,
              height: widget.height,
              decoration: ShapeDecoration(
                shape: SeraphineShapes.squircle(radius: effectiveRadius),
                shadows: currentShadows,
              ),
              child: cardContent,
            );
          },
        ),
      ),
    );
  }
}

class _RefractiveBorderPainter extends CustomPainter {
  final double radius;
  final double glowIntensity;
  final Offset mousePosition;
  final Color primaryColor;
  final Color accentColor;
  final Color themeBorderColor;

  _RefractiveBorderPainter({
    required this.radius,
    required this.glowIntensity,
    required this.mousePosition,
    required this.primaryColor,
    required this.accentColor,
    required this.themeBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = SeraphineShapes.squircle(radius: radius);
    final path = shape.getOuterPath(rect);

    // 1. Base Thin Border
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = themeBorderColor.withValues(alpha: 0.1 + (0.2 * glowIntensity));
    canvas.drawPath(path, basePaint);

    if (glowIntensity > 0) {
      // 2. Specular Highlight (Mouse Reactive) - Softer Glow
      final specularPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * glowIntensity
        ..shader = RadialGradient(
          center: Alignment(
            (mousePosition.dx / size.width) * 2 - 1,
            (mousePosition.dy / size.height) * 2 - 1,
          ),
          radius: 0.5,
          colors: [
            primaryColor.withValues(alpha: 0.2 * glowIntensity),
            primaryColor.withValues(alpha: 0.0),
          ],
        ).createShader(rect);

      canvas.drawPath(path, specularPaint);

      // 3. Alive Glow (Internal Edge Lighting)
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * glowIntensity
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4.0)
        ..color = primaryColor.withValues(alpha: 0.3 * glowIntensity);

      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RefractiveBorderPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity ||
      oldDelegate.mousePosition != mousePosition;
}

class _SeraphineSquircleClipper extends CustomClipper<Path> {
  final double cornerRadius;
  _SeraphineSquircleClipper({required this.cornerRadius});

  @override
  Path getClip(Size size) {
    return SeraphineShapes.squircle(
      radius: cornerRadius,
    ).getOuterPath(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant _SeraphineSquircleClipper oldClipper) =>
      oldClipper.cornerRadius != cornerRadius;
}
