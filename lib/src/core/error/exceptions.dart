/// 🛡️ Seraphine Security Exceptions
/// Centralized exceptions for cryptographic and integrity failures.
class SecurityException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  SecurityException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() {
    if (originalError != null) {
      return 'SecurityException: $message (Original: $originalError)';
    }
    return 'SecurityException: $message';
  }
}
