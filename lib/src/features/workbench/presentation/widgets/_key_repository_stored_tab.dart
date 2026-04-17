import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_status_badge.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_breakpoints.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

class KeyRepositoryStoredTab extends GetView<WorkbenchController> {
  const KeyRepositoryStoredTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Obx(() {
      if (controller.savedConfigs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.lock_shield,
                size: 48,
                color: colors.textDetail.withValues(alpha: 0.2),
              ),
              SeraphineSpacing.mdV,
              Text(
                'NO PERSISTED CONFIGURATIONS',
                style: SeraphineTypography.label.copyWith(
                  color: colors.textDetail.withValues(alpha: 0.5),
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: context.isMobile
            ? const EdgeInsets.all(16)
            : SeraphineSpacing.pAllLG,
        itemCount: controller.savedConfigs.length,
        separatorBuilder: (_, _) => SeraphineSpacing.smV,
        itemBuilder: (context, index) {
          final config = controller.savedConfigs[index];
          final rawKey = config.key.value;
          final isSelected =
              controller.masterKeyController.text == rawKey &&
              controller.selectedAlgorithm.value == config.algorithm.value;

          final maskedKey = config.key.masked;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.1)
                  : colors.surfaceLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(colors.cardRadius),
              border: Border.all(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.4)
                    : colors.glassBorder.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: Row(
                children: [
                  Text(
                    config.label.displayValue.toUpperCase(),
                    style: SeraphineTypography.boldTracking.copyWith(
                      fontSize: 11,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected) const SeraphineStatusBadge(label: 'ACTIVE'),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maskedKey,
                      style: SeraphineTypography.console.copyWith(
                        fontSize: 10,
                        color: colors.textDetail,
                      ),
                    ),
                    SeraphineSpacing.xxsV,
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            config.algorithm.value.toUpperCase(),
                            style: SeraphineTypography.boldTracking.copyWith(
                              fontSize: 8,
                              color: isSelected
                                  ? colors.primary
                                  : colors.textDetail,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                onPressed: () => controller.deleteConfig(config.id),
                icon: const Icon(CupertinoIcons.trash, size: 16),
                color: colors.primary.withValues(alpha: 0.5),
                tooltip: 'Delete Configuration',
              ),
              onTap: () {
                controller.useConfig(config);
                Get.back();
              },
            ),
          );
        },
      );
    });
  }
}
