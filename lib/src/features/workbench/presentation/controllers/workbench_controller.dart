import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/laravel_env_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/entities/vault_secret.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/encryption_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/vault_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/mixins/_workbench_config_actions.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/mixins/_workbench_editor_actions.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/mixins/_workbench_state.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';
import 'package:vault_env_manager/src/shared/utils/syntax_highlighter.dart';

/// Controller for the Workbench feature, managing state, actions, and configurations.
/// Adheres to Rule of 200 by decomposing complexity into modular mixins.
class WorkbenchController extends GetxController
    with WorkbenchState, WorkbenchEditorActions, WorkbenchConfigActions {
  @override
  final VaultLogicManager vault;
  @override
  final EncryptionLogicManager encryption;
  @override
  final LogService log = Get.find<LogService>();
  @override
  final LaravelEnvService laravelEnvService;
  @override
  final AppConfigService config;

  WorkbenchController(
    this.vault,
    this.encryption,
    this.laravelEnvService,
    this.config,
  );

  final isKeyMasked = true.obs;
  final repositoryTab = 0.obs;
  final progressVal = 0.0.obs;
  final RxList<VaultSecret> vaultSecrets = <VaultSecret>[].obs;

  String get secureKeyMasked => '*' * (masterKeyController.text.length);

  @override
  void onInit() {
    super.onInit();
    SyntaxHighlighter.initialize().then((_) => updateSyntax());

    plaintextController.addListener(updateStats);
    ciphertextController.addListener(updateStats);
    masterKeyController.addListener(
      () => encryption.masterKey.value = masterKeyController.text,
    );

    ever(selectedSyntax, (_) => updateSyntax());
    ever(config.activeProfileId, (_) => _handleProfileSwitch());

    // Sync connection state
    ever(
      config.vaultOrigin,
      (o) => vault.updateConnection(o, config.vaultToken.value),
    );
    ever(
      config.vaultToken,
      (t) => vault.updateConnection(config.vaultOrigin.value, t),
    );
    vault.updateConnection(config.vaultOrigin.value, config.vaultToken.value);

    _listenForReferenceChanges();
  }

  @override
  void onClose() {
    disposeEditors();
    disposeConfigControllers();
    super.onClose();
  }

  void _handleProfileSwitch() {
    log.clear();
    plaintextController.clear();
    ciphertextController.clear();
    vaultSecrets.clear();
    vault.reset();
    log.info('System context swapped to ${config.vaultOrigin.value}');
    statusMessage.value = 'STATUS: STANDBY';
  }

  void appendLog(String message, {LogLevel level = LogLevel.info}) =>
      log.append(message, level: level);
  void clearLogs() => log.clear();

  Future<void> encrypt() async {
    statusMessage.value = 'STATUS: ENCRYPTING...';
    await encryption.encrypt(plaintextController.text, (s) {
      ciphertextController.text = s;
      statusMessage.value = 'STATUS: ENCRYPTED';
    });
  }

  Future<void> decrypt() async {
    statusMessage.value = 'STATUS: DECRYPTING...';
    await encryption.decrypt(ciphertextController.text, (s) {
      plaintextController.text = s;
      if (vault.lastPath.value.isNotEmpty) {
        vault.vaultDecryptedBaseline.value = s;
      }
      statusMessage.value = 'STATUS: DECRYPTED';
    });
  }

  Future<void> handleVaultSync(
    String fullPath, {
    String? displayName,
    String? specificKey,
    int? version,
  }) async {
    await vault.sync(
      path: fullPath,
      name: displayName,
      specificKey: specificKey,
      version: version,
      onDataFetched: (content) {
        ciphertextController.text = content;
        statusMessage.value = 'STATUS: SYNCHRONIZED';
        _updateReference();
      },
      onBeforeDecrypt: () {
        if (masterKeyController.text.isNotEmpty) {
          encryption
              .silentDecrypt(ciphertextController.text)
              .then((s) => vault.vaultDecryptedBaseline.value = s);
          decrypt();
        }
      },
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> fetchVaultData(
    String fullPath,
  ) =>
      vault.fetchRaw(fullPath);

  void revertToVault() {
    if (vault.vaultDecryptedBaseline.value.isNotEmpty) {
      plaintextController.text = vault.vaultDecryptedBaseline.value;
      log.info('Reverted to Vault version.');
    }
  }

  void setEditorHeight(double height) => config.setEditorHeight(height);
  void setEditorWidthPercent(double percent) =>
      config.setEditorWidthPercent(percent);

  void _listenForReferenceChanges() {
    ciphertextController.addListener(() => _updateReference());
    masterKeyController.addListener(() => _updateReference());
    ever(encryption.selectedAlgorithm, (_) => _updateReference());
  }

  void _updateReference() {
    encryption
        .silentDecrypt(ciphertextController.text)
        .then((s) => encryption.decryptedReference.value = s);
  }
}
