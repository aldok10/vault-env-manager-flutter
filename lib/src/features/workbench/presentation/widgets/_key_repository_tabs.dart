import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

class KeyRepositoryTabs extends GetView<WorkbenchController> {
  const KeyRepositoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Stored', 'Manual'];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: SeraphineColors.of(context).border),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;

          return Expanded(
            child: Obx(() {
              final isSelected = controller.repositoryTab.value == index;
              return InkWell(
                onTap: () => controller.repositoryTab.value = index,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? SeraphineColors.of(context).primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: SeraphineTypography.label.copyWith(
                      color: isSelected
                          ? SeraphineColors.of(context).primary
                          : SeraphineColors.of(context).textDetail,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }
}
