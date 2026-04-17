import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🧬 SeraphineCodeEditor Molecule
/// A high-fidelity code editor with line numbers and glassmorphic styling.
class SeraphineCodeEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool isReadOnly;

  const SeraphineCodeEditor({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.isReadOnly = false,
  });

  @override
  State<SeraphineCodeEditor> createState() => _SeraphineCodeEditorState();
}

class _SeraphineCodeEditorState extends State<SeraphineCodeEditor> {
  late final ScrollController _mainScrollController;
  late final ScrollController _gutterScrollController;
  final RxInt _lineCount = 1.obs;

  @override
  void initState() {
    super.initState();
    _mainScrollController = ScrollController();
    _gutterScrollController = ScrollController();

    _mainScrollController.addListener(_syncScroll);
    widget.controller.addListener(_updateLineCount);
    _updateLineCount();
  }

  void _syncScroll() {
    if (_gutterScrollController.hasClients) {
      _gutterScrollController.jumpTo(_mainScrollController.offset);
    }
  }

  void _updateLineCount() {
    final text = widget.controller.text;
    final lines = text.isEmpty ? 1 : text.split('\n').length;
    _lineCount.value = lines;
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_syncScroll);
    widget.controller.removeListener(_updateLineCount);
    _mainScrollController.dispose();
    _gutterScrollController.dispose();
    super.dispose();
  }

  static const double _fontSize = 13.0;
  static const double _lineHeight = 1.5;
  static const double _verticalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LINE NUMBER GUTTER
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.5),
            ),
            child: Obx(
              () => ListView.builder(
                controller: _gutterScrollController,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
                itemCount: _lineCount.value,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: _fontSize * _lineHeight,
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        '${index + 1}',
                        style: SeraphineTypography.code.copyWith(
                          fontSize: 11,
                          height: _lineHeight,
                          color: colors.textDetail,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // MAIN EDITOR AREA
          Expanded(
            child: TextField(
              controller: widget.controller,
              scrollController: _mainScrollController,
              maxLines: widget.obscureText ? 1 : null,
              expands: !widget.obscureText,
              textAlignVertical: TextAlignVertical.top,
              readOnly: widget.isReadOnly,
              obscureText: widget.obscureText,
              style: SeraphineTypography.code.copyWith(
                fontSize: _fontSize,
                height: _lineHeight,
                color: colors.textPrimary,
              ),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: SeraphineTypography.code.copyWith(
                  color: colors.textDetail.withValues(alpha: 0.4),
                  fontSize: _fontSize,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: _verticalPadding,
                  horizontal: 24,
                ),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
              ),
              onChanged: (_) => _updateLineCount(),
            ),
          ),
        ],
      ),
    );
  }
}
