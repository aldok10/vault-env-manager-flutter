import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🧬 SeraphineEditorHeader Molecule
/// A glassmorphic header for editor panes.
class SeraphineEditorHeader extends StatelessWidget {
  final String label;
  final Color dotColor;
  final RxString stats;
  final VoidCallback onClear;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onSwap;

  const SeraphineEditorHeader({
    super.key,
    required this.label,
    required this.dotColor,
    required this.stats,
    required this.onClear,
    required this.onCopy,
    required this.onPaste,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(colors.cardRadius),
        ),
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 380;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Label & Indicator
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Animate(
                      onPlay: (c) => c.repeat(reverse: true),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.3, 1.3),
                      duration: const Duration(seconds: 1),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: SeraphineTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Stats (Optional)
              if (!isNarrow) ...[
                const SizedBox(width: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      stats.value,
                      style: SeraphineTypography.caption.copyWith(
                        fontSize: 9,
                        color: colors.textDetail,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // 3. Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderAction(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    onTap: onSwap,
                    tooltip: 'Swap',
                  ),
                  _HeaderAction(
                    icon: CupertinoIcons.doc_on_doc,
                    onTap: onCopy,
                    tooltip: 'Copy',
                  ),
                  _HeaderAction(
                    icon: CupertinoIcons.doc_on_clipboard,
                    onTap: onPaste,
                    tooltip: 'Paste',
                  ),
                  _HeaderAction(
                    icon: CupertinoIcons.trash,
                    onTap: onClear,
                    tooltip: 'Clear',
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isDestructive;

  const _HeaderAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(
        icon,
        size: 16,
        color: isDestructive
            ? colors.error.withValues(alpha: 0.8)
            : colors.textSecondary,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 16,
    );
  }
}
