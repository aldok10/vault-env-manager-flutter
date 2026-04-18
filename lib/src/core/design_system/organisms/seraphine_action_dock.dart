import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_box.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';

/// 🛸 SeraphineActionDock
/// A floating, glassmorphic control center for primary vault actions.
class SeraphineActionDock extends StatelessWidget {
  final VoidCallback onEncrypt;
  final VoidCallback onDecrypt;
  final RxBool isProcessing;

  const SeraphineActionDock({
    super.key,
    required this.onEncrypt,
    required this.onDecrypt,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SeraphineMotion.fast,
      curve: SeraphineMotion.standardCurve,
      child: SeraphineGlassBox(
        padding: const EdgeInsets.all(SeraphineSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Tooltip(
                message: 'Encrypt current workspace data',
                child: Semantics(
                  label: 'Encrypt',
                  hint: 'Cryptographic locking of secret payloads',
                  child: SeraphineButton(
                    text: 'ENCRYPT',
                    icon: CupertinoIcons.lock_shield_fill,
                    onPressed: onEncrypt,
                    isLoading: isProcessing.value,
                    variant: SeraphineButtonVariant.solid,
                  ),
                ),
              ),
            ),
            SeraphineSpacing.xsH,
            Obx(
              () => Tooltip(
                message: 'Decrypt current workspace data',
                child: Semantics(
                  label: 'Decrypt',
                  hint: 'Unlock encrypted payloads using the derivation key',
                  child: SeraphineButton(
                    text: 'DECRYPT',
                    icon: CupertinoIcons.lock_open_fill,
                    onPressed: onDecrypt,
                    isLoading: isProcessing.value,
                    variant: SeraphineButtonVariant.outline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1.0,
          end: 0,
          duration: SeraphineMotion.slow,
          curve: Curves.easeOutQuart,
        )
        .fadeIn(duration: SeraphineMotion.medium);
  }
}
