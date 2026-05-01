import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_config_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

class MigrationFakeStorageService extends StorageService {
  final Map<String, String> secureData = {};
  final Map<String, String> normalData = {};

  @override
  Future<StorageService> init() async => this;

  @override
  Future<String?> get(String key, {bool isSecure = true}) async {
    return isSecure ? secureData[key] : normalData[key];
  }

  @override
  Future<void> saveNormal(String key, String value) async {
    normalData[key] = value;
  }

  @override
  Future<void> saveSecure(String key, String value) async {
    secureData[key] = value;
  }

  @override
  Future<void> delete(String key, {bool isSecure = true}) async {
    if (isSecure) {
      secureData.remove(key);
    } else {
      normalData.remove(key);
    }
  }
}

void main() {
  late VaultConfigService service;
  late MigrationFakeStorageService mockStorage;

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    mockStorage = MigrationFakeStorageService();
    Get.put<StorageService>(mockStorage);

    final compute = ComputeService();
    await compute.init();
    Get.put(compute);

    service = VaultConfigService();
  });

  group('VaultConfigService Migration and Security', () {
    test(
      'init should create default profile in SECURE storage when empty',
      () async {
        await service.init({});

        expect(service.vaultProfiles, isNotEmpty);
        expect(service.activeProfileId.value, 'default');

        // Should be in secure storage
        expect(mockStorage.secureData['vault_profiles'], isNotNull);
        expect(mockStorage.secureData['active_profile_id'], 'default');

        // Should NOT be in normal storage
        expect(mockStorage.normalData['vault_profiles'], isNull);
        expect(mockStorage.normalData['active_profile_id'], isNull);
      },
    );

    test('init should migrate data from normal to secure storage', () async {
      // Arrange: Put data in normal storage (simulating old version)
      final profilesJson =
          '[{"id":"old","name":"Old Profile","vaultOrigin":"https://old.com","vaultUiDomain":"","scrapingUrl":"","vaultNamespace":"","vaultDiscoveryPath":"","verifySsl":true}]';
      mockStorage.normalData['vault_profiles'] = profilesJson;
      mockStorage.normalData['active_profile_id'] = 'old';

      // Act
      await service.init({});

      // Assert
      expect(service.activeProfileId.value, 'old');
      expect(service.vaultProfiles.first.id, 'old');

      // Should have migrated to secure storage
      expect(mockStorage.secureData['vault_profiles'], contains('old'));
      expect(mockStorage.secureData['active_profile_id'], 'old');

      // Should have been deleted from normal storage
      expect(mockStorage.normalData['vault_profiles'], isNull);
      expect(mockStorage.normalData['active_profile_id'], isNull);
    });

    test('saveProfile should persist to SECURE storage', () async {
      await service.init({});
      final newProfile = VaultProfile(
        id: 'new',
        name: 'New Profile',
        vaultOrigin: 'https://new.com',
        vaultUiDomain: '',
        scrapingUrl: '',
        vaultNamespace: '',
        vaultDiscoveryPath: '',
        verifySsl: true,
      );

      await service.saveProfile(newProfile);

      expect(mockStorage.secureData['vault_profiles'], contains('new'));
      expect(mockStorage.normalData['vault_profiles'], isNull);
    });

    test(
      'switchActiveProfile should persist active ID to SECURE storage',
      () async {
        await service.init({});
        final newProfile = VaultProfile(
          id: 'new',
          name: 'New Profile',
          vaultOrigin: 'https://new.com',
          vaultUiDomain: '',
          scrapingUrl: '',
          vaultNamespace: '',
          vaultDiscoveryPath: '',
          verifySsl: true,
        );
        await service.saveProfile(newProfile);

        await service.switchActiveProfile('new');

        expect(mockStorage.secureData['active_profile_id'], 'new');
        expect(mockStorage.normalData['active_profile_id'], isNull);
      },
    );
  });
}
