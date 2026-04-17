import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/features/workbench/domain/entities/secret_config.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/encryption_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/encryption_algorithm.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/label.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/secret_key.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

mixin WorkbenchConfigActions on GetxController {
  EncryptionLogicManager get encryption;
  AppConfigService get config;
  LogService get log;

  final masterKeyController = TextEditingController();
  final keyLabelController = TextEditingController();
  final newKeyController = TextEditingController();
  final masterKeyFocusNode = FocusNode();

  void addNewKey() {
    final label = keyLabelController.text.trim();
    final key = newKeyController.text.trim();
    if (label.isEmpty || key.isEmpty) return;

    final secretConfig = SecretConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: Label(label),
      key: SecretKey(key),
      algorithm: EncryptionAlgorithm(encryption.selectedAlgorithm.value),
    );

    config.saveSecretConfig(secretConfig);
    log.success('Config [${label.toUpperCase()}] saved.');
    keyLabelController.clear();
    newKeyController.clear();
  }

  void useConfig(SecretConfig config) {
    masterKeyController.text = config.key.value;
    encryption.selectedAlgorithm.value = config.algorithm.value;
    log.info('Active configuration: ${config.label.displayValue}');
  }

  void deleteConfig(String id) => config.deleteSecretConfig(id);
  void regenKey() => encryption.regenKey((k) => newKeyController.text = k);

  void disposeConfigControllers() {
    masterKeyController.dispose();
    keyLabelController.dispose();
    newKeyController.dispose();
    masterKeyFocusNode.dispose();
  }
}
