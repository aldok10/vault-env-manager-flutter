import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

class ScoutOperationalProtocol extends StatelessWidget {
  const ScoutOperationalProtocol({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: SeraphineSpacing.radiusOS,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SeraphineColors.of(context).surface.withValues(alpha: 0.2),
            borderRadius: SeraphineSpacing.radiusOS,
            border: Border.all(
              color: SeraphineColors.of(
                context,
              ).glassBorder.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OPERATIONAL PROTOCOL',
                style: SeraphineTypography.boldTracking.copyWith(fontSize: 10),
              ),
              SeraphineSpacing.lgV,
              _ProtocolStep(
                color: SeraphineColors.of(context).primary,
                label: 'INITIALIZE VAULT DASHBOARD',
              ),
              SeraphineSpacing.mdV,
              _ProtocolStep(
                color: SeraphineColors.of(context).primary,
                label: 'LOCATE TARGET SECRET MAP',
              ),
              SeraphineSpacing.mdV,
              const _ProtocolStep(
                color: Colors.amber,
                label: 'EXECUTE ACTIVE RECONNAISSANCE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtocolStep extends StatelessWidget {
  final Color color;
  final String label;
  const _ProtocolStep({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
        SeraphineSpacing.mdH,
        Text(
          label,
          style: SeraphineTypography.boldTracking.copyWith(
            fontSize: 9,
            color: SeraphineColors.of(
              context,
            ).textPrimary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
