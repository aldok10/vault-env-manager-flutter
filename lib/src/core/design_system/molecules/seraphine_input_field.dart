import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🧬 SeraphineInputField Molecule
/// Glassmorphic, focused, and secure.
class SeraphineInputField extends StatefulWidget {
  final bool isDense;
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final bool autofocus;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const SeraphineInputField({
    super.key,
    this.isDense = false,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.autofocus = false,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<SeraphineInputField> createState() => _SeraphineInputFieldState();
}

class _SeraphineInputFieldState extends State<SeraphineInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void didUpdateWidget(SeraphineInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!.toUpperCase(),
              style: SeraphineTypography.label.copyWith(
                fontSize: 10,
                letterSpacing: 1.2,
                color: _isFocused ? colors.primary : colors.textDetail,
              ),
            ),
          ),
        AnimatedContainer(
          duration: SeraphineMotion.fast,
          curve: SeraphineMotion.smooth,
          decoration: ShapeDecoration(
            color: _isFocused
                ? colors.background.withValues(alpha: 0.8)
                : colors.inputBg.withValues(alpha: 0.4),
            shape: SeraphineShapes.squircle(
              radius: colors.cardRadius,
              side: BorderSide(
                color: _isFocused
                    ? colors.primary
                    : colors.border.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            shadows: _isFocused
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            cursorColor: colors.primary,
            style: (widget.isDense
                    ? SeraphineTypography.caption.copyWith(fontSize: 12)
                    : SeraphineTypography.bodySmall)
                .copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: (widget.isDense
                      ? SeraphineTypography.caption.copyWith(fontSize: 12)
                      : SeraphineTypography.bodySmall)
                  .copyWith(
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: widget.isDense ? 14 : 18,
                      color: _isFocused ? colors.primary : colors.textDetail,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onSuffixTap,
                        child: Icon(
                          widget.suffixIcon,
                          size: widget.isDense ? 14 : 18,
                          color:
                              _isFocused ? colors.primary : colors.textDetail,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.isDense ? 6 : 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
