import 'dart:convert';

class ExtractSecret {
  /// Extracts the secret value from a Vault response.
  static String extract(dynamic data) => switch (data) {
        null => '',
        final String s => _tryDecode(s),
        final Map<String, dynamic> m => _processMap(m),
        _ => data.toString(),
      };

  static String _tryDecode(String s) {
    try {
      final decoded = json.decode(s);
      return switch (decoded) {
        final Map<String, dynamic> m => _processMap(m),
        _ => s,
      };
    } catch (_) {
      return s;
    }
  }

  static String _processMap(Map<String, dynamic> m) => switch (m.length) {
        1 when m.values.first is String => m.values.first as String,
        1 => json.encode(m.values.first),
        _ => json.encode(m),
      };
}
