import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';

/// ⚛️ SeraphineIcon Atom
/// Standardized icon scaling and coloring for the SeraphineUI system.
class SeraphineIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const SeraphineIcon(this.icon, {super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? SeraphineColors.of(context).primary,
    );
  }
}
