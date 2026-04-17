import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

/// ↕️ SeraphineVerticalResizer
/// A subtle, high-fidelity resizer handle for vertical layout adjustments.
class SeraphineVerticalResizer extends GetView<WorkbenchController> {
  const SeraphineVerticalResizer({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          controller.setEditorHeight(
            controller.editorHeight.value + details.delta.dy,
          );
        },
        child: Container(
          height: 12,
          width: double.infinity,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SeraphineColors.of(
                context,
              ).glassBorder.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
