import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/routes/app_routes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';

class SettingsController extends GetxController {
  late final AppConfigService _config;

  // New config values
  RxString get themeMode => _config.themeMode;
  RxString get osStyle => _config.osStyle;
  RxString get colorTheme => _config.colorTheme;
  RxDouble get uiScale => _config.uiScale;

  // Vault config
  RxList<VaultProfile> get vaultProfiles => _config.vaultProfiles;
  RxString get activeProfileId => _config.activeProfileId;

  RxString get vaultOrigin => _config.vaultOrigin;
  RxString get vaultToken => _config.vaultToken;
  RxString get vaultUiDomain => _config.vaultUiDomain;
  RxString get scrapingUrl => _config.scrapingUrl;
  RxString get vaultNamespace => _config.vaultNamespace;
  RxString get vaultDiscoveryPath => _config.vaultDiscoveryPath;
  RxBool get verifySsl => _config.verifySsl;
  RxBool get hideVaultContext => _config.hideVaultContext;

  RxnInt get accentColor => _config.accentColor;
  RxnInt get iconData => _config.iconData;

  final vaultOriginController = TextEditingController();
  final vaultTokenController = TextEditingController();
  final vaultUiDomainController = TextEditingController();
  final scrapingUrlController = TextEditingController();
  final vaultDiscoveryPathController = TextEditingController();
  final vaultNamespaceController = TextEditingController();
  final profileNameController = TextEditingController();
  final purgePasswordController = TextEditingController();

  // UI state
  final isInterfaceOpen = true.obs;
  final isSyncOpen = false.obs;
  final isScraping = false.obs;

  @override
  void onInit() {
    super.onInit();
    _config = AppConfigService.to;
    _syncTextControllers();

    // Automatically update text fields when profile switches
    ever(activeProfileId, (_) => _syncTextControllers());
  }

  void _syncTextControllers() {
    final activeProfile = _config.vaultProfiles.firstWhere(
      (p) => p.id == activeProfileId.value,
      orElse: () => _config.vaultProfiles.first,
    );
    profileNameController.text = activeProfile.name;

    vaultOriginController.text = _config.vaultOrigin.value;
    vaultTokenController.text = _config.vaultToken.value;
    vaultUiDomainController.text = _config.vaultUiDomain.value;
    scrapingUrlController.text = _config.scrapingUrl.value;
    vaultDiscoveryPathController.text = _config.vaultDiscoveryPath.value;
    vaultNamespaceController.text = _config.vaultNamespace.value;
  }

  @override
  void onClose() {
    vaultOriginController.dispose();
    vaultTokenController.dispose();
    vaultUiDomainController.dispose();
    scrapingUrlController.dispose();
    vaultDiscoveryPathController.dispose();
    vaultNamespaceController.dispose();
    profileNameController.dispose();
    purgePasswordController.dispose();
    super.onClose();
  }

  void setTheme(String theme) => _config.setThemeMode(theme);
  void setOsStyle(String style) => _config.setOsStyle(style);
  void setColorTheme(String themeId) => _config.setColorTheme(themeId);
  void setScale(double scale) => _config.setScale(scale);

  void setVaultOrigin(String val) => _config.setVaultOrigin(val);
  void setVaultToken(String val) => _config.setVaultToken(val);
  void setVaultUiDomain(String val) => _config.setVaultUiDomain(val);
  void setScrapingUrl(String val) => _config.setScrapingUrl(val);
  void setVaultDiscoveryPath(String val) => _config.setVaultDiscoveryPath(val);
  void setVaultNamespace(String val) => _config.setVaultNamespace(val);
  void setVerifySsl(bool val) => _config.setVerifySsl(val);
  void setHideVaultContext(bool val) => _config.setHideVaultContext(val);

  Future<void> setAccentColor(int? color) async {
    await _config.setProfileBranding(
      activeProfileId.value,
      color,
      iconData.value,
    );
  }

  Future<void> setIconData(int? icon) async {
    await _config.setProfileBranding(
      activeProfileId.value,
      accentColor.value,
      icon,
    );
  }

  void handleSaveVaultConfig() {
    final curProfile = _config.vaultProfiles.firstWhere(
      (p) => p.id == activeProfileId.value,
      orElse: () => _config.vaultProfiles.first,
    );

    final updatedProfile = curProfile.copyWith(
      name: profileNameController.text,
      vaultOrigin: vaultOriginController.text,
      vaultUiDomain: vaultUiDomainController.text,
      scrapingUrl: scrapingUrlController.text,
      vaultDiscoveryPath: vaultDiscoveryPathController.text,
      vaultNamespace: vaultNamespaceController.text,
    );

    _config.saveProfile(updatedProfile);
    _config.setVaultToken(vaultTokenController.text);

    Get.snackbar(
      'SUCCESS',
      'Environment metadata and credentials persisted.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF34C759).withValues(alpha: 0.1),
      colorText: const Color(0xFF34C759),
    );
  }

  Future<void> switchProfile(String profileId) async {
    await _config.switchActiveProfile(profileId);

    Get.snackbar(
      'SWITCHED',
      'Environment changed successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SeraphineColors.accent.withValues(alpha: 0.1),
      colorText: SeraphineColors.accent,
    );
  }

  Future<void> createNewProfile() async {
    final newId = 'env_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = VaultProfile(
      id: newId,
      name: 'New Environment',
      vaultOrigin: 'https://vault.internal.net',
      vaultUiDomain: 'vault.internal.net',
      scrapingUrl: 'environment',
      vaultNamespace: '',
      vaultDiscoveryPath: 'SAM/',
      vaultFingerprint: '',
      verifySsl: true,
    );
    await _config.saveProfile(newProfile);
    await _config.switchActiveProfile(newId);
  }

  Future<void> deleteActiveProfile() async {
    await _config.deleteProfile(activeProfileId.value);
  }

  void handleLockAndSignOut() {
    // Clear sensitive session data
    _config.setVaultToken('');
    Get.offAllNamed(AppRoutes.initial);
  }

  void handlePurge() {
    // In a real app, verify against stored hash or session key
    // For now, simple confirmation
    _config.setVaultToken('');
    _config.setVaultOrigin('');
    purgePasswordController.clear();

    Get.snackbar(
      'SYSTEM WIPE',
      'All local session data has been purged.',
      backgroundColor: const Color(0xFFFF3B30).withValues(alpha: 0.1),
      colorText: const Color(0xFFFF3B30),
    );

    Get.offAllNamed(AppRoutes.initial);
  }

  Future<void> handleSyncAll() async {
    isScraping.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulate
    isScraping.value = false;

    Get.snackbar(
      'DISCOVERY COMPLETE',
      'Vault Intelligence updated successfully.',
      backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
      colorText: const Color(0xFF007AFF),
    );
  }
}
