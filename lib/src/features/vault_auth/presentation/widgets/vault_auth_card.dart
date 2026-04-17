import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_dropdown.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_workbench_widget.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/widgets/vault_biometric_button.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/widgets/vault_ldap_form.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/widgets/vault_token_form.dart';

/// 🏛️ VaultAuthCard
/// Secure authorization gateway with high spatial depth.
class VaultAuthCard extends GetView<VaultAuthController> {
  const VaultAuthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SeraphineWorkbenchWidget(
      title: 'Sign In',
      icon: CupertinoIcons.person_crop_circle_fill,
      isCollapsible: true,
      initialCollapsed: false,
      child: Padding(
        padding: const EdgeInsets.all(SeraphineSpacing.lg),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTH METHOD',
                  style: SeraphineTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SeraphineSpacing.smV,
                SeraphineDropdown<String>(
                  value: controller.selectedMethod,
                  items: controller.methods,
                ),
              ],
            ),
            SeraphineSpacing.lgV,
            Obx(() {
              if (controller.selectedMethod.value == 'Token') {
                return VaultTokenForm(controller: controller);
              } else {
                return VaultLdapForm(controller: controller);
              }
            }),
            SeraphineSpacing.lgV,
            _buildErrorMessage(context),
            _buildActionRow(),
            SeraphineSpacing.mdV,
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Obx(() {
      if (controller.errorMsg.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            controller.errorMsg.value,
            style: SeraphineTypography.caption.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => SeraphineButton(
              text: 'SIGN IN',
              onPressed: () => controller.signIn(),
              isLoading: controller.isLoading.value,
              icon: CupertinoIcons.arrow_right_square_fill,
              variant: SeraphineButtonVariant.solid,
            ),
          ),
        ),
        Obx(() {
          if (controller.isBiometricSupported.value) {
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: VaultBiometricButton(
                onPressed: () => controller.authenticateWithBiometrics(),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSkipButton() {
    return SeraphineButton(
      text: 'Skip authorization for now',
      variant: SeraphineButtonVariant.ghost,
      onPressed: () => controller.skipLogin(),
    );
  }
}
