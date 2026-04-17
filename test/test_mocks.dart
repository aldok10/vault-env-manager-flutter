import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

base class FakeStorageService extends StorageService {
  final Map<String, String> _data = {};

  @override
  Future<StorageService> init() async {
    // Provide a default profile if none exists
    _data['vault_profiles'] =
        '[{"id":"default","name":"Test Profile","vaultOrigin":"https://vault.example.com","vaultUiDomain":"","scrapingUrl":"","vaultNamespace":"","vaultDiscoveryPath":"/sys/internal/ui/mounts","verifySsl":true}]';
    _data['active_profile_id'] = 'default';
    return this;
  }

  @override
  Future<String?> get(String key, {bool isSecure = false}) async => _data[key];

  @override
  Future<void> saveNormal(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> saveSecure(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key, {bool isSecure = true}) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

Future<AppConfigService> setupTestConfig({StorageService? storage}) async {
  final usedStorage = storage ?? FakeStorageService();
  if (storage == null) {
    await (usedStorage as FakeStorageService).init();
  }

  Get.put<StorageService>(usedStorage);

  final compute = ComputeService();
  await compute.init();
  Get.put(compute);

  final config = AppConfigService();
  await config.testInit(usedStorage);

  Get.put(config);

  return config;
}
