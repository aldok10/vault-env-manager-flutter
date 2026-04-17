import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_text.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_color_extension.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

enum SeraphineButtonVariant { glass, solid, outline, ghost }

/// 🧬 SeraphineButton Molecule
/// Interactive, tactile, and weightless.
class SeraphineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final SeraphineButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const SeraphineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = SeraphineButtonVariant.solid,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  factory SeraphineButton.glass({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
  }) => SeraphineButton(
    text: text,
    onPressed: onPressed,
    variant: SeraphineButtonVariant.glass,
    icon: icon,
    isLoading: isLoading,
    width: width,
  );

  factory SeraphineButton.solid({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
  }) => SeraphineButton(
    text: text,
    onPressed: onPressed,
    variant: SeraphineButtonVariant.solid,
    icon: icon,
    isLoading: isLoading,
    width: width,
  );

  factory SeraphineButton.outline({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
  }) => SeraphineButton(
    text: text,
    onPressed: onPressed,
    variant: SeraphineButtonVariant.outline,
    icon: icon,
    isLoading: isLoading,
    width: width,
  );

  factory SeraphineButton.ghost({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
  }) => SeraphineButton(
    text: text,
    onPressed: onPressed,
    variant: SeraphineButtonVariant.ghost,
    icon: icon,
    isLoading: isLoading,
    width: width,
  );

  @override
  State<SeraphineButton> createState() => _SeraphineButtonState();
}

class _SeraphineButtonState extends State<SeraphineButton> {
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);
  final ValueNotifier<bool> _isPressed = ValueNotifier(false);

  @override
  void dispose() {
    _isHovered.dispose();
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: GestureDetector(
        onTapDown: (_) => _isPressed.value = true,
        onTapUp: (_) => _isPressed.value = false,
        onTapCancel: () => _isPressed.value = false,
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_isHovered, _isPressed]),
          builder: (context, child) {
            return AnimatedScale(
              scale: _isPressed.value ? 0.94 : (_isHovered.value ? 1.04 : 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: _buildBody(isDisabled),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(bool isDisabled) {
    final colors = SeraphineColors.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: _getTextColor(isDisabled, colors)),
          const SizedBox(width: 8),
        ],
        SeraphineText(
          widget.text,
          style: SeraphineTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: _getTextColor(isDisabled, colors),
          ),
        ),
      ],
    );

    switch (widget.variant) {
      case SeraphineButtonVariant.glass:
        return SeraphineGlassBox(
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: _isHovered.value
              ? colors.primary.withValues(alpha: 0.15)
              : colors.glassBackground,
          borderColor: _isHovered.value ? colors.primary : colors.glassBorder,
          child: content,
        );
      case SeraphineButtonVariant.solid:
        return AnimatedContainer(
          duration: SeraphineMotion.fast,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: ShapeDecoration(
            color: isDisabled
                ? colors.surfaceHighlight
                : (_isHovered.value
                      ? colors.primary.withValues(alpha: 0.8)
                      : colors.primary),
            shape: SeraphineShapes.squircle(),
            shadows: _isHovered.value && !isDisabled
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: content,
        );
      case SeraphineButtonVariant.outline:
        return AnimatedContainer(
          duration: SeraphineMotion.fast,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: ShapeDecoration(
            color: _isHovered.value
                ? colors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: SeraphineShapes.squircle(
              side: BorderSide(
                color: _isHovered.value ? colors.primary : colors.border,
                width: 1.5,
              ),
            ),
          ),
          child: content,
        );
      case SeraphineButtonVariant.ghost:
        return Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered.value
                ? colors.surfaceHighlight.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(SeraphineShapes.baseRadius),
          ),
          child: content,
        );
    }
  }

  Color _getTextColor(bool isDisabled, SeraphineColorExtension colors) {
    if (isDisabled) { return colors.textDetail; }
    if (widget.variant == SeraphineButtonVariant.solid) { return Colors.white; }
    if (widget.variant == SeraphineButtonVariant.outline && _isHovered.value) { return colors.primary; }
    return colors.textPrimary;
  }
}
