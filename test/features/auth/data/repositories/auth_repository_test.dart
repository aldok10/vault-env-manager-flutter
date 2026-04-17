import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../../test_mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late AppConfigService mockConfig;

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    mockConfig = await setupTestConfig();
    repository = AuthRepositoryImpl(mockConfig);
  });

  group('AuthRepositoryImpl', () {
    test(
      'should return Right(true) when the correct password is provided',
      () async {
        // Setup the master password first
        await repository.setupMasterPassword('12345678');

        // Act
        final result = await repository.unlock('12345678');

        // Assert
        expect(result.isRight(), true);
      },
    );

    test(
      'should return Left(AuthFailure) when an incorrect password is provided',
      () async {
        // Setup the master password first
        await repository.setupMasterPassword('12345678');

        // Act
        final result = await repository.unlock('wrong-password');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (success) => fail('Should have failed'),
        );
      },
    );
  });
}
