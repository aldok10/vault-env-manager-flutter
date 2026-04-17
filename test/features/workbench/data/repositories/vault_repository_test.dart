import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';
import 'package:vault_env_manager/src/features/workbench/data/repositories/vault_repository_impl.dart';

import '../../../../test_mocks.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late VaultRepositoryImpl repository;
  late MockHttpClient mockClient;
  late AppConfigService mockConfig;

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    mockConfig = await setupTestConfig();
    mockClient = MockHttpClient();
    repository = VaultRepositoryImpl(mockClient, mockConfig);

    // Register fallback for mocktail
    registerFallbackValue(Uri.parse('http://localhost'));

    // Initialize ComputeService for tests
    if (!Get.isRegistered<ComputeService>()) {
      Get.put(ComputeService());
    }
  });

  group('VaultRepositoryImpl Unit Tests', () {
    test('listKeys should return list of keys on 200 SUCCESS', () async {
      // Arrange
      final responseBody = json.encode({
        'data': {
          'keys': ['key1', 'key2/'],
        },
      });

      // Updated: Set values directly on the real config object from setupTestConfig
      mockConfig.scrapingUrl.value = 'environment';
      mockConfig.vaultToken.value = 'test_token';
      mockConfig.vaultOrigin.value = 'http://localhost';

      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await repository.listKeys('SAM/path');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be right ($l)'),
        (keys) => expect(keys, ['key1', 'key2/']),
      );
    });

    test('getSecret should return Map on 200 SUCCESS', () async {
      // Arrange
      final responseBody = json.encode({
        'data': {
          'data': {'VALUE': '111'},
        },
      });

      mockConfig.scrapingUrl.value = 'environment';

      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await repository.getSecret('SAM/data');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be right'),
        (data) => expect(data['VALUE'], '111'),
      );
    });

    test('getSecret should return VaultAuthFailure on 403', () async {
      // Arrange
      mockConfig.scrapingUrl.value = 'environment';
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('Forbidden', 403));

      // Act
      final result = await repository.getSecret('environment/data');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<VaultAuthFailure>()),
        (r) => fail('Should be left'),
      );
    });
  });
}
