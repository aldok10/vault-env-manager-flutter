import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/core/services/network_security_interceptor.dart';

/// Unit tests for the certificate-pinning predicate used by
/// [SecureHttpClient.createPinningClient].
///
/// We test the pure predicate rather than the `badCertificateCallback`
/// closure itself because constructing an [X509Certificate] in a unit
/// test requires a real TLS handshake. The predicate is what actually
/// makes the accept/reject decision; the closure is a thin adapter
/// around it.
void main() {
  // A stable, arbitrary byte sequence we can treat as a fake DER-encoded
  // certificate body. The actual structure doesn't matter for pinning —
  // we only ever hash the bytes.
  final fakeDer = List<int>.generate(256, (i) => i & 0xff);
  final fakeDerHash = sha256.convert(fakeDer).toString();

  group('SecureHttpClient.verifyPin', () {
    test('rejects when no pin is configured (fail-closed)', () {
      // This is the whole point of the change: an unconfigured pin must
      // not cause us to accept a cert the OS already flagged as bad.
      expect(SecureHttpClient.verifyPin(fakeDer, null), isFalse);
    });

    test('accepts when certificate hash matches configured pin', () {
      final pin = SecureHttpClient.debugNormalisePin(fakeDerHash);
      expect(SecureHttpClient.verifyPin(fakeDer, pin), isTrue);
    });

    test('rejects when certificate hash does not match pin', () {
      final wrongPin = SecureHttpClient.debugNormalisePin('0' * 64);
      expect(SecureHttpClient.verifyPin(fakeDer, wrongPin), isFalse);
    });

    test('accepts when pin was supplied with colon separators (case A)', () {
      // Real-world ops teams often paste `AA:BB:CC:...` style fingerprints
      // out of openssl. The normaliser must strip colons before compare.
      final colonised = fakeDerHash
          .toUpperCase()
          .replaceAllMapped(RegExp(r'.{2}'), (m) => '${m.group(0)}:')
          .replaceAll(RegExp(r':$'), '');
      final normalised = SecureHttpClient.debugNormalisePin(colonised);
      expect(SecureHttpClient.verifyPin(fakeDer, normalised), isTrue);
    });

    test('accepts when pin was supplied in uppercase hex', () {
      final upper = SecureHttpClient.debugNormalisePin(
        fakeDerHash.toUpperCase(),
      );
      expect(SecureHttpClient.verifyPin(fakeDer, upper), isTrue);
    });

    test('empty string pin is treated as "no pin" (fail-closed)', () {
      expect(SecureHttpClient.debugNormalisePin(''), isNull);
      expect(
        SecureHttpClient.verifyPin(fakeDer, null),
        isFalse,
        reason: 'Empty fingerprint string must not be treated as a match.',
      );
    });

    test('differs by a single bit → rejected', () {
      // Defence against accidental not-quite-constant-time compares: we
      // still want a clean "false" when everything matches except the
      // last byte of the hash.
      final almost = '${fakeDerHash.substring(0, fakeDerHash.length - 2)}00';
      final pin = SecureHttpClient.debugNormalisePin(almost);
      expect(SecureHttpClient.verifyPin(fakeDer, pin), isFalse);
    });

    test(
      'different certificate bytes → rejected even with a valid-looking pin',
      () {
        final otherDer = List<int>.generate(256, (i) => (i + 1) & 0xff);
        final pin = SecureHttpClient.debugNormalisePin(fakeDerHash);
        expect(
          SecureHttpClient.verifyPin(otherDer, pin),
          isFalse,
          reason: 'Pin is bound to the exact DER bytes we originally hashed; '
              'changing the input must fail verification.',
        );
      },
    );
  });

  group('SecureHttpClient.debugNormalisePin', () {
    test('returns null for null input', () {
      expect(SecureHttpClient.debugNormalisePin(null), isNull);
    });

    test('returns null for empty input', () {
      expect(SecureHttpClient.debugNormalisePin(''), isNull);
    });

    test('strips colons and lowercases', () {
      expect(SecureHttpClient.debugNormalisePin('AA:bb:CC:dd'), 'aabbccdd');
    });
  });
}
