import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

class VaultConfigService extends GetxService {
  static VaultConfigService get to => Get.find();

  StorageService get _storage => Get.find<StorageService>();

  // Storage Keys
  static const String _kVaultProfiles = 'vault_profiles';
  static const String _kActiveProfileId = 'active_profile_id';
  static const String _kCipherPass = 'cipher_pass';

  // Observable properties
  final RxList<VaultProfile> vaultProfiles = <VaultProfile>[].obs;
  final RxString activeProfileId = ''.obs;

  final RxString vaultOrigin = ''.obs;
  final RxString vaultToken = ''.obs;
  final RxString vaultUiDomain = ''.obs;
  final RxString scrapingUrl = ''.obs;
  final RxString vaultNamespace = ''.obs;
  final RxString vaultDiscoveryPath = ''.obs;
  final RxString vaultFingerprint = ''.obs;
  final RxBool verifySsl = true.obs;
  final RxString cipherPass = ''.obs;

  // Branding Observables
  final RxnInt accentColor = RxnInt();
  final RxnInt iconData = RxnInt();

  // Profile shift notification for other services
  final _profileSwitchController = StreamController<String>.broadcast();
  Stream<String> get onProfileSwitched => _profileSwitchController.stream;

  Future<VaultConfigService> init(Map<String, String> envDefaults) async {
    // Attempt to load from secure storage first
    String? profilesJson = await _storage.get(_kVaultProfiles, isSecure: true);
    bool migratedProfiles = false;

    // Migration: try normal storage if not found in secure
    if (profilesJson == null || profilesJson.isEmpty) {
      profilesJson = await _storage.get(_kVaultProfiles, isSecure: false);
      if (profilesJson != null && profilesJson.isNotEmpty) {
        migratedProfiles = true;
      }
    }

    if (profilesJson != null && profilesJson.isNotEmpty) {
      try {
        final List<dynamic> list = await ComputeService.to.parseJsonList(
          profilesJson,
        );
        final profiles = <VaultProfile>[];
        for (final item in list) {
          VaultProfile.fromMapSecure(item).fold(
            (failure) => debugPrint(
              'VaultConfigService: Profile validation failed: ${failure.message}',
            ),
            (profile) => profiles.add(profile),
          );
        }
        vaultProfiles.value = profiles;

        if (migratedProfiles) {
          await _persistProfiles();
          await _storage.delete(_kVaultProfiles, isSecure: false);
          debugPrint(
            'VaultConfigService: Migrated vault profiles to secure storage.',
          );
        }
      } catch (e) {
        debugPrint('VaultConfigService: Error parsing vault profiles: $e');
      }
    }

    if (vaultProfiles.isEmpty) {
      await _initializeDefaultProfile(envDefaults);
    } else {
      // Attempt to load active profile ID from secure storage
      String? activeId = await _storage.get(_kActiveProfileId, isSecure: true);
      if (activeId == null || activeId.isEmpty) {
        // Migration: try normal storage
        activeId = await _storage.get(_kActiveProfileId, isSecure: false);
        if (activeId != null && activeId.isNotEmpty) {
          await _storage.saveSecure(_kActiveProfileId, activeId);
          await _storage.delete(_kActiveProfileId, isSecure: false);
          debugPrint(
            'VaultConfigService: Migrated active profile ID to secure storage.',
          );
        }
      }
      activeProfileId.value = activeId ?? vaultProfiles.first.id;
    }

    cipherPass.value = await _storage.get(_kCipherPass, isSecure: true) ?? '';

    await switchActiveProfile(activeProfileId.value);
    return this;
  }

  Future<void> _initializeDefaultProfile(
    Map<String, String> envDefaults,
  ) async {
    final defaultProfile = VaultProfile(
      id: 'default',
      name: 'Default Environment',
      vaultOrigin: envDefaults['VAULT_ORIGIN'] ?? 'https://vault.example.com',
      vaultUiDomain: envDefaults['VAULT_UI_DOMAIN'] ?? 'vault.example.com',
      scrapingUrl: envDefaults['SCRAPING_URL'] ?? 'environment/metadata/',
      vaultNamespace: envDefaults['VAULT_NAMESPACE'] ?? '',
      vaultDiscoveryPath: envDefaults['VAULT_DISCOVERY_PATH'] ?? 'SAM/',
      vaultFingerprint: envDefaults['VAULT_FINGERPRINT'] ?? '',
      verifySsl: (envDefaults['VERIFY_SSL'] ?? 'true') == 'true',
    );
    vaultProfiles.add(defaultProfile);
    await _persistProfiles();
    activeProfileId.value = 'default';
    await _storage.saveSecure(_kActiveProfileId, 'default');
  }

