import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/features/workbench/data/models/secret_config_model.dart';
import 'package:vault_env_manager/src/features/workbench/domain/entities/secret_config.dart';

class WorkbenchConfigService extends GetxService {
  static WorkbenchConfigService get to => Get.find();

  StorageService get _storage => Get.find<StorageService>();
  String _activeProfileId = 'default';

  static const String _kHideVaultContext = 'hide_vault_context';
  static const String _kEditorHeight = 'editor_height';
  static const String _kEditorWidthPercent = 'editor_width_percent';
  static const String _kDashboardCollapsed = 'dashboard_collapsed';
  static const String _kIsFlipped = 'is_flipped';
  static const String _kSecretConfigsBase = 'secret_configs';
  static const String _kEditorFont = 'editor_font';
  static const String _kTabSize = 'tab_size';
  static const String _kAutoSave = 'auto_save';

  final RxBool hideVaultContext = false.obs;
  final RxBool isDashboardCollapsed = false.obs;
  final RxBool isFlipped = false.obs;
  final RxDouble editorHeight = 500.0.obs;
  final RxDouble editorWidthPercent = 50.0.obs;
  final RxList<SecretConfig> secretConfigs = <SecretConfig>[].obs;
  final RxString editorFont = 'JetBrains Mono'.obs;
  final RxInt tabSize = 2.obs;
  final RxBool autoSave = true.obs;

  String _getProfileKey(String key) => '${key}_$_activeProfileId';

  Future<WorkbenchConfigService> init(String profileId) async {
    _activeProfileId = profileId;

    debugPrint('WorkbenchConfigService: Initializing for profile: $profileId');

    // Global UI Settings
    hideVaultContext.value =
        (await _storage.get(_kHideVaultContext, isSecure: false) ?? 'false') ==
            'true';
    editorHeight.value = double.tryParse(
          await _storage.get(_kEditorHeight, isSecure: false) ?? '500.0',
        ) ??
        500.0;
    editorWidthPercent.value = double.tryParse(
          await _storage.get(_kEditorWidthPercent, isSecure: false) ?? '50.0',
        ) ??
        50.0;

    // Profile-Specific UI Settings (Isolation)
    isDashboardCollapsed.value = (await _storage.get(
              _getProfileKey(_kDashboardCollapsed),
              isSecure: false,
            ) ??
            'false') ==
        'true';
    isFlipped.value =
        (await _storage.get(_getProfileKey(_kIsFlipped), isSecure: false) ??
                'false') ==
            'true';

    editorFont.value =
        await _storage.get(_getProfileKey(_kEditorFont), isSecure: false) ??
            'JetBrains Mono';
    tabSize.value = int.tryParse(
          await _storage.get(_getProfileKey(_kTabSize), isSecure: false) ?? '2',
        ) ??
        2;
    autoSave.value =
        (await _storage.get(_getProfileKey(_kAutoSave), isSecure: false) ??
                'true') ==
            'true';

    // Profile-Specific Secret Configs
    final configsJson = await _storage.get(
      _getProfileKey(_kSecretConfigsBase),
      isSecure: true,
    );

    // Fallback/Migration: If new profile is 'default' and empty, try loading legacy global key
    var finalJson = configsJson;
    if (profileId == 'default' && (finalJson == null || finalJson.isEmpty)) {
      final legacyJson = await _storage.get(
        _kSecretConfigsBase,
        isSecure: true,
      );
      if (legacyJson != null && legacyJson.isNotEmpty) {
        debugPrint(
          'WorkbenchConfigService: Migrating legacy global configs...',
        );
        finalJson = legacyJson;
        // Save to profile-specific key immediately
        await _storage.saveSecure(
          _getProfileKey(_kSecretConfigsBase),
          finalJson,
        );
      }
    }

    if (finalJson != null && finalJson.isNotEmpty) {
      try {
        final List<dynamic> list = json.decode(finalJson);
        secretConfigs.value =
            list.map((e) => SecretConfigModel.fromMap(e).toDomain()).toList();
      } catch (e) {
        debugPrint('WorkbenchConfigService: Error parsing secret configs: $e');
        secretConfigs.clear();
      }
    } else {
      secretConfigs.clear();
    }

    return this;
  }

  Future<void> setHideVaultContext(bool hide) async {
    hideVaultContext.value = hide;
    await _storage.saveNormal(_kHideVaultContext, hide.toString());
  }

  Future<void> setDashboardCollapsed(bool collapsed) async {
    isDashboardCollapsed.value = collapsed;
    await _storage.saveNormal(
      _getProfileKey(_kDashboardCollapsed),
      collapsed.toString(),
    );
  }

  Future<void> setIsFlipped(bool flipped) async {
    isFlipped.value = flipped;
    await _storage.saveNormal(_getProfileKey(_kIsFlipped), flipped.toString());
  }

  Future<void> setEditorHeight(double height) async {
    editorHeight.value = height;
    await _storage.saveNormal(_kEditorHeight, height.toString());
  }

  Future<void> setEditorWidthPercent(double percent) async {
    final double clamped = percent.clamp(0.2, 0.8);
    editorWidthPercent.value = clamped;
    await _storage.saveNormal(_kEditorWidthPercent, clamped.toString());
  }

  Future<void> saveSecretConfig(SecretConfig config) async {
    final index = secretConfigs.indexWhere((p) => p.id == config.id);
    if (index != -1) {
      secretConfigs[index] = config;
    } else {
      secretConfigs.add(config);
    }
    await _storage.saveSecure(
      _getProfileKey(_kSecretConfigsBase),
      json.encode(
        secretConfigs
            .map((e) => SecretConfigModel.fromDomain(e).toMap())
            .toList(),
      ),
    );
  }

  Future<void> deleteSecretConfig(String id) async {
    secretConfigs.removeWhere((p) => p.id == id);
    await _storage.saveSecure(
      _getProfileKey(_kSecretConfigsBase),
      json.encode(
        secretConfigs
            .map((e) => SecretConfigModel.fromDomain(e).toMap())
            .toList(),
      ),
    );
  }

  Future<void> setEditorFont(String font) async {
    editorFont.value = font;
    await _storage.saveNormal(_getProfileKey(_kEditorFont), font);
  }

  Future<void> setTabSize(int size) async {
    tabSize.value = size;
    await _storage.saveNormal(_getProfileKey(_kTabSize), size.toString());
  }

  Future<void> toggleAutoSave(bool value) async {
    autoSave.value = value;
    await _storage.saveNormal(_getProfileKey(_kAutoSave), value.toString());
  }
}
