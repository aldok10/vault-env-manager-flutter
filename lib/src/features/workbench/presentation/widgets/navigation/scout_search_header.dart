import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';

class ScoutSearchHeader extends GetView<DiscoveryController> {
  const ScoutSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SeraphineColors.of(context).surface.withValues(alpha: 0.3),
        borderRadius: SeraphineSpacing.radiusOS,
        border: Border.all(color: SeraphineColors.of(context).glassBorder),
      ),
      child: TextField(
        controller: controller.searchController,
        style: SeraphineTypography.bodySmall.copyWith(
          color: SeraphineColors.of(context).textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'FILTER NODES...',
          hintStyle: SeraphineTypography.boldTracking.copyWith(
            fontSize: 9,
            color: SeraphineColors.of(context).textDetail.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            size: 16,
            color: SeraphineColors.of(context).textDetail,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(CupertinoIcons.xmark, size: 14),
                    onPressed: () => controller.handleClearSearch(),
                    color: SeraphineColors.of(context).textDetail,
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
