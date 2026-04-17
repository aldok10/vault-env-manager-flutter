import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_card.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_workbench_widget.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/algorithm_selector_widget.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/key_repository_modal.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/master_key_widget.dart';
import 'package:vault_env_manager/src/shared/utils/adaptive_modal.dart';

/// 🧱 SeraphineConfigGrid Organism (2026 Evolution)
/// Implements an Adaptive Bento Grid layout for security configurations.
class SeraphineConfigGrid extends GetView<WorkbenchController> {
  const SeraphineConfigGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Mobile Layout (Single Column Stack)
    if (MediaQuery.of(context).size.width < 800) {
      return SeraphineWorkbenchWidget(
        title: 'SECURITY CONFIGURATION',
        icon: CupertinoIcons.shield_fill,
        isCollapsible: true,
        child: Column(
          children: [
            MasterKeyWidget(
              textController: controller.masterKeyController,
              focusNode: controller.masterKeyFocusNode,
              secureKeyMasked: controller.secureKeyMasked,
              isKeyMasked: controller.isKeyMasked,
            ),
            SeraphineSpacing.mdV,
            AlgorithmSelectorWidget(
              selectedAlgorithm: controller.selectedAlgorithm,
              algorithms: controller.algorithms,
              selectedSyntax: controller.selectedSyntax,
              syntaxes: controller.syntaxes,
              isDense: true,
            ),
          ],
        ),
      );
    }

    // Desktop Ultra-Dense Strip Layout
    return Semantics(
      label: 'Security Configuration Strip',
      container: true,
      child: SeraphineGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cornerRadius: 8, // Tighter radius for the strip
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Master Key (Flexible)
            Expanded(
              flex: 4,
              child: MasterKeyWidget(
                textController: controller.masterKeyController,
                focusNode: controller.masterKeyFocusNode,
                secureKeyMasked: controller.secureKeyMasked,
                isKeyMasked: controller.isKeyMasked,
                isDense: true,
              ),
            ),

            SeraphineSpacing.mdH,

            // 2. Saved Keys (Fixed width icon button)
            SeraphineGlassCard(
              onTap: () => AdaptiveModal.show(
                context: context,
                child: const KeyRepositoryModal(),
                title: 'KEY REPOSITORY',
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              cornerRadius: 6,
              child: SizedBox(
                height: 42,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: SeraphineColors.of(context).primary,
                      size: 20,
                    ),
                    Text(
                      'VAULT',
                      style: TextStyle(
                        fontSize: 8,
                        color: SeraphineColors.of(context).primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SeraphineSpacing.mdH,

            // 3. Algorithm Selector (Flexible)
            Expanded(
              flex: 5,
              child: AlgorithmSelectorWidget(
                selectedAlgorithm: controller.selectedAlgorithm,
                algorithms: controller.algorithms,
                selectedSyntax: controller.selectedSyntax,
                syntaxes: controller.syntaxes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
