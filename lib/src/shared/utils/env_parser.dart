/// A lightweight utility to parse and stringify .env files.
///
/// Handles standard dot-env format:
/// - KEY=VALUE
/// - Comments starting with #
/// - Quoted values (single or double)
/// - Empty lines
class EnvParser {
  /// Parses a .env string into a Map.
  static Map<String, String> parse(String content) {
    final Map<String, String> result = {};
    final lines = content.split('\n');

    for (var line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines or comments
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      // Split only on the first '='
      final parts = trimmedLine.split('=');
      if (parts.length < 2) continue;

      final key = parts[0].trim();
      var value = parts.sublist(1).join('=').trim();

      // Handle quoted values
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);

        // Handle escaped quotes in double quoted strings
        if (value.contains('\\"')) {
          value = value.replaceAll('\\"', '"');
        }
      }

      // Final value cleanup for inline comments (if not quoted)
      // Note: This is simplified; true dotenv parsers handle this differently.
      if (!value.contains(' ') && value.contains('#')) {
        value = value.split('#')[0].trim();
      }

      result[key] = value;
    }

    return result;
  }

  /// Stringifies a Map into a .env formatted string.
  static String stringify(Map<String, String> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      // If value contains spaces, add double quotes
      if (value.contains(' ')) {
        buffer.writeln('$key="$value"');
      } else {
        buffer.writeln('$key=$value');
      }
    });
    return buffer.toString();
  }
}
