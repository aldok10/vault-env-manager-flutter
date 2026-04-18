import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/auth/domain/repositories/i_auth_repository.dart';

/// Master-password authentication backed by PBKDF2-HMAC-SHA256.
///
/// Stored format (v2):
///   `v2$<iterations>$<salt_b64>$<derivedKey_b64>`
///
/// A random 32-byte salt is generated on each call to [setupMasterPassword].
/// Verification uses [CryptoUtils.constantTimeEquals] to avoid timing leaks.
///
/// Legacy v1 hashes produced by the previous single-round HMAC implementation
/// are still accepted on [unlock] so existing installs keep working; if the
/// legacy hash matches, the record is transparently re-hashed and persisted
/// in the v2 format before the method returns.
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._config);

  final AppConfigService _config;

  // -- PBKDF2 tuning -----------------------------------------------------
  static const int _pbkdf2Iterations = 100000;
  static const int _pbkdf2SaltBytes = 32;
  static const int _pbkdf2DkBytes = 32;
  static const String _v2Prefix = 'v2';

  // -- Legacy (v1) constants kept so old records still verify ------------
  static const String _legacySalt = 'vault-env-manager-v1-salt';
  static const String _legacyKey = 'master-key-derivation-secret';

  @override
  bool isSetup() => _config.cipherPass.value.isNotEmpty;

  @override
  Future<Either<Failure, bool>> setupMasterPassword(String password) async {
    try {
      if (password.isEmpty) {
        return const Left(AuthFailure('Master password must not be empty.'));
      }
      final hash = await _hashV2(password);
      await _config.setCipherPass(hash);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize security: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> unlock(String password) async {
    try {
      final stored = _config.cipherPass.value;
      if (stored.isEmpty) {
        return const Left(AuthFailure('Master password is not set.'));
      }

      if (stored.startsWith('$_v2Prefix\$')) {
        return (await _verifyV2(password, stored))
            ? const Right(true)
            : const Left(AuthFailure('Invalid master password'));
      }

      // Legacy (v1) record. Verify with old HMAC, then upgrade to v2.
      if (_verifyLegacy(password, stored)) {
        try {
          await _config.setCipherPass(await _hashV2(password));
        } catch (_) {
          // Upgrade failure must not block login; log-only once wiring
          // a proper logger is available.
        }
        return const Right(true);
      }
      return const Left(AuthFailure('Invalid master password'));
    } catch (e) {
      return Left(ServerFailure('Authentication error: $e'));
    }
  }

  @override
  Future<void> lock() async {
    // Session-only lock, keep the cipherPass hash in config for next unlock.
  }

  // ---------------------------------------------------------------------
  // v2 — PBKDF2-HMAC-SHA256
  // ---------------------------------------------------------------------

  /// Hashes a new master password using a freshly-generated salt.
  ///
  /// The PBKDF2 inner loop is delegated to [compute] so the 100 000-round
  /// HMAC-SHA256 derivation runs on a background isolate, keeping the UI
  /// thread responsive on lower-end devices (see Devin Review finding on
  /// MR !1). In `flutter_test` contexts, [compute] transparently runs the
  /// callback on the current isolate.
  Future<String> _hashV2(String password) async {
    final salt = _randomBytes(_pbkdf2SaltBytes);
    final dk = await compute(
      _pbkdf2Isolate,
      _Pbkdf2Args(
        password: utf8.encode(password),
        salt: salt,
        iterations: _pbkdf2Iterations,
        dkLen: _pbkdf2DkBytes,
      ),
    );
    return '$_v2Prefix\$$_pbkdf2Iterations\$'
        '${base64Encode(salt)}\$${base64Encode(dk)}';
  }

  Future<bool> _verifyV2(String password, String stored) async {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _v2Prefix) return false;

    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return false;

    final Uint8List salt;
    final Uint8List expected;
    try {
      salt = base64Decode(parts[2]);
      expected = base64Decode(parts[3]);
    } catch (_) {
      return false;
    }

    // A v2 record with a tampered/empty salt or derived-key field must be
    // rejected outright. Otherwise _pbkdf2(..., dkLen: 0) returns an empty
    // list and _constantTimeEquals([], []) trivially matches, letting any
    // password unlock the app. See Devin Review finding on MR !1.
    if (salt.isEmpty || expected.isEmpty) return false;

    final candidate = await compute(
      _pbkdf2Isolate,
      _Pbkdf2Args(
        password: utf8.encode(password),
        salt: salt,
        iterations: iterations,
        dkLen: expected.length,
      ),
    );
    return _constantTimeEquals(candidate, expected);
  }

  // ---------------------------------------------------------------------
  // v1 legacy — retained for one-time upgrade on successful unlock
  // ---------------------------------------------------------------------

  bool _verifyLegacy(String password, String storedHex) {
    final key = utf8.encode(_legacyKey);
    final data = utf8.encode(
      _legacySalt + base64.encode(utf8.encode(password)),
    );
    final computed = Hmac(sha256, key).convert(data).toString();
    // Constant-time over the stored hex representation.
    return _constantTimeEqualsString(computed, storedHex);
  }

  // ---------------------------------------------------------------------
  // Primitives
  // ---------------------------------------------------------------------

  Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes;
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  bool _constantTimeEqualsString(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// RFC 2898 PBKDF2-HMAC-SHA256 derivation.
///
/// Exposed as a top-level function so [compute] can spawn it in a
/// background isolate — `compute` rejects closures and instance methods
/// because those cannot be sent across isolate boundaries.
///
/// Also used directly by unit tests to exercise the RFC 6070 test vectors
/// without any `AppConfigService` wiring.
@visibleForTesting
Uint8List pbkdf2HmacSha256({
  required List<int> password,
  required List<int> salt,
  required int iterations,
  required int dkLen,
}) {
  final hmac = Hmac(sha256, password);
  const hLen = 32; // SHA-256 output size in bytes.
  final blocks = (dkLen + hLen - 1) ~/ hLen;
  final out = Uint8List(blocks * hLen);

  for (var i = 1; i <= blocks; i++) {
    final block = Uint8List(salt.length + 4)
      ..setRange(0, salt.length, salt)
      ..[salt.length] = (i >> 24) & 0xff
      ..[salt.length + 1] = (i >> 16) & 0xff
      ..[salt.length + 2] = (i >> 8) & 0xff
      ..[salt.length + 3] = i & 0xff;

    var u = Uint8List.fromList(hmac.convert(block).bytes);
    final t = Uint8List.fromList(u);
    for (var c = 1; c < iterations; c++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < hLen; j++) {
        t[j] ^= u[j];
      }
    }
    out.setRange((i - 1) * hLen, i * hLen, t);
  }
  return Uint8List.sublistView(out, 0, dkLen);
}

/// Isolate entry-point consumed by [compute]. Delegates to
/// [pbkdf2HmacSha256]; the only reason it exists is so [compute] has a
/// single-argument function to call.
Uint8List _pbkdf2Isolate(_Pbkdf2Args args) => pbkdf2HmacSha256(
      password: args.password,
      salt: args.salt,
      iterations: args.iterations,
      dkLen: args.dkLen,
    );

class _Pbkdf2Args {
  _Pbkdf2Args({
    required this.password,
    required this.salt,
    required this.iterations,
    required this.dkLen,
  });

  final List<int> password;
  final List<int> salt;
  final int iterations;
  final int dkLen;
}
