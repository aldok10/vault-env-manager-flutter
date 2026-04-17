import 'dart:convert';

/// Service dedicated to extracting normalized secret payloads from Vault JSON responses.
/// Handles Vault KV V1, KV V2, and direct object structures.
class SecretExtractionService {
  /// Extracts the inner 'data' payload from a standard Vault response.
  ///
  /// Case 1 (KV V2): { "data": { "data": { "key": "value" }, "metadata": { ... } } }
  /// Case 2 (KV V1): { "data": { "key": "value" } }
  /// Case 3 (Direct): { "key": "value" }
  static Map<String, dynamic> extract(dynamic responseData) {
    if (responseData == null) return {};

    Map<String, dynamic> data;
    if (responseData is String) {
      try {
        data = json.decode(responseData);
      } catch (_) {
        return {};
      }
    } else if (responseData is Map<String, dynamic>) {
      data = responseData;
    } else {
      return {};
    }

    // Extraction prioritizes nested 'data' (V2) then outer 'data' (V1)
    if (data.containsKey('data')) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) {
        if (inner.containsKey('data') &&
            inner['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(inner['data']);
        }
        return Map<String, dynamic>.from(inner);
      }
    }

    return Map<String, dynamic>.from(data);
  }

  /// Extracts a specific nested value from a path string (e.g., "mysql.password")
  static dynamic extractByPath(Map<String, dynamic> data, String path) {
    final segments = path.split('.');
    dynamic current = data;

    for (final segment in segments) {
      if (current is Map<String, dynamic> && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return null;
      }
    }
    return current;
  }
}
