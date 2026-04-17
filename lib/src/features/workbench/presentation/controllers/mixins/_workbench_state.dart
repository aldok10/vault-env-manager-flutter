import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/features/workbench/domain/entities/secret_config.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/encryption_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/vault_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

mixin WorkbenchState on GetxController {
  VaultLogicManager get vault;
  EncryptionLogicManager get encryption;
  LogService get log;
  AppConfigService get config;

  // Delegation Aliases
  RxList<SystemLog> get consoleLogs => log.logs;
  final statusMessage = 'STATUS: STANDBY'.obs;

  RxBool get isVaultConnected => vault.isConnected;
  RxBool get isLoadingVault => vault.isLoading;
  RxString get selectedEnvPath => vault.selectedPath;
  RxString get lastSelectedKey => vault.lastKey;
  RxnInt get selectedEnvVersion => vault.selectedVersion;
  RxString get vaultDecryptedBaseline => vault.vaultDecryptedBaseline;

  RxBool get isProcessing => encryption.isProcessing;
  RxString get selectedAlgorithm => encryption.selectedAlgorithm;
  RxList<String> get algorithms => encryption.algorithms;
  RxString get decryptedReferenceValue => encryption.decryptedReference;
  RxString get masterKeyText => encryption.masterKey;

  // AppConfig Aliases
  RxBool get isDashboardCollapsed => config.isDashboardCollapsed;
  RxBool get isFlipped => config.isFlipped;
  RxDouble get editorHeight => config.editorHeight;
  RxDouble get editorWidthPercent => config.editorWidthPercent;
  RxString get vaultOrigin => config.vaultOrigin;
  RxString get vaultToken => config.vaultToken;
  RxList<SecretConfig> get savedConfigs => config.secretConfigs;
}
