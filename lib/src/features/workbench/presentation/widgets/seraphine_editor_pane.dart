import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/atoms/seraphine_glass_card.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_code_editor.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_editor_header.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';

/// 🧬 SeraphineEditorPane (Feature-Specific)
/// A specialized pane for the Workbench that integrates SeraphineUI components.
class SeraphineEditorPane extends StatelessWidget {
  final String label;
  final Color dotColor;
  final RxString stats;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onClear;
  final VoidCallback onPaste;
  final VoidCallback onSwap;
  final void Function(String, {LogLevel? level}) appendLog;
  final double? height;

  const SeraphineEditorPane({
    super.key,
    required this.label,
    required this.dotColor,
    required this.stats,
    required this.controller,
    required this.hint,
    required this.onClear,
    required this.onPaste,
    required this.onSwap,
    required this.appendLog,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SeraphineGlassCard(
      child: Column(
        children: [
          SeraphineEditorHeader(
            label: label,
            dotColor: dotColor,
            stats: stats,
            onClear: onClear,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: controller.text));
              appendLog('$label copied to clipboard', level: LogLevel.info);
            },
            onPaste: onPaste,
            onSwap: onSwap,
          ),
          if (height != null)
            SizedBox(
              height: height,
              child: SeraphineCodeEditor(controller: controller, hint: hint),
            )
          else
            Expanded(
              child: SeraphineCodeEditor(controller: controller, hint: hint),
            ),
        ],
      ),
    );
  }
}