  Future<void> switchActiveProfile(String profileId) async {
    if (vaultProfiles.isEmpty) return;

    try {
      final profile = vaultProfiles.firstWhere(
        (p) => p.id == profileId,
        orElse: () => vaultProfiles.first,
      );

      activeProfileId.value = profile.id;
      await _storage.saveSecure(_kActiveProfileId, profile.id);

      vaultOrigin.value = profile.vaultOrigin;
      vaultUiDomain.value = profile.vaultUiDomain;
      scrapingUrl.value = profile.scrapingUrl;
      vaultNamespace.value = profile.vaultNamespace;
      vaultDiscoveryPath.value = profile.vaultDiscoveryPath;
      vaultFingerprint.value = profile.vaultFingerprint;
      verifySsl.value = profile.verifySsl;

      // Update branding
      accentColor.value = profile.accentColor;
      iconData.value = profile.iconData;

      vaultToken.value =
          await _storage.get('vault_token_${profile.id}', isSecure: true) ?? '';

      _profileSwitchController.add(profile.id);
    } catch (e) {
      debugPrint('VaultConfigService: Failed to switch profile: $e');
    }
  }

  Future<void> saveProfile(VaultProfile profile) async {
    final index = vaultProfiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      vaultProfiles[index] = profile;
    } else {
      vaultProfiles.add(profile);
    }
    await _persistProfiles();

    if (activeProfileId.value == profile.id) {
      await switchActiveProfile(profile.id);
    }
  }

  Future<void> deleteProfile(String profileId) async {
    if (vaultProfiles.length <= 1) return;
    vaultProfiles.removeWhere((p) => p.id == profileId);
    await _persistProfiles();
    await _storage.saveSecure('vault_token_$profileId', '');

    if (activeProfileId.value == profileId) {
      await switchActiveProfile(vaultProfiles.first.id);
    }
  }

  Future<void> updateActiveProfileMetadata({
    String? name,
    String? vaultOrigin,
    String? vaultUiDomain,
    String? scrapingUrl,
    String? vaultNamespace,
    String? vaultDiscoveryPath,
    String? vaultFingerprint,
    bool? verifySsl,
    int? newAccentColor,
    int? newIconData,
  }) async {
    final idx = vaultProfiles.indexWhere((p) => p.id == activeProfileId.value);
    if (idx != -1) {
      vaultProfiles[idx] = vaultProfiles[idx].copyWith(
        name: name,
        vaultOrigin: vaultOrigin,
        vaultUiDomain: vaultUiDomain,
        scrapingUrl: scrapingUrl,
        vaultNamespace: vaultNamespace,
        vaultDiscoveryPath: vaultDiscoveryPath,
        vaultFingerprint: vaultFingerprint,
        verifySsl: verifySsl,
        accentColor: newAccentColor,
        iconData: newIconData,
      );
      await _persistProfiles();

      // Update observables if it's the active one
      if (activeProfileId.value == vaultProfiles[idx].id) {
        final p = vaultProfiles[idx];
        this.vaultOrigin.value = p.vaultOrigin;
        this.vaultUiDomain.value = p.vaultUiDomain;
        this.scrapingUrl.value = p.scrapingUrl;
        this.vaultNamespace.value = p.vaultNamespace;
        this.vaultDiscoveryPath.value = p.vaultDiscoveryPath;
        this.vaultFingerprint.value = p.vaultFingerprint;
        this.verifySsl.value = p.verifySsl;
        accentColor.value = p.accentColor;
        iconData.value = p.iconData;
      }

      vaultProfiles.refresh();
    }
  }

  Future<void> setProfileBranding(String id, int? color, int? icon) async {
    final idx = vaultProfiles.indexWhere((p) => p.id == id);
    if (idx != -1) {
      vaultProfiles[idx] = vaultProfiles[idx].copyWith(
        accentColor: color,
        iconData: icon,
      );
      await _persistProfiles();

      if (activeProfileId.value == id) {
        accentColor.value = color;
        iconData.value = icon;
      }
    }
  }

  Future<void> _persistProfiles() async {
    final data = vaultProfiles.map((e) => e.toMap()).toList();
    final jsonString = await ComputeService.to.stringifyJson(data);
    await _storage.saveSecure(_kVaultProfiles, jsonString);
  }

  Future<void> setCipherPass(String pass) async {
    cipherPass.value = pass;
    await _storage.saveSecure(_kCipherPass, pass);
  }

  Future<void> switchProfile(String profileId) =>
      switchActiveProfile(profileId);

  Future<void> createProfile(
    String name,
    String vaultOrigin, {
    int? color,
    int? icon,
  }) async {
    final profile = VaultProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      vaultOrigin: vaultOrigin,
      vaultUiDomain: '',
      scrapingUrl: '',
      vaultNamespace: '',
      vaultDiscoveryPath: '',
      verifySsl: true,
      accentColor: color,
      iconData: icon,
    );
    await saveProfile(profile);
  }
}
