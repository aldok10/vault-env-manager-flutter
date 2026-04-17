import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_card.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 💎 SeraphineUI Workbench Widget
/// A high-fidelity container for workbench tools with Liquid Glass effects.
class SeraphineWorkbenchWidget extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final Widget? persistentChild;
  final Widget? action;
  final Widget? headerTrailing;
  final double? width;
  final double? height;
  final bool isExpandable;
  final bool isCollapsible;
  final bool initialCollapsed;

  const SeraphineWorkbenchWidget({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.persistentChild,
    this.action,
    this.headerTrailing,
    this.width,
    this.height,
    this.isExpandable = false,
    this.isCollapsible = false,
    this.initialCollapsed = false,
  });

  @override
  State<SeraphineWorkbenchWidget> createState() =>
      _SeraphineWorkbenchWidgetState();
}

class _SeraphineWorkbenchWidgetState extends State<SeraphineWorkbenchWidget>
    with SingleTickerProviderStateMixin {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initialCollapsed;
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionWidget = widget.action;
    final colors = SeraphineColors.of(context);

    return SeraphineGlassCard(
      width: widget.width,
      height: _isCollapsed ? null : widget.height,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Header
          InkWell(
            onTap: widget.isCollapsible ? _toggleCollapse : null,
            borderRadius: _isCollapsed
                ? BorderRadius.circular(colors.cardRadius)
                : BorderRadius.vertical(
                    top: Radius.circular(colors.cardRadius),
                  ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: colors.primary),
                    SeraphineSpacing.mdH,
                  ],
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            widget.title.toUpperCase(),
                            style: SeraphineTypography.label.copyWith(
                              color: colors.textPrimary.withValues(alpha: 0.7),
                              fontSize: 10,
                              letterSpacing: 2.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (widget.headerTrailing != null) ...[
                          const Spacer(),
                          Flexible(child: widget.headerTrailing!),
                        ],
                      ],
                    ),
                  ),
                  if (widget.headerTrailing == null) const Spacer(),
                  if (actionWidget != null && !_isCollapsed) actionWidget,
                  if (widget.isCollapsible) ...[
                    SeraphineSpacing.smH,
                    Icon(
                      _isCollapsed
                          ? CupertinoIcons.chevron_down
                          : CupertinoIcons.chevron_up,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Content
          if (!_isCollapsed) ...[
            // Subtle Refractive Divider
            Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.glassBorder.withValues(alpha: 0.0),
                    colors.glassBorder.withValues(alpha: 0.3),
                    colors.glassBorder.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),

            // Widget Content
            if (widget.isExpandable)
              Expanded(child: widget.child)
            else
              widget.child,
          ],

          // Persistent Content (Visible even when collapsed)
          if (widget.persistentChild != null) ...[
            // Divider
            Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.glassBorder.withValues(alpha: 0.0),
                    colors.glassBorder.withValues(alpha: 0.2),
                    colors.glassBorder.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            widget.persistentChild!,
          ],
        ],
      ),
    );
  }
}
