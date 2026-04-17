import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/organisms/seraphine_action_dock.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/scout_sidepanel.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/seraphine_config_grid.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/workbench_diff_explorer.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/workbench_header.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/workbench_secret_editor.dart';

/// 🏛️ WorkbenchPage
/// The flagship environment management hub, reimagined for 2026.
class WorkbenchPage extends GetView<WorkbenchController> {
  const WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Vault Workbench',
      container: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawerScrimColor: Colors.black.withValues(alpha: 0.3),
        endDrawer: Semantics(
          label: 'System Logs and Scouting Panel',
          child: const ScoutSidepanel(),
        ),
        body: const _WorkbenchContent(),
      ),
    );
  }
}

class _WorkbenchContent extends GetView<WorkbenchController> {
  const _WorkbenchContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              const WorkbenchHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    SeraphineSpacing.xl,
                    0,
                    SeraphineSpacing.xl,
                    SeraphineSpacing.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(),
                      child: const Column(
                        children: [
                          SeraphineConfigGrid(),
                          SeraphineSpacing.mdV,
                          WorkbenchSecretEditor(),
                          SeraphineSpacing.xlV,
                          WorkbenchDiffExplorer(),
                          // Bottom spacing for dock
                          SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🛸 Floating Action Dock
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Semantics(
              button: true,
              label: 'Vault Actions Control Dock',
              hint: 'Access encryption and decryption tools',
              child: SeraphineActionDock(
                onEncrypt: () => controller.encrypt(),
                onDecrypt: () => controller.decrypt(),
                isProcessing: controller.isProcessing,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
