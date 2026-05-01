import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_config_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

base class SeparatedFakeStorageService extends StorageService {
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
  late SeparatedFakeStorageService storage;
  late VaultConfigService service;

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    storage = SeparatedFakeStorageService();
    Get.put<StorageService>(storage);

    final compute = ComputeService();
    await compute.init();
    Get.put(compute);

    service = VaultConfigService();
    Get.put(service);
  });

  test('migrates vault_profiles from normal to secure storage on init', () async {
    // Arrange: seed normal storage with a profile, secure storage empty
    const profilesJson =
        '[{"id":"migrated_profile","name":"Migrated Profile","vaultOrigin":"https://migrated.com","vaultUiDomain":"","scrapingUrl":"","vaultNamespace":"","vaultDiscoveryPath":"/","verifySsl":true}]';
    storage.normalData['vault_profiles'] = profilesJson;

    // Act: initialize service
    await service.init({});

    // Assert: should load the profile
    expect(service.vaultProfiles.length, 1);
    expect(service.vaultProfiles.first.id, 'migrated_profile');

    // Should have moved to secure storage
    expect(storage.secureData.containsKey('vault_profiles'), isTrue);
    expect(storage.secureData['vault_profiles'], profilesJson);

    // Should have deleted from normal storage
    expect(storage.normalData.containsKey('vault_profiles'), isFalse);
  });

  test('saves new profiles to secure storage', () async {
    await service.init({});

    await service.createProfile('New Profile', 'https://new.com');

    expect(storage.secureData.containsKey('vault_profiles'), isTrue);
    expect(storage.normalData.containsKey('vault_profiles'), isFalse);
  });
}
