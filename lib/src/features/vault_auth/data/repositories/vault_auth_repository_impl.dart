import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/repositories/i_vault_auth_repository.dart';

class VaultAuthRepositoryImpl implements IVaultAuthRepository {
  final http.Client _client;
  final AppConfigService _config;

  VaultAuthRepositoryImpl(this._client, this._config);

  @override
  Future<Either<VaultFailure, String>> loginWithToken(String token) async {
    try {
      final response = await _client.get(
        _buildUri(<String>['v1', 'auth', 'token', 'lookup-self']),
        headers: {'X-Vault-Token': token},
      );

      if (response.statusCode == 200) {
        return Right(token); // Valid token, just return it
      } else if (response.statusCode == 403) {
        return const Left(VaultAuthFailure('Invalid Vault Token'));
      } else {
        return Left(VaultFailure('Vault API Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(VaultNetworkFailure('Network Error: $e'));
    }
  }

  @override
  Future<Either<VaultFailure, String>> loginWithLdap({
    required String username,
    required String password,
    required String mountPath,
  }) async {
    // Usernames can legitimately contain characters that break URLs (e.g.
    // 'alice@corp', 'svc/vault', 'user%20name'). Interpolating them into a
    // `Uri.parse(...)` template therefore risks either breaking the request
    // (on stray `/` or `?`) or, worse, letting a crafted username redirect
    // the call to a different Vault endpoint (path traversal via `..`).
    //
    // We instead hand the raw username to `Uri.pathSegments`, which
    // percent-encodes each segment correctly and does NOT treat `/` inside
    // a segment as a separator.
    if (username.isEmpty) {
      return const Left(VaultAuthFailure('Username must not be empty.'));
    }
    if (_containsPathTraversal(username) || _containsPathTraversal(mountPath)) {
      return const Left(
        VaultAuthFailure(
          'Username and mount path must not contain path traversal.',
        ),
      );
    }

    final mount = mountPath.isEmpty ? 'ldap' : mountPath;

    try {
      final uri = _buildUri(<String>['v1', 'auth', mount, 'login', username]);

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['auth']?['client_token'];

        if (token != null) {
          return Right(token);
        } else {
          return const Left(
            VaultAuthFailure('No token returned in auth response'),
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        final errorMsg = _extractErrorMessage(response.body);
        return Left(VaultAuthFailure('Authentication Failed: $errorMsg'));
      } else {
        return Left(VaultFailure('Vault API Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(VaultNetworkFailure('Network Error: $e'));
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = json.decode(body);
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        return data['errors'].join(', ');
      }
      return 'Unknown Error';
    } catch (_) {
      return 'Invalid Response Format';
    }
  }

  /// Compose a request URI safely against the configured Vault origin.
  ///
  /// `additionalSegments` are appended to the origin's existing path and
  /// each segment is percent-encoded by `Uri` rather than pasted into a
  /// string template. This avoids two classes of bug:
  ///
  ///   1. A segment containing `/`, `?`, `#`, or `%` silently breaking the
  ///      URL (e.g. a username `svc/vault` would previously be parsed as
  ///      two path segments by `Uri.parse`).
  ///   2. Path-traversal segments like `..` being passed unchanged to the
  ///      upstream, letting a crafted input redirect the call to a
  ///      different Vault endpoint.
  ///
  /// `_containsPathTraversal` is also checked by callers for defence in
  /// depth — `Uri.pathSegments` alone would happily accept `..`.
  @visibleForTesting
  Uri buildVaultUri(List<String> additionalSegments) =>
      _buildUri(additionalSegments);

  Uri _buildUri(List<String> additionalSegments) {
    final base = Uri.parse(_config.vaultOrigin.value);
    final existing = base.pathSegments.where((s) => s.isNotEmpty);
    return base.replace(
      pathSegments: <String>[...existing, ...additionalSegments],
    );
  }

  /// Returns true for inputs that would let an attacker escape the
  /// intended path (`.`, `..`), or smuggle URL metacharacters through
  /// path segments even after encoding. Empty-string mount paths are
  /// permitted (the caller defaults them to `ldap`).
  @visibleForTesting
  static bool isPathTraversal(String segment) =>
      _containsPathTraversal(segment);

  static bool _containsPathTraversal(String segment) {
    if (segment.isEmpty) return false;
    // Block literal `.`/`..` as whole segments — they are the classic
    // traversal primitives and have no legitimate use as a username or
    // mount path.
    if (segment == '.' || segment == '..') return true;
    // Block any segment containing a forward or back slash. `Uri` would
    // encode these, but from a defence-in-depth perspective we want to
    // reject them up front because most Vault deployments will never
    // have legitimately-named identities with embedded slashes.
    if (segment.contains('/') || segment.contains(r'\')) return true;
    // Reject NUL and control characters.
    for (final codeUnit in segment.codeUnits) {
      if (codeUnit < 0x20 || codeUnit == 0x7f) return true;
    }
    return false;
  }
}
