/// Exception thrown when the Message Authentication Code (MAC) or GCM Tag is invalid.
/// Indicates the encrypted data has been tampered with.
final class MacInvalidException implements Exception {
  final String message;
  const MacInvalidException([this.message = 'The MAC/Tag is invalid.']);

  @override
  String toString() => 'MacInvalidException: $message';
}

/// Exception thrown when a [Crypt] instance cannot be constructed because
/// the supplied `APP_KEY` is malformed or of the wrong length.
///
/// This is raised eagerly from `Crypt.fromAppKey` in preference to silently
/// zero-padding or truncating a weak key to fit the cipher's key size.
final class CryptException implements Exception {
  final String message;
  const CryptException([this.message = 'Invalid cryptographic key.']);

  @override
  String toString() => 'CryptException: $message';
}
