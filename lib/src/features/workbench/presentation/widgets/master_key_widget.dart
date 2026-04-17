import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

/// ⚛️ SeraphineMasterKeyWidget
/// Refined for 2026 with enhanced focus states and spatial depth.
class MasterKeyWidget extends GetView<WorkbenchController> {
  final TextEditingController textController;
  final FocusNode focusNode;
  final RxBool isKeyMasked;
  final bool isDense;

  const MasterKeyWidget({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isKeyMasked,
    required String secureKeyMasked,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDense) ...[
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SeraphineColors.of(context).primary,
                ),
              ),
              SeraphineSpacing.xsH,
              Text(
                'MASTER AUTHORIZATION',
                style: SeraphineTypography.label.copyWith(
                  fontSize: 10,
                  color: SeraphineColors.of(context).textDetail,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Obx(() {
                final activeConfig = controller.savedConfigs.firstWhereOrNull(
                  (c) =>
                      c.key.value == controller.masterKeyText.value &&
                      c.algorithm.value == controller.selectedAlgorithm.value,
                );

                if (activeConfig == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SeraphineColors.primaryGlow,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: SeraphineColors.of(
                        context,
                      ).primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    activeConfig.label.displayValue.toUpperCase(),
                    style: SeraphineTypography.label.copyWith(
                      fontSize: 9,
                      color: SeraphineColors.of(context).primary,
                    ),
                  ),
                );
              }),
            ],
          ),
          SeraphineSpacing.smV,
        ],
        Obx(
          () => SeraphineInputField(
            isDense: isDense,
            controller: textController,
            focusNode: focusNode,
            label: isDense ? null : 'SECRET KEY',
            hint: isDense ? 'Master Key' : 'Enter Master Key...',
            obscureText: isKeyMasked.value,
            prefixIcon: CupertinoIcons.shield_fill,
            suffixIcon: isKeyMasked.value
                ? CupertinoIcons.eye
                : CupertinoIcons.eye_slash,
            onSuffixTap: () => isKeyMasked.value = !isKeyMasked.value,
          ),
        ),
      ],
    );
  }
}
