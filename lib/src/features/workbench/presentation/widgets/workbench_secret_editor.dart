import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_workbench_widget.dart';
import 'package:vault_env_manager/src/core/design_system/organisms/seraphine_system_console.dart';
import 'package:vault_env_manager/src/core/design_system/organisms/seraphine_workbench_editor_layout.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/seraphine_path_context_bar.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/seraphine_vertical_resizer.dart';

/// 📝 WorkbenchSecretEditor
/// Fully migrated to SeraphineUI for 2026 "Zero-Legacy" initiative.
class WorkbenchSecretEditor extends GetView<WorkbenchController> {
  const WorkbenchSecretEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Vault Workbench Editor',
      container: true,
      child: SeraphineWorkbenchWidget(
        title: 'SECRET EDITORS',
        icon: CupertinoIcons.doc_text_fill,
        isCollapsible: true,
        initialCollapsed: false,
        child: Column(
          children: [
            // SYSTEM CONSOLE SECTION
            SizedBox(
              height: 180, // Slightly taller for better legibility
              child: Obx(
                () => SeraphineSystemConsole(
                  logs: controller.consoleLogs.toList(),
                  onPurge: () => controller.clearLogs(),
                ),
              ),
            ),

            // CONTEXT BAR SECTION
            Obx(
              () => controller.selectedEnvPath.isEmpty
                  ? const SizedBox.shrink()
                  : const SeraphinePathContextBar(),
            ),

            // MAIN EDITOR LAYOUT SECTION
            Obx(
              () => SizedBox(
                height: controller.editorHeight.value,
                child: ClipRRect(
                  child: SeraphineWorkbenchEditorLayout(
                    plaintextController: controller.plaintextController,
                    plaintextStats: controller.plaintextStats,
                    onClearPlaintext: () => controller.clearPlaintext(),
                    onPasteToPlaintext: () => controller.pasteToPlaintext(),
                    ciphertextController: controller.ciphertextController,
                    ciphertextStats: controller.ciphertextStats,
                    onClearCiphertext: () => controller.clearCiphertext(),
                    onPasteToCiphertext: () => controller.pasteToCiphertext(),
                    isFlipped: controller.isFlipped,
                    onSwap: () => controller.swapEditors(),
                    splitRatio: controller.editorWidthPercent,
                    onSplitRatioChanged: (val) =>
                        controller.setEditorWidthPercent(val),
                    appendLog: (msg, {level}) => controller.appendLog(
                      msg,
                      level: level ?? LogLevel.info,
                    ),
                  ),
                ),
              ),
            ),

            // RESIZER HANDLE
            const SeraphineVerticalResizer(),
          ],
        ),
      ),
    );
  }
}
