import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_text.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';

/// 💻 SeraphineSystemConsole
/// A high-fidelity console for real-time operation logs.
class SeraphineSystemConsole extends StatelessWidget {
  final List<SystemLog> logs;
  final VoidCallback? onPurge;

  const SeraphineSystemConsole({super.key, required this.logs, this.onPurge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SeraphineSpacing.pHLG.copyWith(top: SeraphineSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          SeraphineSpacing.xsV,
          Expanded(
            child: Container(
              padding: SeraphineSpacing.pAllMD,
              decoration: BoxDecoration(
                color: SeraphineColors.of(
                  context,
                ).background.withValues(alpha: 0.5),
                borderRadius: SeraphineSpacing.radius,
                border: Border.all(color: SeraphineColors.of(context).border),
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index];
                  return _LogEntry(log: log)
                      .animate()
                      .fadeIn(duration: SeraphineMotion.fast)
                      .slideX(
                        begin: 0.02,
                        end: 0,
                        curve: SeraphineMotion.smooth,
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SeraphineText(
          'SYSTEM CONSOLE',
          style: SeraphineTypography.label.copyWith(
            fontSize: 10,
            letterSpacing: 1.2,
            color: SeraphineColors.of(context).textDetail,
          ),
        ),
        if (onPurge != null)
          TextButton(
            onPressed: onPurge,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: SeraphineText(
              'PURGE',
              style: SeraphineTypography.label.copyWith(
                fontSize: 10,
                color: SeraphineColors.of(context).primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _LogEntry extends StatelessWidget {
  final SystemLog log;

  const _LogEntry({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeraphineText(
            '[${log.timeFormatted}]',
            style: SeraphineTypography.code.copyWith(
              color: SeraphineColors.of(context).textDetail,
              fontSize: 10,
            ),
          ),
          SeraphineSpacing.smH,
          SeraphineText(
            log.level.icon,
            style: TextStyle(fontSize: 10, color: log.level.color(context)),
          ),
          SeraphineSpacing.xsH,
          Expanded(
            child: SeraphineText(
              log.message,
              style: SeraphineTypography.code.copyWith(
                color: log.level.color(context).withValues(alpha: 0.9),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
