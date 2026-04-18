import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_text.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🏢 SeraphineSidebar Organism
/// Side navigation with glassmorphic depth.
class SeraphineSidebar extends StatelessWidget {
  final List<SeraphineSidebarItem> items;
  final Widget? header;
  final Widget? footer;

  const SeraphineSidebar({
    super.key,
    required this.items,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(16),
      child: SeraphineGlassBox(
        cornerRadius: 24,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          children: [
            if (header != null) ...[header!, const SizedBox(height: 32)],
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) => items[index],
              ),
            ),
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ],
        ),
      ),
    );
  }
}

class SeraphineSidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SeraphineSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<SeraphineSidebarItem> createState() => _SeraphineSidebarItemState();
}

class _SeraphineSidebarItemState extends State<SeraphineSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return MouseRegion(
      onEnter: (_) {
        if (_isHovered) return;
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!_isHovered) return;
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SeraphineMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: widget.isSelected
                ? colors.primary.withValues(alpha: 0.15)
                : (_isHovered
                    ? colors.textPrimary.withValues(alpha: 0.05)
                    : Colors.transparent),
            shape: SeraphineShapes.squircle(
              radius: colors.cardRadius,
              side: widget.isSelected
                  ? BorderSide(color: colors.primary, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color:
                    widget.isSelected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SeraphineText(
                  widget.label,
                  style: SeraphineTypography.bodyMedium.copyWith(
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
