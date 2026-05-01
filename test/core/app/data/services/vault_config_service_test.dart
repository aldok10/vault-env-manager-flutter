import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_config_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

base class MigrationFakeStorageService extends StorageService {
  final Map<String, String> normalData = {};
  final Map<String, String> secureData = {};

  @override
  Future<StorageService> init() async {
    return this;
  }

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

  @override
  Future<void> clear() async {
    normalData.clear();
    secureData.clear();
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

  group('VaultConfigService Migration', () {
    test('init should migrate normal storage to secure storage', () async {
      // Arrange
      const String oldProfilesJson =
          '[{"id":"old_default","name":"Old Default Environment","vaultOrigin":"https://old-vault.example.com","vaultUiDomain":"","scrapingUrl":"","vaultNamespace":"","vaultDiscoveryPath":"SAM/","verifySsl":true}]';
      mockStorage.normalData['vault_profiles'] = oldProfilesJson;
      mockStorage.normalData['active_profile_id'] = 'old_default';

      // Ensure secure storage starts empty
      expect(mockStorage.secureData['vault_profiles'], isNull);
      expect(mockStorage.secureData['active_profile_id'], isNull);

      // Act
      await service.init({});

      // Assert
      // Data should be migrated to secure storage
      expect(mockStorage.secureData['vault_profiles'], isNotNull);
      expect(mockStorage.secureData['active_profile_id'], 'old_default');

      // Data should be deleted from normal storage
      expect(mockStorage.normalData['vault_profiles'], isNull);
      expect(mockStorage.normalData['active_profile_id'], isNull);

      // Observables should be populated
      expect(service.vaultProfiles.length, 1);
      expect(service.vaultProfiles.first.id, 'old_default');
      expect(service.activeProfileId.value, 'old_default');
      expect(service.vaultOrigin.value, 'https://old-vault.example.com');
    });

    test('init should use secure storage if migration is already done', () async {
      // Arrange
      const String newProfilesJson =
          '[{"id":"new_default","name":"New Default Environment","vaultOrigin":"https://new-vault.example.com","vaultUiDomain":"","scrapingUrl":"","vaultNamespace":"","vaultDiscoveryPath":"SAM/","verifySsl":true}]';
      mockStorage.secureData['vault_profiles'] = newProfilesJson;
      mockStorage.secureData['active_profile_id'] = 'new_default';

      // Secure data should override anything in normal data, though in a real case it shouldn't exist
      mockStorage.normalData['vault_profiles'] = '[{"id":"bad"}]';
      mockStorage.normalData['active_profile_id'] = 'bad';

      // Act
      await service.init({});

      // Assert
      expect(mockStorage.secureData['vault_profiles'], newProfilesJson);
      expect(mockStorage.secureData['active_profile_id'], 'new_default');

      // Observables should match secure data
      expect(service.vaultProfiles.length, 1);
      expect(service.vaultProfiles.first.id, 'new_default');
      expect(service.activeProfileId.value, 'new_default');
      expect(service.vaultOrigin.value, 'https://new-vault.example.com');
    });

    test('switchActiveProfile should save to secure storage', () async {
      // Arrange
      await service.init({}); // Creates default profile
      await service.createProfile('Profile 2', 'https://vault2.com');
      final newProfileId = service.vaultProfiles.last.id;

      // Ensure active ID in secure storage is currently 'default'
      expect(mockStorage.secureData['active_profile_id'], 'default');

      // Act
      await service.switchActiveProfile(newProfileId);

      // Assert
      expect(mockStorage.secureData['active_profile_id'], newProfileId);
      expect(mockStorage.normalData['active_profile_id'], isNull);
    });

    test('saveProfile should save to secure storage', () async {
      // Arrange
      await service.init({});
      final newProfile = VaultProfile(
        id: 'new_id',
        name: 'New Name',
        vaultOrigin: 'https://new-origin.com',
        vaultUiDomain: '',
        scrapingUrl: '',
        vaultNamespace: '',
        vaultDiscoveryPath: '',
        verifySsl: true,
      );

      // Act
      await service.saveProfile(newProfile);

      // Assert
      expect(mockStorage.secureData['vault_profiles'], contains('new_id'));
      expect(mockStorage.normalData['vault_profiles'], isNull);
    });
  });
}
