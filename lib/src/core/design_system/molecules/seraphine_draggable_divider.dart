import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';

/// 🧬 SeraphineDraggableDivider Molecule
/// A premium draggable vertical divider for splitting editor views.
class SeraphineDraggableDivider extends StatefulWidget {
  final double gutter;
  final double totalWidth;
  final void Function(double delta) onDeltaUpdate;

  const SeraphineDraggableDivider({
    super.key,
    required this.gutter,
    required this.totalWidth,
    required this.onDeltaUpdate,
  });

  @override
  State<SeraphineDraggableDivider> createState() =>
      _SeraphineDraggableDividerState();
}

class _SeraphineDraggableDividerState extends State<SeraphineDraggableDivider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) => setState(() => _isDragging = true),
        onPanEnd: (details) => setState(() => _isDragging = false),
        onPanUpdate: (details) {
          widget.onDeltaUpdate(details.delta.dx);
        },
        child: Container(
          width: widget.gutter,
          alignment: Alignment.center,
          color: Colors.transparent, // Expand hit area
          child: AnimatedContainer(
            duration: SeraphineMotion.fast,
            curve: SeraphineMotion.standardCurve,
            width: _isDragging ? 6 : 2,
            height: _isDragging ? 100 : 40,
            decoration: BoxDecoration(
              gradient: _isDragging
                  ? LinearGradient(
                      colors: [
                        SeraphineColors.of(context).primary,
                        SeraphineColors.of(context).accent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: _isDragging ? null : SeraphineColors.of(context).border,
              borderRadius: BorderRadius.circular(SeraphineShapes.baseRadius),
              boxShadow: _isDragging
                  ? [
                      BoxShadow(
                        color: SeraphineColors.of(
                          context,
                        ).primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}
