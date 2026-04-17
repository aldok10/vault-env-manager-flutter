import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/laravel_env_service.dart';
import 'package:vault_env_manager/src/features/workbench/domain/entities/secret_config.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/encryption_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/vault_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/encryption_algorithm.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/label.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/secret_key.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

class MockVaultLogicManager extends Mock implements VaultLogicManager {
  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});
  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});
}

class MockEncryptionLogicManager extends Mock
    implements EncryptionLogicManager {
  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});
  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});
}

class MockLaravelEnvService extends Mock implements LaravelEnvService {}

class MockAppConfigService extends Mock implements AppConfigService {}

class MockLogService extends Mock implements LogService {
  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});
  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});
}

void main() {
  late WorkbenchController controller;
  late MockVaultLogicManager mockVault;
  late MockEncryptionLogicManager mockEncryption;
  late MockLaravelEnvService mockLaravel;
  late MockAppConfigService mockConfig;
  late MockLogService mockLog;

  setUpAll(() {
    registerFallbackValue(const SecretKey(''));
    registerFallbackValue(const EncryptionAlgorithm(''));
    registerFallbackValue(const Label(''));
    registerFallbackValue(
      const SecretConfig(
        id: '',
        label: Label(''),
        key: SecretKey(''),
        algorithm: EncryptionAlgorithm(''),
      ),
    );
  });

  setUp(() {
    mockVault = MockVaultLogicManager();
    mockEncryption = MockEncryptionLogicManager();
    mockLaravel = MockLaravelEnvService();
    mockConfig = MockAppConfigService();
    mockLog = MockLogService();

    Get.put<LogService>(mockLog);

    // Mock initial config list
    when(() => mockConfig.secretConfigs).thenReturn(<SecretConfig>[].obs);
    when(() => mockConfig.activeProfileId).thenReturn('default'.obs);
    when(() => mockConfig.vaultOrigin).thenReturn('http://localhost:8200'.obs);
    when(() => mockConfig.vaultToken).thenReturn('s.token'.obs);
    when(() => mockConfig.isDashboardCollapsed).thenReturn(false.obs);
    when(() => mockConfig.isFlipped).thenReturn(false.obs);
    when(() => mockConfig.editorHeight).thenReturn(400.0.obs);
    when(() => mockConfig.editorWidthPercent).thenReturn(0.5.obs);
    when(() => mockConfig.vaultDiscoveryPath).thenReturn('secret/'.obs);

    // Mock Logic Manager Observables
    when(() => mockVault.isConnected).thenReturn(false.obs);
    when(() => mockVault.isLoading).thenReturn(false.obs);
    when(() => mockVault.selectedPath).thenReturn(''.obs);
    when(() => mockVault.lastKey).thenReturn(''.obs);
    when(() => mockVault.selectedVersion).thenReturn(RxnInt());
    when(() => mockVault.vaultDecryptedBaseline).thenReturn(''.obs);
    when(() => mockVault.lastPath).thenReturn(''.obs);

    when(() => mockEncryption.isProcessing).thenReturn(false.obs);
    when(() => mockEncryption.selectedAlgorithm).thenReturn('aes-256-cbc'.obs);
    when(
      () => mockEncryption.algorithms,
    ).thenReturn(['aes-256-cbc', 'aes-256-gcm'].obs);
    when(() => mockEncryption.decryptedReference).thenReturn(''.obs);
    when(() => mockEncryption.masterKey).thenReturn(''.obs);

    // Mock Logic Manager Methods
    when(
      () => mockVault.updateConnection(any(), any()),
    ).thenAnswer((_) async => {});

    controller = WorkbenchController(
      mockVault,
      mockEncryption,
      mockLaravel,
      mockConfig,
    );
  });

  group('WorkbenchController - Logic Tests', () {
    test('encrypt should delegate to encryption manager', () async {
      const plaintext = 'PlainData';
      controller.plaintextController.text = plaintext;

      when(() => mockEncryption.encrypt(any(), any())).thenAnswer((
        invocation,
      ) async {
        final onFinish = invocation.positionalArguments[1] as Function(String);
        onFinish('iv:CipherData');
      });

      await controller.encrypt();

      expect(controller.ciphertextController.text, 'iv:CipherData');
      expect(controller.statusMessage.value, 'STATUS: ENCRYPTED');
    });

    test('decrypt should delegate to encryption manager', () async {
      const ciphertext = 'iv:CipherData';
      controller.ciphertextController.text = ciphertext;

      when(() => mockEncryption.decrypt(any(), any())).thenAnswer((
        invocation,
      ) async {
        final onFinish = invocation.positionalArguments[1] as Function(String);
        onFinish('PlainData');
      });

      await controller.decrypt();

      expect(controller.plaintextController.text, 'PlainData');
      expect(controller.statusMessage.value, 'STATUS: DECRYPTED');
    });
  });

  group('WorkbenchController - Persistent Configs', () {
    test('useConfig should update UI state correctly', () {
      const config = SecretConfig(
        id: '1',
        label: Label('PROD'),
        key: SecretKey('PROD_KEY'),
        algorithm: EncryptionAlgorithm('aes-128-cbc'),
      );

      controller.useConfig(config);

      expect(controller.masterKeyController.text, 'PROD_KEY');
      expect(controller.selectedAlgorithm.value, 'aes-128-cbc');
    });

    test('addNewKey should persist new config via AppConfig', () {
      controller.keyLabelController.text = 'TEST_LABEL';
      controller.newKeyController.text = 'TEST_KEY';
      controller.selectedAlgorithm.value = 'aes-256-gcm';

      when(
        () => mockConfig.saveSecretConfig(any()),
      ).thenAnswer((_) async => {});

      controller.addNewKey();

      verify(() => mockConfig.saveSecretConfig(any())).called(1);
    });
  });
}
