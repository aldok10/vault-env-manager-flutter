import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'syntax_highlighter.dart';

class CodeEditorController extends TextEditingController {
  SyntaxType _syntaxType = SyntaxType.none;
  SyntaxHighlighter _highlighter = SyntaxHighlighter(SyntaxType.none);

  CodeEditorController({super.text, SyntaxType syntaxType = SyntaxType.none}) {
    _syntaxType = syntaxType;
    _highlighter = SyntaxHighlighter(syntaxType);
  }

  SyntaxType get syntaxType => _syntaxType;
  set syntaxType(SyntaxType type) {
    if (_syntaxType != type) {
      _syntaxType = type;
      _highlighter = SyntaxHighlighter(type);
      notifyListeners();
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // If not highlighting or if we have composing text (IME active),
    // fall back to default behavior temporarily to prevent cursor/overlay jitter.
    if (_syntaxType == SyntaxType.none ||
        (withComposing && value.composing.isValid)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final colors = SeraphineColors.of(context);

    return TextSpan(
      style: style,
      children: _highlighter.highlight(
        text,
        style ?? const TextStyle(),
        colors: colors,
      ),
    );
  }

  void updateSyntax(String syntax) {
    switch (syntax.toLowerCase()) {
      case '.json':
        syntaxType = SyntaxType.json;
        break;
      case '.yml':
      case '.yaml':
        syntaxType = SyntaxType.yml;
        break;
      case '.env':
        syntaxType = SyntaxType.env;
        break;
      default:
        syntaxType = SyntaxType.none;
    }
  }
}
