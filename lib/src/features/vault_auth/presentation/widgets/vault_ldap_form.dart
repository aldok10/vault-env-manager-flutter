import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';

class VaultLdapForm extends StatelessWidget {
  final VaultAuthController controller;

  const VaultLdapForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeraphineInputField(
          label: 'USERNAME',
          controller: controller.usernameController,
          focusNode: controller.usernameFocusNode,
          hint: 'your.user',
          prefixIcon: CupertinoIcons.person_fill,
          onChanged: (_) => controller.errorMsg.value = '',
        ),
        SeraphineSpacing.mdV,
        Obx(
          () => SeraphineInputField(
            label: 'PASSWORD',
            controller: controller.passwordController,
            focusNode: controller.passwordFocusNode,
            obscureText: controller.obscurePassword.value,
            hint: '••••••••',
            prefixIcon: CupertinoIcons.lock_fill,
            onChanged: (_) => controller.errorMsg.value = '',
            onSubmitted: (_) => controller.signIn(),
            suffixIcon: controller.obscurePassword.value
                ? CupertinoIcons.eye
                : CupertinoIcons.eye_slash,
            onSuffixTap: () => controller.togglePasswordVisibility(),
          ),
        ),
        SeraphineSpacing.mdV,
        GestureDetector(
          onTap: () => controller.toggleAdvancedSettings(),
          child: Row(
            children: [
              Obx(
                () => Icon(
                  controller.isAdvancedSettingsOpen.value
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_right,
                  size: 14,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ADVANCED CONFIGURATION',
                style: SeraphineTypography.label.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (!controller.isAdvancedSettingsOpen.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SeraphineInputField(
              label: 'MOUNT PATH',
              controller: controller.mountController,
              hint: 'ldap',
              onChanged: (_) => controller.errorMsg.value = '',
            ),
          );
        }),
      ],
    );
  }
}
