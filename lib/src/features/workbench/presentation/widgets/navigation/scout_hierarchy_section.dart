import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_node_item.dart';

class ScoutHierarchySection extends GetView<DiscoveryController> {
  const ScoutHierarchySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SeraphineSpacing.mdV,
        Obx(() {
          if (controller.filteredNodes.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            itemCount: controller.filteredNodes.length,
            itemBuilder: (context, index) {
              final node = controller.filteredNodes[index];
              return ScoutNodeItem(node: node, index: index);
            },
          );
        }),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            'VAULT HIERARCHY (${controller.discoveredNodes.length})',
            style: SeraphineTypography.boldTracking.copyWith(
              fontSize: 10,
              color: SeraphineColors.of(context).primary.withValues(alpha: 0.8),
            ),
          ),
        ),
        TextButton(
          onPressed: () => controller.handlePurge(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'PURGE MAP',
            style: SeraphineTypography.boldTracking.copyWith(
              fontSize: 8,
              color: SeraphineColors.of(context).primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = controller.searchQuery.value.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? CupertinoIcons.search : CupertinoIcons.wind,
              size: 32,
              color: SeraphineColors.of(
                context,
              ).textDetail.withValues(alpha: 0.2),
            ),
            SeraphineSpacing.mdV,
            Text(
              isSearching ? 'NO NODES MATCHED' : 'READY TO ANALYZE',
              style: SeraphineTypography.boldTracking.copyWith(
                fontSize: 9,
                color: SeraphineColors.of(
                  context,
                ).textDetail.withValues(alpha: 0.3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
