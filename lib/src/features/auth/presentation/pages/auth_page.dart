import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_background.dart';
import 'package:vault_env_manager/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vault_env_manager/src/features/auth/presentation/widgets/_auth_card.dart';
import 'package:vault_env_manager/src/features/auth/presentation/widgets/_auth_theme_toggle.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SeraphineBackground(),
          AuthThemeToggle(),
          Center(child: SingleChildScrollView(child: AuthCard())),
        ],
      ),
    );
  }
}
