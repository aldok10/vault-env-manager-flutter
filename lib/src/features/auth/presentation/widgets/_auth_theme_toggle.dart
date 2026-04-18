import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';

class AuthThemeToggle extends StatelessWidget {
  const AuthThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final AppConfigService config = Get.find<AppConfigService>();

    return Positioned(
      top: 32,
      right: 32,
      child: SeraphineGlassBox(
        cornerRadius: SeraphineSpacing.md,
        padding: EdgeInsets.zero,
        child: Obx(
          () => IconButton(
            icon: Icon(
              config.themeMode.value == 'Dark'
                  ? CupertinoIcons.sun_max_fill
                  : CupertinoIcons.moon_stars_fill,
              color: SeraphineColors.of(context).textPrimary,
              size: 20,
            ),
            onPressed: () {
              final newMode =
                  config.themeMode.value == 'Dark' ? 'Light' : 'Dark';
              config.setThemeMode(newMode);
              Get.changeThemeMode(
                newMode == 'Dark' ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 800));
  }
}
