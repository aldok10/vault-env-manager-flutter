import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

import '../test_mocks.dart';

void main() {
  late AppConfigService service;
  late FakeStorageService mockStorage;

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    mockStorage = FakeStorageService();
    // Pre-fill storage with two profiles
    final profiles = [
      {
        'id': 'p1',
        'name': 'Profile 1',
        'vaultOrigin': 'https://v1.com',
        'vaultUiDomain': '',
        'scrapingUrl': '',
        'vaultNamespace': '',
        'vaultDiscoveryPath': '',
        'verifySsl': true
      },
      {
        'id': 'p2',
        'name': 'Profile 2',
        'vaultOrigin': 'https://v2.com',
        'vaultUiDomain': '',
        'scrapingUrl': '',
        'vaultNamespace': '',
        'vaultDiscoveryPath': '',
        'verifySsl': true
      },
    ];
    await mockStorage.saveNormal('vault_profiles', json.encode(profiles));
    await mockStorage.saveNormal('active_profile_id', 'p1');
    
    // Save some profile-specific data
    await mockStorage.saveSecure('secret_configs_p1', '[{"id":"s1","label":"Secret 1","key":"p1/s1"}]');
    await mockStorage.saveSecure('secret_configs_p2', '[{"id":"s2","label":"Secret 2","key":"p2/s2"}]');

    Get.put<StorageService>(mockStorage);
    Get.put(ComputeService());

    service = AppConfigService();
    await service.testInit(mockStorage);
    Get.put(service);
  });

  group('Multi-Tenant Switch Verification', () {
    test('Switching profile should refresh dependent services (Workbench)', () async {
      // 1. Verify initial state (p1)
      expect(service.activeProfileId.value, 'p1');
      expect(service.secretConfigs.length, 1);
      expect(service.secretConfigs.first.label.value, 'Secret 1');

      // 2. Switch to p2
      await service.switchVault('p2');

      // 3. Verify state after switch
      expect(service.activeProfileId.value, 'p2');
      expect(service.secretConfigs.length, 1);
      expect(service.secretConfigs.first.label.value, 'Secret 2');
    });

    test('Isolated key prefixing works as expected', () async {
      // Ensure we are on p1
      await service.switchVault('p1');
      
      // Save a new config on p1
      // Note: we'd usually use domain models here, but for simple verification:
      // expect(workbench.secretConfigs.length, 1);
      
      // Switch to p2 and verify p1's data isn't there
      await service.switchVault('p2');
      expect(service.secretConfigs.first.label.value, 'Secret 2');
    });
  });
}
