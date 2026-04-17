import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_background.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/widgets/vault_auth_card.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/widgets/vault_auth_header.dart';

class VaultAuthPage extends GetView<VaultAuthController> {
  const VaultAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [SeraphineBackground(), _VaultAuthContent()]),
    );
  }
}

class _VaultAuthContent extends GetView<VaultAuthController> {
  const _VaultAuthContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const VaultAuthHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: SeraphineSpacing.pAllLG,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    children: [
                      const VaultAuthCard(),
                      Text(
                        'Contact your system administrator for access credentials.',
                        style: SeraphineTypography.caption.copyWith(
                          color: SeraphineColors.of(context).textDetail,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
