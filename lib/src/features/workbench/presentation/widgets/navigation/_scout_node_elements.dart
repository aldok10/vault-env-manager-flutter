import 'package:flutter/cupertino.dart';
// Unnecessary material import removed
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/models/ui_node.dart';

class ScoutNodeBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const ScoutNodeBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 6.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: SeraphineTypography.boldTracking.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class ScoutVersionBadge extends StatelessWidget {
  final int version;

  const ScoutVersionBadge({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: SeraphineColors.of(context).primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: SeraphineColors.of(context).primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'V$version',
        style: SeraphineTypography.boldTracking.copyWith(
          fontSize: 6.5,
          color: SeraphineColors.of(context).primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class ScoutNodeIcon extends StatelessWidget {
  final UiNode node;
  final bool isSelected;
  final bool isCollapsed;
  final bool hasSubKeys;
  final Color envColor;

  const ScoutNodeIcon({
    super.key,
    required this.node,
    required this.isSelected,
    required this.isCollapsed,
    required this.hasSubKeys,
    required this.envColor,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    if (node.isFolder) {
      icon = isCollapsed
          ? CupertinoIcons.folder_fill
          : CupertinoIcons.folder_open;
    } else if (hasSubKeys && !isCollapsed) {
      icon = CupertinoIcons.archivebox_fill;
    } else {
      icon = isSelected
          ? CupertinoIcons.checkmark_seal_fill
          : CupertinoIcons.doc_fill;
    }

    return Icon(
      icon,
      size: 14,
      color: isSelected
          ? SeraphineColors.of(context).primary
          : (node.isFolder
                ? SeraphineColors.of(context).primary
                : envColor.withValues(alpha: 0.8)),
    );
  }
}
