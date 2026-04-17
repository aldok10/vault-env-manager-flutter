import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/appearance_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/security_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/workbench_config_service.dart';
import 'package:vault_env_manager/src/features/workbench/domain/entities/secret_config.dart';
import 'package:vault_env_manager/src/shared/mixins/hydrated_mixin.dart';
import 'package:vault_env_manager/src/shared/utils/env_parser.dart';

import '../mixins/appearance_facade_mixin.dart';
import '../mixins/security_facade_mixin.dart';
import '../mixins/vault_facade_mixin.dart';
import '../mixins/workbench_facade_mixin.dart';

class AppConfigService extends GetxService
    with
        HydratedMixin,
        VaultFacadeMixin,
        AppearanceFacadeMixin,
        WorkbenchFacadeMixin,
        SecurityFacadeMixin {
  static AppConfigService get to => Get.find();

  @override
  String get storageKey => 'app_facade_config';

  StorageService get _storage => Get.find<StorageService>();

  // Initialized sub-services
  final _vault = VaultConfigService();
  final _appearance = AppearanceConfigService();
  final _workbench = WorkbenchConfigService();
  final _security = SecurityConfigService();

  // Redirecting Getters for UI compatibility
  RxString get themeMode => _appearance.themeMode;
  RxString get osStyle => _appearance.osStyle;
  RxDouble get uiScale => _appearance.uiScale;
  RxString get colorTheme => _appearance.colorTheme;
  bool get isDark => _appearance.isDark;

  RxList<VaultProfile> get vaultProfiles => _vault.vaultProfiles;
  RxString get activeProfileId => _vault.activeProfileId;
  RxString get vaultOrigin => _vault.vaultOrigin;
  RxString get vaultToken => _vault.vaultToken;
  RxString get vaultUiDomain => _vault.vaultUiDomain;
  RxString get scrapingUrl => _vault.scrapingUrl;
  RxString get vaultNamespace => _vault.vaultNamespace;
  RxString get vaultDiscoveryPath => _vault.vaultDiscoveryPath;
  RxString get vaultFingerprint => _vault.vaultFingerprint;
  RxBool get verifySsl => _vault.verifySsl;

  RxBool get hideVaultContext => _workbench.hideVaultContext;
  RxBool get isDashboardCollapsed => _workbench.isDashboardCollapsed;
  RxBool get isFlipped => _workbench.isFlipped;
  RxDouble get editorHeight => _workbench.editorHeight;
  RxDouble get editorWidthPercent => _workbench.editorWidthPercent;
  RxList<SecretConfig> get secretConfigs => _workbench.secretConfigs;
  RxnInt get accentColor => _vault.accentColor;
  RxnInt get iconData => _vault.iconData;

  RxString get cipherPass => _security.cipherPass;

  Future<AppConfigService> init() async {
    final envDefaults = await _loadEnvDefaults();

    // Legacy Migration (move global config to default profile)
    await _migrateLegacyData();

    // Cascading Initialization
    await _vault.init(envDefaults);
    final String activeId = _vault.activeProfileId.value;

    await _appearance.init(envDefaults);
    await _workbench.init(activeId);
    await _security.init(activeId);

    // Register delegates
    Get.put(_vault, permanent: true);
    Get.put(_appearance, permanent: true);
    Get.put(_workbench, permanent: true);
    Get.put(_security, permanent: true);

    // Listen to profile switches to re-initialize dependent services
    _vault.onProfileSwitched.listen(_onVaultProfileSwitched);

    debugPrint('AppConfigService: Facade ready.');
    return this;
  }

  Future<Map<String, String>> _loadEnvDefaults() async {
    try {
      final envString = await rootBundle.loadString('assets/.env');
      return EnvParser.parse(envString);
    } catch (e) {
      return {};
    }
  }

  // Tenant-Aware Switcher
  @override
  Future<void> switchVault(String profileId) async {
    // 1. Perform Hard Reset on state components
    _workbench.secretConfigs.clear();

    // 2. Switch Metadata & Credentials
    await _vault.switchActiveProfile(profileId);

    // 3. Re-initialize dependent services
    await _workbench.init(profileId);
    await _security.init(profileId);
    await updateHydrated();
  }

  // Alias for backward compatibility
  Future<void> switchActiveProfile(String profileId) => switchVault(profileId);

  Future<void> setProfileBranding(String id, int? color, int? icon) =>
      _vault.setProfileBranding(id, color, icon);

  // Backward compatibility delegates
  Future<void> setVaultOrigin(String val) async {
    final sanitized = _sanitizeUrl(val);
    await _vault.updateActiveProfileMetadata(vaultOrigin: sanitized);
  }

  Future<void> setVaultToken(String val) async {
    _vault.vaultToken.value = val;
    await _storage.saveSecure(
      'vault_token_${_vault.activeProfileId.value}',
      val,
    );
  }

  Future<void> setVaultDiscoveryPath(String path) async {
    await _vault.updateActiveProfileMetadata(vaultDiscoveryPath: path);
  }

  Future<void> setVaultUiDomain(String domain) =>
      _vault.updateActiveProfileMetadata(vaultUiDomain: domain);
  Future<void> setScrapingUrl(String url) =>
      _vault.updateActiveProfileMetadata(scrapingUrl: url);
  Future<void> setVaultNamespace(String val) =>
      _vault.updateActiveProfileMetadata(vaultNamespace: val);
  Future<void> setVaultFingerprint(String val) =>
      _vault.updateActiveProfileMetadata(vaultFingerprint: val);
  Future<void> setVerifySsl(bool val) =>
      _vault.updateActiveProfileMetadata(verifySsl: val);

  Future<void> saveProfile(VaultProfile profile) => _vault.saveProfile(profile);
  Future<void> deleteProfile(String profileId) =>
      _vault.deleteProfile(profileId);

  Future<void> setThemeMode(String mode) => _appearance.setThemeMode(mode);
  Future<void> setColorTheme(String themeId) =>
      _appearance.setColorTheme(themeId);
  @override
  Future<void> setOsStyle(String style) => _appearance.setOsStyle(style);
  @override
  Future<void> setScale(double scale) => _appearance.setScale(scale);

  Future<void> setHideVaultContext(bool hide) =>
      _workbench.setHideVaultContext(hide);
  Future<void> setDashboardCollapsed(bool collapsed) =>
      _workbench.setDashboardCollapsed(collapsed);
  Future<void> setIsFlipped(bool flipped) => _workbench.setIsFlipped(flipped);
  Future<void> setEditorHeight(double height) =>
      _workbench.setEditorHeight(height);
  Future<void> setEditorWidthPercent(double percent) =>
      _workbench.setEditorWidthPercent(percent);

  Future<void> saveSecretConfig(SecretConfig config) =>
      _workbench.saveSecretConfig(config);
  Future<void> deleteSecretConfig(String id) =>
      _workbench.deleteSecretConfig(id);

  Future<void> testInit(StorageService storage) async {
    await _migrateLegacyData();
    // For unit tests, we initialize sub-services with empty defaults
    await _vault.init({});
    final activeId = _vault.activeProfileId.value;

    await _appearance.init({});
    await _workbench.init(activeId);
    await _security.init(activeId);

    Get.put(_vault);
    Get.put(_appearance);
    Get.put(_workbench);
    Get.put(_security);
  }

  Future<void> _migrateLegacyData() async {
    const String oldKey = 'secret_configs';
    const String defaultKey = 'secret_configs_default';

    final legacyData = await _storage.get(oldKey, isSecure: true);
    if (legacyData != null && legacyData.isNotEmpty) {
      final newData = await _storage.get(defaultKey, isSecure: true);
      if (newData == null || newData.isEmpty) {
        debugPrint(
          'AppConfigService: Migrating legacy global config to default profile.',
        );
        await _storage.saveSecure(defaultKey, legacyData);
      }
      // Cleanup to prevent redundant checks
      await _storage.saveSecure(oldKey, '');
    }
  }

  void _onVaultProfileSwitched(String profileId) {
    _workbench.init(profileId);
    _security.init(profileId);
  }

  String _sanitizeUrl(String val) {
    var s = val.trim();
    if (s.isEmpty) return s;

    // 1. Ensure a protocol is present
    if (!s.contains('://')) {
      s = 'https://$s';
    }

    // 2. Enforce HTTPS for non-local origins
    if (s.startsWith('http://')) {
      final uri = Uri.tryParse(s);
      if (uri != null && uri.hasAuthority) {
        final host = uri.host.toLowerCase();
        final isLocal =
            host == 'localhost' ||
            host == '127.0.0.1' ||
            host == '::1' ||
            host.endsWith('.local');

        if (!isLocal) {
          s = 'https://${s.substring(7)}';
        }
      }
    }

    // 3. Strip trailing slashes
    if (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }

    return s;
  }

  @override
  Map<String, dynamic> toJson() => {'activeProfile': activeProfileId.value};

  @override
  void fromJson(Map<String, dynamic> json) {
    // Session state recovery if needed
  }
}
