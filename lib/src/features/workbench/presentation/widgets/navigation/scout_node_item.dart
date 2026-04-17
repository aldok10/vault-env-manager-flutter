import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/models/ui_node.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/_scout_node_elements.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_subkey_item.dart';

class ScoutNodeItem extends GetView<DiscoveryController> {
  final UiNode node;
  final int index;
  final double indentSize = 18.0;

  const ScoutNodeItem({super.key, required this.node, required this.index});

  @override
  Widget build(BuildContext context) {
    final int depth =
        node.fullPath.split('/').where((s) => s.isNotEmpty).length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            _buildHierarchyLine(context, depth),
            _buildNodeContent(context, depth),
          ],
        ),
        _buildSubKeys(depth),
      ],
    );
  }

  Widget _buildHierarchyLine(BuildContext context, int depth) {
    if (depth <= 0) return const SizedBox();
    return Positioned(
      left: (depth - 0.5) * indentSize,
      top: 0,
      bottom: 0,
      child: Container(
        width: 0.5,
        color: SeraphineColors.of(context).border.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _buildNodeContent(BuildContext context, int depth) {
    return Obx(() {
      final isCollapsed = controller.collapsedPaths.contains(node.fullPath);
      final hasSubKeys = node.subKeys != null && node.subKeys!.isNotEmpty;
      final bool isSelected =
          !node.isFolder &&
          (!hasSubKeys || isCollapsed) &&
          controller.selectedPath == node.fullPath;

      final Color envColor = _getEnvColor(context, node.environment);

      return Padding(
        padding: EdgeInsets.only(left: depth * indentSize, bottom: 4),
        child: InkWell(
          onTap: () => controller.selectNode(node),
          borderRadius: SeraphineSpacing.radiusSM,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: _buildDecoration(
              context,
              isSelected,
              isCollapsed,
              hasSubKeys,
            ),
            child: Row(
              children: [
                ScoutNodeIcon(
                  node: node,
                  isSelected: isSelected,
                  isCollapsed: isCollapsed,
                  hasSubKeys: hasSubKeys,
                  envColor: envColor,
                ),
                SeraphineSpacing.smH,
                _buildNodeText(context, envColor),
                _buildTrailingIcon(
                  context,
                  isCollapsed,
                  hasSubKeys,
                  isSelected,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 250.ms);
    });
  }

  BoxDecoration _buildDecoration(
    BuildContext context,
    bool isSelected,
    bool isCollapsed,
    bool hasSubKeys,
  ) {
    return BoxDecoration(
      color: isSelected
          ? SeraphineColors.of(context).primary.withValues(alpha: 0.15)
          : (node.isFolder
                ? SeraphineColors.of(context).surface.withValues(alpha: 0.08)
                : (hasSubKeys && !isCollapsed
                      ? SeraphineColors.of(
                          context,
                        ).primary.withValues(alpha: 0.05)
                      : Colors.transparent)),
      borderRadius: SeraphineSpacing.radiusSM,
      border: isSelected
          ? Border.all(
              color: SeraphineColors.of(context).primary.withValues(alpha: 0.3),
            )
          : (node.isFolder
                ? Border.all(
                    color: SeraphineColors.of(
                      context,
                    ).border.withValues(alpha: 0.15),
                  )
                : (hasSubKeys && !isCollapsed
                      ? Border.all(
                          color: SeraphineColors.of(
                            context,
                          ).primary.withValues(alpha: 0.1),
                        )
                      : null)),
    );
  }

  Widget _buildNodeText(BuildContext context, Color envColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  node.name.toUpperCase(),
                  style: SeraphineTypography.bodySmall.copyWith(
                    fontWeight: node.isFolder
                        ? FontWeight.w900
                        : FontWeight.w700,
                    fontSize: 10,
                    color: SeraphineColors.of(context).textPrimary,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (node.version != null)
                ScoutVersionBadge(version: node.version!),
            ],
          ),
          if (node.environment.isNotEmpty && !node.isFolder)
            ScoutNodeBadge(text: node.environment, color: envColor),
        ],
      ),
    );
  }

  Widget _buildTrailingIcon(
    BuildContext context,
    bool isCollapsed,
    bool hasSubKeys,
    bool isSelected,
  ) {
    if (hasSubKeys) {
      return Icon(
        isCollapsed ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_up,
        size: 10,
        color: SeraphineColors.of(context).primary.withValues(alpha: 0.4),
      );
    }
    if (!node.isFolder) {
      return Icon(
        CupertinoIcons.chevron_right,
        size: 10,
        color: SeraphineColors.of(context).textDetail.withValues(alpha: 0.2),
      );
    }
    return const SizedBox();
  }

  Widget _buildSubKeys(int depth) {
    return Obx(() {
      final isCollapsed = controller.collapsedPaths.contains(node.fullPath);
      if (node.isFolder || node.subKeys == null || isCollapsed) {
        return const SizedBox();
      }

      return Column(
        children: node.subKeys!
            .map(
              (keyName) => ScoutSubKeyItem(
                parentNode: node,
                keyName: keyName,
                depth: depth + 1,
                indentSize: indentSize,
              ),
            )
            .toList(),
      );
    });
  }

  Color _getEnvColor(BuildContext context, String env) {
    return switch (env) {
      'PRODUCTION' => SeraphineColors.of(context).primary,
      'STSeraphineING' => SeraphineColors.of(context).warning,
      'DEVELOPMENT' => SeraphineColors.of(context).primary,
      _ => SeraphineColors.of(context).textDetail,
    };
  }
}
