import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_config_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

class MigrationMockStorageService extends StorageService {
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
  group('VaultConfigService Migration Tests', () {
    late MigrationMockStorageService mockStorage;
    late VaultConfigService service;

    setUp(() async {
      Get.reset();

      final compute = ComputeService();
      await compute.init();
      Get.put(compute);

      mockStorage = MigrationMockStorageService();
      await mockStorage.init();
      Get.put<StorageService>(mockStorage);

      service = VaultConfigService();
      Get.put(service);
    });

    test('Migrates existing normal storage data to secure storage', () async {
      // Setup legacy insecure data
      final profilesJson =
          '[{"id":"old-profile","name":"Test Profile","vaultOrigin":"https://vault.example.com","vaultUiDomain":"","scrapingUrl":"","vaultNamespace":"","vaultDiscoveryPath":"/sys/internal/ui/mounts","verifySsl":true}]';

      mockStorage.normalData['vault_profiles'] = profilesJson;
      mockStorage.normalData['active_profile_id'] = 'old-profile';

      // Ensure secure storage is empty initially
      expect(mockStorage.secureData['vault_profiles'], isNull);
      expect(mockStorage.secureData['active_profile_id'], isNull);

      // Trigger initialization which should handle migration
      await service.init({});

      // Verify data is now in secure storage
      expect(mockStorage.secureData['vault_profiles'], isNotNull);
      expect(mockStorage.secureData['active_profile_id'], 'old-profile');

      // Verify normal storage has been cleared for these keys
      expect(mockStorage.normalData['vault_profiles'], isNull);
      expect(mockStorage.normalData['active_profile_id'], isNull);

      // Verify the parsed state reflects the migrated profile
      expect(service.vaultProfiles.length, 1);
      expect(service.vaultProfiles.first.id, 'old-profile');
      expect(service.activeProfileId.value, 'old-profile');
    });

    test('Uses secure storage exclusively for new saves', () async {
      await service.init({});

      // Act
      await service.createProfile('New Secure Profile', 'https://secure.example.com');

      // Check storage usage
      expect(mockStorage.normalData['vault_profiles'], isNull);
      expect(mockStorage.secureData['vault_profiles'], isNotNull);
      expect(mockStorage.secureData['vault_profiles']!.contains('New Secure Profile'), isTrue);
    });
  });
}
