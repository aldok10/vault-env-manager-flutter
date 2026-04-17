import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';

class VaultAuthHeader extends GetView<VaultAuthController> {
  const VaultAuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              color: colors.background.withValues(alpha: 0.5),
              shape: SeraphineShapes.squircle(
                radius: 12,
                side: BorderSide(
                  color: colors.border.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.lock_shield_fill,
                  size: 16,
                  color: colors.primary,
                ),
                SeraphineSpacing.mdH,
                Text(
                  'VAULT AUTHORIZATION',
                  style: SeraphineTypography.label.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => SeraphineButton(
              text: controller.selectedMethod.value.toUpperCase(),
              variant: SeraphineButtonVariant.ghost,
              onPressed: () {}, // Decorative
            ),
          ),
        ],
      ),
    );
  }
}
