import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_dropdown.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_labeled_input.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_breakpoints.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

class KeyRepositoryManualTab extends GetView<WorkbenchController> {
  const KeyRepositoryManualTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: context.isMobile
                ? const EdgeInsets.all(16)
                : SeraphineSpacing.pAllLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SeraphineLabeledInput(
                  label: 'Key Label',
                  child: SeraphineInputField(
                    controller: controller.keyLabelController,
                    hint: 'Internal name (e.g. ST_MAIN_VAULT)',
                    prefixIcon: CupertinoIcons.tag,
                  ),
                ),
                SeraphineSpacing.mdV,
                SeraphineLabeledInput(
                  label: 'Secure Token / Key Content',
                  child: SeraphineInputField(
                    controller: controller.newKeyController,
                    hint: 'Enter or regen key...',
                    obscureText: true,
                    prefixIcon: CupertinoIcons.doc_text,
                    suffixIcon: CupertinoIcons.refresh,
                    onSuffixTap: () => controller.regenKey(),
                  ),
                ),
                SeraphineSpacing.mdV,
                SeraphineLabeledInput(
                  label: 'Cryptography Algorithm',
                  child: SeraphineDropdown(
                    value: controller.selectedAlgorithm,
                    items: controller.algorithms,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: SeraphineSpacing.pAllLG,
          child: SeraphineButton.solid(
            onPressed: () {
              controller.addNewKey();
              controller.repositoryTab.value = 0; // Go to Stored
            },
            text: 'REGISTER SECURE KEY',
            icon: CupertinoIcons.shield_fill,
          ),
        ),
      ],
    );
  }
}
