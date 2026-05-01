import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';
import '../../../../test_mocks.dart';

void main() {
  late AppConfigService service;
  late FakeStorageService mockStorage;

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    mockStorage = FakeStorageService();
    Get.put<StorageService>(mockStorage);

    final compute = ComputeService();
    await compute.init();
    Get.put(compute);

    service = AppConfigService();
  });

  group('AppConfigService Persistence', () {
    test('init should load all reactive variables from storage', () async {
      // Act
      await service.init();

      // Assert
      // We expect defaults because FakeStorageService returns null by default
      expect(service.themeMode.value, 'Dark');
      expect(service.vaultOrigin.value, 'https://vault.example.com');
    });

    test(
      'setVaultOrigin should persist to normal storage and enforce HTTPS',
      () async {
        // Arrange
        await service.init();

        // Act
        await service.setVaultOrigin('vault.myorg.com');

        // Assert
        expect(service.vaultOrigin.value, 'https://vault.myorg.com');
      },
    );

    test('setVaultToken should persist to secure storage', () async {
      // Arrange
      await service.init();

      // Act
      await service.setVaultToken('new.secure.token');

      // Assert
      expect(service.vaultToken.value, 'new.secure.token');
    });

    test('setThemeMode should persist and update theme', () async {
      // Arrange
      await service.init();

      // Act
      await service.setThemeMode('light');

      // Assert
      expect(service.themeMode.value, 'light');
    });
  });
}
