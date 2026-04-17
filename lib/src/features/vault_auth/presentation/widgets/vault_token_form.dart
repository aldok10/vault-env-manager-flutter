import 'package:flutter/cupertino.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';

class VaultTokenForm extends StatelessWidget {
  final VaultAuthController controller;

  const VaultTokenForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SeraphineInputField(
          label: 'VAULT TOKEN',
          controller: controller.tokenController,
          focusNode: controller.tokenFocusNode,
          obscureText: true,
          hint: 'hvs.••••••••',
          prefixIcon: CupertinoIcons.lock_fill,
          onChanged: (_) => controller.errorMsg.value = '',
          onSubmitted: (_) => controller.signIn(),
        ),
      ],
    );
  }
}
