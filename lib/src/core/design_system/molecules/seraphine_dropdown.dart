import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🧬 SeraphineDropdown Molecule
/// A high-fidelity, glassmorphism-enhanced dropdown for 2026.
/// Aligned with HyperOS 3 and Samsung One UI 6 aesthetics.
class SeraphineDropdown<T> extends StatefulWidget {
  final String? label;
  final Rx<T> value;
  final List<T> items;
  final bool isUppercase;
  final String Function(T)? itemLabelBuilder;
  final ValueChanged<T?>? onChanged;
  final bool isDense;

  const SeraphineDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    this.isUppercase = false,
    this.itemLabelBuilder,
    this.onChanged,
    this.isDense = false,
    this.prefixIcon,
  });

  final IconData? prefixIcon;

  @override
  State<SeraphineDropdown<T>> createState() => _SeraphineDropdownState<T>();
}

class _SeraphineDropdownState<T> extends State<SeraphineDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool _isHovered = false;
  bool _isOpen = false;

  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: SeraphineMotion.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: SeraphineMotion.smooth),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _pressController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_isOpen) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_isOpen) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _hideOverlay() async {
    if (!_isOpen) return;
    // The menu component handles its own exit animation via a call forward
    // but for simplicity here we just trigger the state change
    setState(() => _isOpen = false);
    // Entry removal happens after a short delay to allow animation if handled by the child
    // In this premium version, the _SeraphineDropdownMenu handles the removal callback
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => _SeraphineDropdownOverlay<T>(
        layerLink: _layerLink,
        size: size,
        items: widget.items,
        selectedValue: widget.value.value,
        itemLabelBuilder: widget.itemLabelBuilder,
        isUppercase: widget.isUppercase,
        onSelected: (newValue) {
          widget.value.value = newValue;
          widget.onChanged?.call(newValue);
          _hideOverlay();
        },
        onDismiss: _hideOverlay,
        onRemoved: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          if (mounted) setState(() => _isOpen = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.isDense && widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              widget.label!.toUpperCase(),
              style: SeraphineTypography.label.copyWith(
                fontSize: 10,
                letterSpacing: 1.5,
                color: _isOpen || _isHovered
                    ? SeraphineColors.of(context).primary
                    : colors.textDetail,
              ),
            ),
          ),
        CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTapDown: (_) => _pressController.forward(),
              onTapUp: (_) => _pressController.reverse(),
              onTapCancel: () => _pressController.reverse(),
              onTap: _toggleOverlay,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: SeraphineMotion.fast,
                  curve: SeraphineMotion.smooth,
                  decoration: ShapeDecoration(
                    color: _isOpen || _isHovered
                        ? colors.surfaceHighlight.withValues(alpha: 0.8)
                        : colors.inputBg.withValues(alpha: 0.6),
                    shape: SeraphineShapes.squircle(
                      radius: colors.cardRadius,
                      side: BorderSide(
                        color: _isOpen || _isHovered
                            ? SeraphineColors.of(
                                context,
                              ).primary.withValues(alpha: 0.5)
                            : colors.border.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    shadows: _isOpen || _isHovered
                        ? [
                            BoxShadow(
                              color: SeraphineColors.of(context).primaryGlow.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: widget.isDense ? 6 : 10,
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          size: 14,
                          color: SeraphineColors.of(context).primary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Obx(
                          () => Text(
                            widget.itemLabelBuilder?.call(widget.value.value) ??
                                widget.value.value.toString(),
                            style:
                                (widget.isDense
                                        ? SeraphineTypography.caption.copyWith(
                                            fontSize: 12,
                                          )
                                        : SeraphineTypography.bodySmall)
                                    .copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: widget.isUppercase
                                          ? 1.0
                                          : 0.0,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        duration: SeraphineMotion.fast,
                        turns: _isOpen ? 0.5 : 0,
                        child: Icon(
                          CupertinoIcons.chevron_down,
                          size: 14,
                          color: _isOpen || _isHovered
                              ? SeraphineColors.of(context).primary
                              : colors.textDetail,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎨 _SeraphineDropdownOverlay Core Overlay Management Widget
class _SeraphineDropdownOverlay<T> extends StatefulWidget {
  final LayerLink layerLink;
  final Size size;
  final List<T> items;
  final T selectedValue;
  final String Function(T)? itemLabelBuilder;
  final bool isUppercase;
  final ValueChanged<T> onSelected;
  final VoidCallback onDismiss;
  final VoidCallback onRemoved;

  const _SeraphineDropdownOverlay({
    required this.layerLink,
    required this.size,
    required this.items,
    required this.selectedValue,
    this.itemLabelBuilder,
    required this.isUppercase,
    required this.onSelected,
    required this.onDismiss,
    required this.onRemoved,
  });

  @override
  State<_SeraphineDropdownOverlay<T>> createState() =>
      _SeraphineDropdownOverlayState<T>();
}

class _SeraphineDropdownOverlayState<T>
    extends State<_SeraphineDropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: SeraphineMotion.fast,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: SeraphineMotion.smooth,
      ),
    );
    _slideAnimation = Tween<double>(begin: -10, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: SeraphineMotion.smooth,
      ),
    );
    _animationController.forward();
  }

  void _close() async {
    await _animationController.reverse();
    widget.onRemoved();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: Container(color: Colors.transparent),
          ),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, widget.size.height + 8),
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                width: widget.size.width,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: ShapeDecoration(
                  color: colors.glassBackground, // Using theme extension
                  shape: SeraphineShapes.squircle(
                    radius: SeraphineShapes.baseRadius,
                    side: BorderSide(
                      color: colors.glassBorder, // Using theme extension
                      width: 1.0,
                    ),
                  ),
                  shadows: SeraphineColors.floatingShadow,
                ),
                child: ClipPath(
                  clipper: ShapeBorderClipper(
                    shape: SeraphineShapes.squircle(),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: SeraphineColors.of(context).glassBlur,
                      sigmaY: SeraphineColors.of(context).glassBlur,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.items.map((item) {
                          final label =
                              widget.itemLabelBuilder?.call(item) ??
                              item.toString();
                          final isSelected = widget.selectedValue == item;

                          return _SeraphineDropdownItem(
                            label: widget.isUppercase
                                ? label.toUpperCase()
                                : label,
                            isSelected: isSelected,
                            onTap: () {
                              widget.onSelected(item);
                              _close();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// 🧼 _SeraphineDropdownItem Internal Component
class _SeraphineDropdownItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeraphineDropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SeraphineDropdownItem> createState() => _SeraphineDropdownItemState();
}

class _SeraphineDropdownItemState extends State<_SeraphineDropdownItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SeraphineMotion.fast,
          curve: SeraphineMotion.smooth,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: ShapeDecoration(
            color: widget.isSelected
                ? SeraphineColors.of(context).primary.withValues(alpha: 0.15)
                : (_isHovered ? colors.surfaceHighlight : Colors.transparent),
            shape: SeraphineShapes.squircle(
              radius: colors.cardRadius - 2, // Slightly smaller for internal items
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style:
                      (widget.isSelected
                              ? (SeraphineTypography.caption.copyWith(
                                  fontSize: 12,
                                )).copyWith(fontWeight: FontWeight.bold)
                              : SeraphineTypography.caption.copyWith(
                                  fontSize: 12,
                                ))
                          .copyWith(
                            color: widget.isSelected
                                ? SeraphineColors.of(context).primary
                                : colors.textPrimary,
                          ),
                ),
              ),
              if (widget.isSelected)
                Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 16,
                  color: SeraphineColors.of(context).primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
