import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/features/settings/presentation/controllers/settings_controller.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/_settings_header.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/_settings_vault_config.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/_settings_visual_config.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SettingsHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: SeraphineSpacing.pAllLG,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: const Column(
                    children: [
                      SettingsVaultConfig(),
                      SeraphineSpacing.lgV,
                      SettingsVisualConfig(),
                      SeraphineSpacing.xlV,
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
