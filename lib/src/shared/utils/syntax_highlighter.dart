import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_color_extension.dart';

enum SyntaxType { env, json, yml, toml, conf, none }

class SyntaxHighlighter {
  final SyntaxType type;
  static HighlighterTheme? _lightTheme;
  static HighlighterTheme? _darkTheme;
  static final Map<String, Highlighter> _highlighters = {};

  SyntaxHighlighter(this.type);

  static final Map<SyntaxType, RegExp> _combinedRegexCache = {};

  static final RegExp _envComment = RegExp(r'^\s*#.*', multiLine: true);
  static final RegExp _envKey = RegExp(
    r'^[A-Za-z0-9_]+(?=\s*=)',
    multiLine: true,
  );
  static final RegExp _envValue = RegExp(r'(?<==).*');

  static final RegExp _tomlComment = RegExp(r'#.*');
  static final RegExp _tomlSection = RegExp(r'\[.*\]');
  static final RegExp _tomlKey = RegExp(
    r'^[A-Za-z0-9_-]+(?=\s*=)',
    multiLine: true,
  );
  static final RegExp _tomlValue = RegExp(r'(?<==).*');

  static final RegExp _confComment = RegExp(r'[#;].*');
  static final RegExp _confSection = RegExp(r'\[.*\]');
  static final RegExp _confKey = RegExp(
    r'^[A-Za-z0-9_-]+(?=\s*)',
    multiLine: true,
  );

  static Future<void> initialize() async {
    await Highlighter.initialize(['json', 'yaml']);
    _lightTheme = await HighlighterTheme.loadLightTheme();
    _darkTheme = await HighlighterTheme.loadDarkTheme();
  }

  static SyntaxType fromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case '.env':
        return SyntaxType.env;
      case '.json':
        return SyntaxType.json;
      case '.yml':
      case '.yaml':
        return SyntaxType.yml;
      case '.toml':
        return SyntaxType.toml;
      case '.conf':
        return SyntaxType.conf;
      default:
        return SyntaxType.none;
    }
  }

  Highlighter? _getPackageHighlighter(bool isDark) {
    final lang = _getLanguageKey();
    if (lang == null) return null;

    final theme = isDark ? _darkTheme : _lightTheme;

    if (theme == null) return null;

    final cacheKey = '${lang}_${isDark ? 'dark' : 'light'}';

    if (!_highlighters.containsKey(cacheKey)) {
      _highlighters[cacheKey] = Highlighter(language: lang, theme: theme);
    }
    return _highlighters[cacheKey];
  }

  String? _getLanguageKey() {
    switch (type) {
      case SyntaxType.json:
        return 'json';
      case SyntaxType.yml:
        return 'yaml';
      default:
        return null;
    }
  }

  List<TextSpan> highlight(
    String text,
    TextStyle baseStyle, {
    required SeraphineColorExtension colors,
  }) {
    // Try package highlighter first (for JSON, YAML)
    final pkgHighlighter = _getPackageHighlighter(
      colors.textPrimary == Colors.white,
    );
    if (pkgHighlighter != null) {
      return [pkgHighlighter.highlight(text)];
    }

    // Fallback to custom regex for .env, .toml, .conf
    if (type == SyntaxType.none || text.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    final allPatterns = _getCustomPatterns(colors);
    if (allPatterns.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final combinedRegex = _combinedRegexCache.putIfAbsent(
      type,
      () => RegExp(
        allPatterns.keys.map((re) => '(${re.pattern})').join('|'),
        multiLine: true,
      ),
    );

    final matches = combinedRegex.allMatches(text);

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: baseStyle,
          ),
        );
      }

      TextStyle? matchStyle;
      final styles = allPatterns.values.toList();
      for (int i = 0; i < styles.length; i++) {
        if (match.group(i + 1) != null) {
          matchStyle = styles[i];
          break;
        }
      }

      spans.add(
        TextSpan(text: match.group(0), style: baseStyle.merge(matchStyle)),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }

    return spans;
  }

  Map<RegExp, TextStyle> _getCustomPatterns(SeraphineColorExtension colors) {
    switch (type) {
      case SyntaxType.env:
        return {
          _envComment: TextStyle(color: colors.syntaxComment),
          _envKey: TextStyle(color: colors.syntaxKeyword),
          _envValue: TextStyle(color: colors.syntaxString),
        };
      case SyntaxType.toml:
        return {
          _tomlComment: TextStyle(color: colors.syntaxComment),
          _tomlSection: TextStyle(
            color: colors.syntaxFunction,
            fontWeight: FontWeight.bold,
          ),
          _tomlKey: TextStyle(color: colors.syntaxKeyword),
          _tomlValue: TextStyle(color: colors.syntaxString),
        };
      case SyntaxType.conf:
        return {
          _confComment: TextStyle(color: colors.syntaxComment),
          _confSection: TextStyle(color: colors.syntaxFunction),
          _confKey: TextStyle(color: colors.syntaxKeyword),
        };
      default:
        return {};
    }
  }
}
