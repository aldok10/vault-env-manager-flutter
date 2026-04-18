import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/models/ui_node.dart';

class ScoutSubKeyItem extends GetView<DiscoveryController> {
  final UiNode parentNode;
  final String keyName;
  final int depth;
  final double indentSize;

  const ScoutSubKeyItem({
    super.key,
    required this.parentNode,
    required this.keyName,
    required this.depth,
    required this.indentSize,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSelected = parentNode.fullPath == controller.selectedPath &&
          keyName == controller.selectedKey;

      return Stack(
        children: [
          _buildHierarchyLine(context),
          _buildContent(context, isSelected),
        ],
      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
    });
  }

  Widget _buildHierarchyLine(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: (depth - 1.5) * indentSize,
          top: 0,
          bottom: 0,
          child: Container(
            width: 0.5,
            color: SeraphineColors.of(
              context,
            ).glassBorder.withValues(alpha: 0.15),
          ),
        ),
        Positioned(
          left: (depth - 1.5) * indentSize,
          top: 15,
          child: Container(
            width: indentSize * 0.7,
            height: 0.5,
            color: SeraphineColors.of(
              context,
            ).glassBorder.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(left: (depth - 0.5) * indentSize, bottom: 2),
      child: InkWell(
        onTap: () => controller.selectSubKey(parentNode, keyName),
        borderRadius: SeraphineSpacing.radiusSM,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? SeraphineColors.of(context).primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: SeraphineSpacing.radiusSM,
            border: isSelected
                ? Border.all(
                    color: SeraphineColors.of(
                      context,
                    ).primary.withValues(alpha: 0.2),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? SeraphineColors.of(context).primary
                      : SeraphineColors.of(
                          context,
                        ).primary.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: SeraphineColors.of(
                              context,
                            ).primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              SeraphineSpacing.smH,
              Expanded(
                child: Text(
                  keyName,
                  style: SeraphineTypography.console.copyWith(
                    fontSize: 9,
                    color: isSelected
                        ? SeraphineColors.of(context).textPrimary
                        : SeraphineColors.of(
                            context,
                          ).textPrimary.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 10,
                  color: SeraphineColors.of(context).primary,
                )
              else
                Icon(
                  CupertinoIcons.arrow_right_circle,
                  size: 10,
                  color: SeraphineColors.of(
                    context,
                  ).textDetail.withValues(alpha: 0.2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
