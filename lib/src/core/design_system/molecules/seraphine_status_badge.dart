import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_card.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 💎 SeraphineStatusBadge
/// A premium status indicator using Liquid Glass materiality.
class SeraphineStatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isVisible;

  const SeraphineStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final activeColor = color ?? SeraphineColors.of(context).primary;

    return Semantics(
      label: 'Status: $label',
      container: true,
      child: SeraphineGlassCard(
        blur: 8,
        cornerRadius: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseIndicator(color: activeColor),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: SeraphineTypography.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  final Color color;
  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
