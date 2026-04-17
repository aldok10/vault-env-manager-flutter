import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/features/workbench/data/repositories/vault_repository_impl.dart';

import '../../../../test_mocks.dart';

base class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late AppConfigService config;
  late VaultRepositoryImpl repository;
  late MockHttpClient mockClient;
  late FakeStorageService mockStorage;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    mockStorage = FakeStorageService();
    Get.put<StorageService>(mockStorage);

    config = await setupTestConfig();
    mockClient = MockHttpClient();
    repository = VaultRepositoryImpl(mockClient, config);
  });

  tearDown(() {
    Get.reset();
  });

  group('Security Validation Tests', () {
    group('HTTPS Enforcement', () {
      test('should enforce HTTPS for non-local origins', () async {
        await config.setVaultOrigin('http://vault.internal.com');
        expect(config.vaultOrigin.value, 'https://vault.internal.com');

        await config.setVaultOrigin('vault.secure.com');
        expect(config.vaultOrigin.value, 'https://vault.secure.com');
      });

      test('should allow HTTP for localhost and 127.0.0.1', () async {
        await config.setVaultOrigin('http://localhost:8200');
        expect(config.vaultOrigin.value, 'http://localhost:8200');

        await config.setVaultOrigin('http://127.0.0.1:8201');
        expect(config.vaultOrigin.value, 'http://127.0.0.1:8201');
      });

      test('should strip trailing slashes', () async {
        await config.setVaultOrigin('https://vault.example.com/');
        expect(config.vaultOrigin.value, 'https://vault.example.com');
      });

      test('should block localhost bypass attempts', () async {
        await config.setVaultOrigin('http://fake-localhost.com');
        expect(config.vaultOrigin.value, 'https://fake-localhost.com');

        await config.setVaultOrigin('http://localhost.attacker.com');
        expect(config.vaultOrigin.value, 'https://localhost.attacker.com');

        await config.setVaultOrigin('http://127.0.0.1.xip.io');
        expect(config.vaultOrigin.value, 'https://127.0.0.1.xip.io');
      });

      test('should handle empty input gracefully', () async {
        await config.setVaultOrigin('');
        expect(config.vaultOrigin.value, '');
      });
    });

    group('Path Traversal Protection', () {
      test('should block path traversal via getSecret', () async {
        final result = await repository.getSecret('../../sys/auth');
        expect(result.isLeft(), true);
      });

      test('should block path traversal via listKeys', () async {
        final result = await repository.listKeys('metadata/../config');
        expect(result.isLeft(), true);
      });
    });
  });
}
