import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/vault_auth/data/repositories/vault_auth_repository_impl.dart';

import '../../../../test_mocks.dart';

/// Unit tests for [VaultAuthRepositoryImpl] focused on the URL-construction
/// and input-validation hardening added in this PR.
///
/// The repository talks to Vault over HTTP, so every test uses
/// `package:http/testing`'s [MockClient] to capture the outgoing URL and
/// asserts against [Uri] semantics rather than raw string concatenation.
/// That is the whole point of the change — we want to prove that no
/// user-controlled segment can smuggle URL metacharacters through the
/// template.
void main() {
  late AppConfigService config;

  // A deliberately-awkward Vault origin: trailing slash, sub-path prefix,
  // and the non-default scheme. If we build URIs correctly, every test
  // below should preserve all three exactly.
  const vaultOrigin = 'https://vault.example.com:8200/proxy/';

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    config = await setupTestConfig();
    await config.setVaultOrigin(vaultOrigin);
  });

  tearDown(Get.reset);

  // ---------------------------------------------------------------------
  // Path-traversal predicate (pure, no IO)
  // ---------------------------------------------------------------------

  group('VaultAuthRepositoryImpl.isPathTraversal', () {
    test('empty string is NOT traversal (caller defaults it)', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal(''), isFalse);
    });

    test('literal "." is rejected', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal('.'), isTrue);
    });

    test('literal ".." is rejected', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal('..'), isTrue);
    });

    test('segment containing a forward slash is rejected', () {
      // The classic `Uri.parse` footgun: "svc/vault" would be parsed as
      // two segments, effectively redirecting the call. We reject up
      // front so the bug surfaces at the validation boundary instead of
      // being silently encoded into a different path.
      expect(VaultAuthRepositoryImpl.isPathTraversal('svc/vault'), isTrue);
    });

    test('segment containing a backslash is rejected', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal(r'svc\vault'), isTrue);
    });

    test('segment containing NUL is rejected', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal('al\u0000ice'), isTrue);
    });

    test('segment containing a DEL control character is rejected', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal('alice\u007f'), isTrue);
    });

    test('normal identifier is allowed', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal('alice'), isFalse);
    });

    test('identifier containing "@" or "+" is allowed (percent-encoded)', () {
      expect(VaultAuthRepositoryImpl.isPathTraversal('alice@corp'), isFalse);
      expect(VaultAuthRepositoryImpl.isPathTraversal('alice+bob'), isFalse);
    });

    test('identifier containing "%" is allowed (Uri double-encodes)', () {
      // `%` is NOT a traversal character — callers want literal `%` to
      // round-trip to `%25`, not be rejected. The `Uri` layer handles
      // encoding; our predicate only guards traversal / control chars.
      expect(VaultAuthRepositoryImpl.isPathTraversal('user%20name'), isFalse);
    });
  });

  // ---------------------------------------------------------------------
  // buildVaultUri — percent-encoding and origin-path preservation
  // ---------------------------------------------------------------------

  group('VaultAuthRepositoryImpl.buildVaultUri', () {
    late VaultAuthRepositoryImpl repo;

    setUp(() {
      // A stub client that never runs — buildVaultUri is pure.
      final stub = MockClient((_) async => http.Response('', 200));
      repo = VaultAuthRepositoryImpl(stub, config);
    });

    test('appends segments to the origin without dropping its path prefix', () {
      final uri = repo.buildVaultUri(<String>['v1', 'sys', 'health']);
      expect(uri.scheme, 'https');
      expect(uri.host, 'vault.example.com');
      expect(uri.port, 8200);
      expect(uri.pathSegments, ['proxy', 'v1', 'sys', 'health']);
    });

    test('username with "@" is percent-encoded, not broken', () {
      final uri = repo.buildVaultUri(<String>[
        'v1',
        'auth',
        'ldap',
        'login',
        'alice@corp',
      ]);
      // `@` is a reserved sub-delim in the userinfo production but is a
      // valid `pchar` in the path — `Uri` may keep it literal. Either
      // way, the important guarantee is that it stays inside the final
      // path segment and does NOT get parsed as userinfo on the origin.
      expect(uri.pathSegments.last, 'alice@corp');
      expect(uri.host, 'vault.example.com');
      expect(uri.userInfo, '');
    });

    test('username with "%" is double-encoded to stay a single segment', () {
      final uri = repo.buildVaultUri(<String>[
        'v1',
        'auth',
        'ldap',
        'login',
        'user%20name',
      ]);
      // `pathSegments` preserves the decoded view.
      expect(uri.pathSegments.last, 'user%20name');
      // But the serialised URI must escape the `%` itself so round-tripping
      // back through Uri.parse yields the same decoded segment.
      expect(uri.toString(), contains('user%2520name'));
      final reparsed = Uri.parse(uri.toString());
      expect(reparsed.pathSegments.last, 'user%20name');
    });

    test('username with spaces is encoded as %20, not "+"', () {
      final uri = repo.buildVaultUri(<String>[
        'v1',
        'auth',
        'ldap',
        'login',
        'alice smith',
      ]);
      expect(uri.pathSegments.last, 'alice smith');
      expect(uri.toString(), contains('alice%20smith'));
    });

    test(
      'origin with NO trailing slash still yields the right segments',
      () async {
        await config.setVaultOrigin('https://vault.example.com:8200');
        final repoNoSlash = VaultAuthRepositoryImpl(
          MockClient((_) async => http.Response('', 200)),
          config,
        );
        final uri = repoNoSlash.buildVaultUri(<String>['v1', 'sys', 'health']);
        expect(uri.pathSegments, ['v1', 'sys', 'health']);
      },
    );
  });

  // ---------------------------------------------------------------------
  // loginWithLdap — validation + URL shape on the wire
  // ---------------------------------------------------------------------

  group('VaultAuthRepositoryImpl.loginWithLdap', () {
    test('empty username is rejected without issuing a request', () async {
      var called = false;
      final client = MockClient((_) async {
        called = true;
        return http.Response('', 200);
      });
      final repo = VaultAuthRepositoryImpl(client, config);

      final result = await repo.loginWithLdap(
        username: '',
        password: 'p',
        mountPath: 'ldap',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<VaultAuthFailure>()),
        (_) => fail('Should have failed validation.'),
      );
      expect(called, isFalse, reason: 'Validation must short-circuit IO.');
    });

    test('".." username is rejected without issuing a request', () async {
      var called = false;
      final client = MockClient((_) async {
        called = true;
        return http.Response('', 200);
      });
      final repo = VaultAuthRepositoryImpl(client, config);

      final result = await repo.loginWithLdap(
        username: '..',
        password: 'p',
        mountPath: 'ldap',
      );

      expect(result.isLeft(), isTrue);
      expect(called, isFalse);
    });

    test('mountPath containing "/" is rejected', () async {
      var called = false;
      final client = MockClient((_) async {
        called = true;
        return http.Response('', 200);
      });
      final repo = VaultAuthRepositoryImpl(client, config);

      final result = await repo.loginWithLdap(
        username: 'alice',
        password: 'p',
        mountPath: 'okta/../..',
      );

      expect(result.isLeft(), isTrue);
      expect(called, isFalse);
    });

    test(
      'legitimate username with "@corp" round-trips through a MockClient',
      () async {
        Uri? captured;
        final client = MockClient((request) async {
          captured = request.url;
          return http.Response(
            json.encode({
              'auth': {'client_token': 's.abc'},
            }),
            200,
          );
        });
        final repo = VaultAuthRepositoryImpl(client, config);

        final result = await repo.loginWithLdap(
          username: 'alice@corp',
          password: 'p',
          mountPath: 'ldap',
        );

        expect(result.isRight(), isTrue);
        expect(captured, isNotNull);
        expect(captured!.host, 'vault.example.com');
        expect(captured!.pathSegments.last, 'alice@corp');
        // Critical: the last segment must not be split, i.e. we must not
        // end up posting to /v1/auth/ldap/login/alice/corp.
        expect(captured!.pathSegments, [
          'proxy',
          'v1',
          'auth',
          'ldap',
          'login',
          'alice@corp',
        ]);
      },
    );

    test('empty mountPath defaults to "ldap"', () async {
      Uri? captured;
      final client = MockClient((request) async {
        captured = request.url;
        return http.Response(
          json.encode({
            'auth': {'client_token': 's.abc'},
          }),
          200,
        );
      });
      final repo = VaultAuthRepositoryImpl(client, config);

      await repo.loginWithLdap(username: 'alice', password: 'p', mountPath: '');

      expect(captured, isNotNull);
      expect(captured!.pathSegments, [
        'proxy',
        'v1',
        'auth',
        'ldap',
        'login',
        'alice',
      ]);
    });

    test(
      'non-200 error body does not leak stack info into the failure',
      () async {
        final client = MockClient((_) async {
          return http.Response(
            json.encode({
              'errors': ['permission denied'],
            }),
            403,
          );
        });
        final repo = VaultAuthRepositoryImpl(client, config);

        final result = await repo.loginWithLdap(
          username: 'alice',
          password: 'wrong',
          mountPath: 'ldap',
        );

        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<VaultAuthFailure>());
          expect(f.message, contains('permission denied'));
        }, (_) => fail('Should have failed'));
      },
    );
  });

  // ---------------------------------------------------------------------
  // loginWithToken — same URL hardening, no user-controlled segment
  // ---------------------------------------------------------------------

  group('VaultAuthRepositoryImpl.loginWithToken', () {
    test(
      'issues GET to /v1/auth/token/lookup-self with the provided token',
      () async {
        Uri? capturedUri;
        String? capturedHeader;
        final client = MockClient((request) async {
          capturedUri = request.url;
          capturedHeader = request.headers['X-Vault-Token'];
          return http.Response('', 200);
        });
        final repo = VaultAuthRepositoryImpl(client, config);

        final result = await repo.loginWithToken('s.xyz');

        expect(result.isRight(), isTrue);
        expect(capturedUri, isNotNull);
        expect(capturedUri!.pathSegments, [
          'proxy',
          'v1',
          'auth',
          'token',
          'lookup-self',
        ]);
        expect(capturedHeader, 's.xyz');
      },
    );

    test('maps 403 to VaultAuthFailure', () async {
      final client = MockClient((_) async => http.Response('', 403));
      final repo = VaultAuthRepositoryImpl(client, config);

      final result = await repo.loginWithToken('bad');
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<VaultAuthFailure>()),
        (_) => fail('Should have failed'),
      );
    });
  });
}
