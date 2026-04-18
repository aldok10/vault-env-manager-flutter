import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_card.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_breakpoints.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vault_env_manager/src/features/auth/presentation/widgets/_auth_visuals.dart';

class AuthCard extends GetView<AuthController> {
  const AuthCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Padding(
      padding: SeraphineSpacing.pHMD,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SeraphineGlassCard(
          cornerRadius: SeraphineShapes.baseRadius * 2,
          padding: isMobile ? SeraphineSpacing.pAllXL : SeraphineSpacing.pAllXL,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthIcon(),
              SeraphineSpacing.xlV,
              const AuthHeader(),
              SeraphineSpacing.xxlV,
              Obx(
                () => SeraphineInputField(
                  label:
                      controller.isNew ? 'Initialization Key' : 'Authorization',
                  controller: controller.passwordController,
                  focusNode: controller.focusNode,
                  autofocus: true,
                  obscureText: true,
                  hint: '••••••••',
                  prefixIcon: CupertinoIcons.lock_shield,
                  onChanged: (_) => controller.isError.value = false,
                ),
              ),
              _buildErrorArea(context),
              SeraphineSpacing.xlV,
              _buildSubmitButton(),
              SeraphineSpacing.xlV,
              const AuthFooter(),
            ],
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
        )
        .fadeIn(duration: const Duration(milliseconds: 800));
  }

  Widget _buildErrorArea(BuildContext context) {
    return Obx(
      () => controller.errorMsg.value.isNotEmpty
          ? Column(
              children: [
                SeraphineSpacing.smV,
                Text(
                  controller.errorMsg.value,
                  style: SeraphineTypography.bodySmall.copyWith(
                    color: SeraphineColors.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SeraphineButton(
        text: controller.isNew ? 'Initialize System' : 'Unlock System',
        icon: controller.isNew
            ? CupertinoIcons.bolt_fill
            : CupertinoIcons.viewfinder_circle_fill,
        onPressed: () => controller.initializeWorkbench(),
        isLoading: controller.isLoading.value,
        width: double.infinity,
      ),
    );
  }
}
