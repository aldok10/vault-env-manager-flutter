import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_text.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🏢 SeraphineAppBar Organism
/// The top-level spatial header for the SeraphineUI shell.
class SeraphineAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const SeraphineAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SeraphineGlassBox(
        cornerRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: NavigationToolbar(
          leading:
              leading ??
              (showBackButton && Get.previousRoute.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: SeraphineColors.of(context).textPrimary,
                      ),
                      onPressed: () => Get.back(),
                    )
                  : null),
          middle: SeraphineText(
            title.toUpperCase(),
            style: SeraphineTypography.h4.copyWith(
              letterSpacing: 2.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerMiddle: true,
          trailing: actions != null
              ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
              : null,
        ),
      ),
    );
  }
}
