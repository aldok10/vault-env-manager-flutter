import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/discovery_controller.dart';

class ScoutCommandConsole extends GetView<DiscoveryController> {
  const ScoutCommandConsole({super.key});

  @override
  Widget build(BuildContext context) {
    return SeraphineGlassBox(
      padding: const EdgeInsets.all(SeraphineSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMMAND CONSOLE',
            style: SeraphineTypography.h4.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
              color: SeraphineColors.of(context).textDetail,
            ),
          ),
          const SizedBox(height: SeraphineSpacing.md),
          Obx(() => _buildStatusRow()),
          const SizedBox(height: SeraphineSpacing.lg),
          _buildScoutButton(),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final statusColor = controller.statusColor.value;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fade(duration: 1000.ms, begin: 0.3, end: 1.0)
            .then()
            .fade(duration: 1000.ms, begin: 1.0, end: 0.3),
        const SizedBox(width: SeraphineSpacing.sm),
        Expanded(
          child: Text(
            controller.statusText.value.toUpperCase(),
            style: SeraphineTypography.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoutButton() {
    return Obx(
      () => SeraphineButton.solid(
        onPressed:
            controller.isScouting.value ? null : () => controller.handleScout(),
        text: controller.isScouting.value
            ? 'DISCOVERY IN PROGRESS...'
            : 'INITIATE SCOUT',
        icon: controller.isScouting.value ? null : CupertinoIcons.bolt_fill,
        isLoading: controller.isScouting.value,
        width: double.infinity,
      ),
    );
  }
}
