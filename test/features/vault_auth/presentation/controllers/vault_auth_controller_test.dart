import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/local_auth_service.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/repositories/i_vault_auth_repository.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';
import '../../../../test_mocks.dart';

class MockVaultAuthRepository extends Mock implements IVaultAuthRepository {}

class MockLocalAuthService extends Mock implements LocalAuthService {
  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});
  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});
}

void main() {
  late VaultAuthController controller;
  late MockVaultAuthRepository mockRepo;
  late MockLocalAuthService mockAuth;
  late AppConfigService config;

  setUp(() async {
    Get.testMode = true;
    mockRepo = MockVaultAuthRepository();
    mockAuth = MockLocalAuthService();

    // Use centralized test setup which handles FakeStorage and async init
    config = await setupTestConfig();

    Get.put<LocalAuthService>(mockAuth);

    controller = VaultAuthController(mockRepo, config, mockAuth);
  });

  group('VaultAuthController Biometrics', () {
    test('canUseBiometrics should return availability from service', () async {
      // Arrange
      when(() => mockAuth.isBiometricAvailable()).thenAnswer((_) async => true);

      // Act
      final result = await controller.canUseBiometrics();

      // Assert
      expect(result, true);
      verify(() => mockAuth.isBiometricAvailable()).called(1);
    });

    test(
      'authenticateWithBiometrics should navigate on success if token exists',
      () async {
        // Arrange
        config.vaultToken.value = 'hvs.existing_token';
        when(
          () => mockAuth.isBiometricAvailable(),
        ).thenAnswer((_) async => true);
        when(() => mockAuth.authenticate()).thenAnswer((_) async => true);

        // Act
        await controller.authenticateWithBiometrics();

        // Assert
        expect(controller.errorMsg.value, '');
      },
    );

    test(
      'authenticateWithBiometrics should show error if token is missing',
      () async {
        // Arrange
        config.vaultToken.value = '';
        when(
          () => mockAuth.isBiometricAvailable(),
        ).thenAnswer((_) async => true);
        when(() => mockAuth.authenticate()).thenAnswer((_) async => true);

        // Act
        await controller.authenticateWithBiometrics();

        // Assert
        expect(controller.errorMsg.value, contains('No saved session found'));
      },
    );

    test(
      'authenticateWithBiometrics should show error if biometrics not available',
      () async {
        // Arrange
        when(
          () => mockAuth.isBiometricAvailable(),
        ).thenAnswer((_) async => false);

        // Act
        await controller.authenticateWithBiometrics();

        // Assert
        expect(controller.errorMsg.value, contains('not available'));
      },
    );
  });
}
