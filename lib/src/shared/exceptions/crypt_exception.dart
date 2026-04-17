/// Exception thrown when the Message Authentication Code (MAC) or GCM Tag is invalid.
/// Indicates the encrypted data has been tampered with.
final class MacInvalidException implements Exception {
  final String message;
  const MacInvalidException([this.message = 'The MAC/Tag is invalid.']);

  @override
  String toString() => 'MacInvalidException: $message';
}
