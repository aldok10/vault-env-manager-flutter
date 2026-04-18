import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_command_console.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_header.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_hierarchy_section.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_operational_protocol.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/navigation/scout_search_header.dart';

class ScoutSidepanel extends GetView<DiscoveryController> {
  const ScoutSidepanel({super.key});

  @override
  Widget build(BuildContext context) {
    final double drawerWidth =
        context.width < 600 ? context.width * 0.9 : context.width * 0.5;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SeraphineGlassBox(
        cornerRadius: 0, // Sidebar usually touches the edge
        borderWidth: 0.5,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScoutHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: SeraphineSpacing.md,
              ),
              children: [
                const ScoutCommandConsole(),
                const SizedBox(height: SeraphineSpacing.lg),
                const ScoutSearchHeader(),
                const SizedBox(height: SeraphineSpacing.lg),
                const ScoutHierarchySection(),
                const SizedBox(height: SeraphineSpacing.lg),
                const ScoutOperationalProtocol(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
