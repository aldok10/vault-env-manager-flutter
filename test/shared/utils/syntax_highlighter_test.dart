import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/utils/syntax_highlighter.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_color_extension.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyntaxHighlighter', () {
    setUpAll(() async {
      await SyntaxHighlighter.initialize();
    });

    test('fromExtension returns correct SyntaxType', () {
      expect(SyntaxHighlighter.fromExtension('.env'), SyntaxType.env);
      expect(SyntaxHighlighter.fromExtension('.json'), SyntaxType.json);
      expect(SyntaxHighlighter.fromExtension('.yml'), SyntaxType.yml);
      expect(SyntaxHighlighter.fromExtension('.yaml'), SyntaxType.yml);
      expect(SyntaxHighlighter.fromExtension('.toml'), SyntaxType.toml);
      expect(SyntaxHighlighter.fromExtension('.conf'), SyntaxType.conf);
      expect(SyntaxHighlighter.fromExtension('.txt'), SyntaxType.none);
      expect(SyntaxHighlighter.fromExtension(''), SyntaxType.none);
    });

    final baseStyle = const TextStyle(fontSize: 14);
    final colors = SeraphineColorExtension.dark;

    test('highlights .env syntax correctly', () {
      final highlighter = SyntaxHighlighter(SyntaxType.env);
      final text = '''
# Comment
KEY=value
''';

      final spans = highlighter.highlight(text, baseStyle, colors: colors);

      // Verify basic structure of returned spans
      expect(spans, isNotEmpty);

      // Extract all text from spans to ensure nothing was lost
      final reconstructed = spans.map((s) => s.text).join('');
      expect(reconstructed, text);
    });

    test('highlights .toml syntax correctly', () {
      final highlighter = SyntaxHighlighter(SyntaxType.toml);
      final text = '''
# Comment
[Section]
key = "value"
''';

      final spans = highlighter.highlight(text, baseStyle, colors: colors);
      expect(spans, isNotEmpty);
      final reconstructed = spans.map((s) => s.text).join('');
      expect(reconstructed, text);
    });

    test('highlights .conf syntax correctly', () {
      final highlighter = SyntaxHighlighter(SyntaxType.conf);
      final text = '''
# Comment
; Another Comment
[Section]
key value
''';

      final spans = highlighter.highlight(text, baseStyle, colors: colors);
      expect(spans, isNotEmpty);
      final reconstructed = spans.map((s) => s.text).join('');
      expect(reconstructed, text);
    });

    test('highlights .json syntax correctly (using package highlighter)', () {
      final highlighter = SyntaxHighlighter(SyntaxType.json);
      final text = '{"key": "value"}';

      final spans = highlighter.highlight(text, baseStyle, colors: colors);
      expect(spans, isNotEmpty);
      expect(spans.first.children, isNotEmpty);
      // The package highlighter returns a TextSpan with children containing the styled segments.
    });

    test('highlights .yml syntax correctly (using package highlighter)', () {
      final highlighter = SyntaxHighlighter(SyntaxType.yml);
      final text = 'key: value';

      final spans = highlighter.highlight(text, baseStyle, colors: colors);
      expect(spans, isNotEmpty);
      expect(spans.first.children, isNotEmpty);
    });

    test('returns unstyled text for none or empty type', () {
      final highlighter = SyntaxHighlighter(SyntaxType.none);
      final text = 'plain text';

      final spans = highlighter.highlight(text, baseStyle, colors: colors);
      expect(spans.length, 1);
      expect(spans.first.text, text);
      expect(spans.first.style, baseStyle);

      final emptySpans = highlighter.highlight('', baseStyle, colors: colors);
      expect(emptySpans.length, 1);
      expect(emptySpans.first.text, '');
      expect(emptySpans.first.style, baseStyle);
    });

    test('handles light and dark themes using SeraphineColorExtension', () {
      final jsonHighlighter = SyntaxHighlighter(SyntaxType.json);
      final text = '{"test": 123}';

      // Dark mode has textPrimary == Colors.white
      final darkColors = SeraphineColorExtension.dark;
      final darkSpans = jsonHighlighter.highlight(text, baseStyle, colors: darkColors);

      // Light mode has textPrimary == Color(0xFF1F2328)
      final lightColors = SeraphineColorExtension.light;
      final lightSpans = jsonHighlighter.highlight(text, baseStyle, colors: lightColors);

      // We expect the first TextSpan to contain the highlighted content in both cases.
      expect(darkSpans.first.children, isNotEmpty);
      expect(lightSpans.first.children, isNotEmpty);

      // For .env (custom patterns), check style mapping
      final envHighlighter = SyntaxHighlighter(SyntaxType.env);
      final customDarkSpans = envHighlighter.highlight('# test', baseStyle, colors: darkColors);
      final customLightSpans = envHighlighter.highlight('# test', baseStyle, colors: lightColors);

      expect(customDarkSpans.length, greaterThan(0));
      expect(customLightSpans.length, greaterThan(0));
    });
  });
}
