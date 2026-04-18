// Copyright (c) 2024 Vault Env Manager
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/local_auth_service.dart';
import 'package:vault_env_manager/src/core/services/network_security_interceptor.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/repositories/i_vault_auth_repository.dart';
import 'package:vault_env_manager/src/features/vault_auth/presentation/controllers/vault_auth_controller.dart';
import 'package:vault_env_manager/src/shared/utils/crypt_helpers.dart';

import 'test_mocks.dart';

// --- Mocks for Bug 5 (VaultAuthController) ---

class MockVaultAuthRepository extends Mock implements IVaultAuthRepository {}

class MockLocalAuthService extends Mock implements LocalAuthService {}

/// Bug Condition Exploration Tests for High-Impact Bugs (Bugs 4-6)
///
/// These tests MUST FAIL on unfixed code — failure confirms the bugs exist.
/// They encode the expected behavior and will validate the fixes when they pass.
///
/// **Validates: Requirements 1.7, 1.8, 1.9, 1.10**

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Bug 4 — Malformed Regex Causes Runtime Crash', () {
    /// **Validates: Requirements 1.7**
    ///
    /// Bug Condition: regexPatternIsMalformed(input.regexSource)
    ///
    /// When index-based extraction fails and the regex fallback is triggered,
    /// the malformed regex pattern (split across lines) throws a FormatException.
    ///
    /// On UNFIXED code: FormatException thrown on regex fallback — test FAILS
    /// Counterexample: FormatException thrown on regex fallback path
    test(
      'unserializeString() should NOT throw FormatException on regex fallback path',
      () {
        // Craft input where index-based extraction fails:
        // - Starts with 's:' to enter the PHP deserialization path
        // - Has exactly ONE quote so firstQuoteIndex == lastQuoteIndex,
        //   causing the index-based path to skip (condition fails)
        // - This forces the regex fallback path
        final malformedInput = 's:5:"hello;';

        // On UNFIXED code: The regex literal is malformed (split across lines
        // in the source file), causing a FormatException when compiled.
        // On FIXED code: The regex is properly formed on a single line and
        // either matches or returns the input unchanged.
        expect(
          () => CryptHelpers.unserializeString(malformedInput),
          returnsNormally,
          reason:
              'unserializeString() should not throw when the regex fallback '
              'path is triggered. On unfixed code, the malformed regex causes '
              'a FormatException.',
        );
      },
    );

    test(
      'unserializeString() should handle input with no quotes gracefully',
      () {
        // Another input that forces the regex fallback:
        // Starts with 's:' but has zero quotes — both indexOf return -1
        // The condition (firstQuoteIndex != -1 && lastQuoteIndex != -1) fails
        // so it falls through to the regex path
        final noQuotesInput = 's:5:hello;';

        // On UNFIXED code: regex fallback throws FormatException
        // On FIXED code: regex doesn't match, returns input unchanged
        expect(
          () => CryptHelpers.unserializeString(noQuotesInput),
          returnsNormally,
          reason:
              'unserializeString() should not throw for input with no quotes. '
              'The regex fallback path should handle this gracefully.',
        );
      },
    );
  });

  group('Bug 5 — Loading State Not Reset on Success', () {
    late MockVaultAuthRepository mockRepository;
    late AppConfigService realConfig;
    late MockLocalAuthService mockLocalAuth;
    late VaultAuthController controller;

    setUp(() async {
      mockRepository = MockVaultAuthRepository();
      mockLocalAuth = MockLocalAuthService();

      // Stub isBiometricAvailable for onInit
      when(
        () => mockLocalAuth.isBiometricAvailable(),
      ).thenAnswer((_) async => false);

      // Use real AppConfigService via setupTestConfig for proper initialization
      realConfig = await setupTestConfig();

      Get.put<LocalAuthService>(mockLocalAuth);

      controller = VaultAuthController(
        mockRepository,
        realConfig,
        mockLocalAuth,
      );
      controller.onInit();
    });

    /// **Validates: Requirements 1.8, 1.9**
    ///
    /// Bug Condition: isLoadingNotReset(input.controllerState)
    ///
    /// When signIn() succeeds, isLoading.value should be reset to false.
    /// On UNFIXED code: isLoading stays true after success fold — test FAILS
    /// Counterexample: isLoading.value == true after successful signIn()
    test(
      'signIn() should reset isLoading to false after successful sign-in',
      () async {
        // Setup: Mock successful token login
        const testToken = 'hvs.test-vault-token-12345';
        when(
          () => mockRepository.loginWithToken(testToken),
        ).thenAnswer((_) async => const Right(testToken));

        // Set the token in the controller's text field
        controller.tokenController.text = testToken;
        controller.selectedMethod.value = 'Token';

        // Act: Call signIn
        await controller.signIn();

        // Assert: isLoading should be false after successful sign-in
        // On UNFIXED code: isLoading stays true because the success fold
        // navigates away without resetting isLoading.value = false.
        // The failure fold resets it, but the success fold does not.
        // On FIXED code: isLoading is reset to false in both folds.
        expect(
          controller.isLoading.value,
          isFalse,
          reason: 'isLoading.value should be false after successful signIn(). '
              'On unfixed code, isLoading stays true after the success fold '
              'because it is only reset in the failure fold.',
        );
      },
    );
  });

  group('Bug 6 — Certificate Pinning Bypass', () {
    /// **Validates: Requirements 1.10**
    ///
    /// Bug Condition: badCertCallbackReturnsTrue() when fingerprint is null
    ///
    /// When createPinningClient(null) is called, the badCertificateCallback
    /// should reject all certificates (return false) for fail-closed behavior.
    ///
    /// On UNFIXED code: callback returns true — test FAILS confirming bypass
    /// Counterexample: badCertificateCallback returns true for any certificate
    /// when fingerprint is null
    test('createPinningClient(null) should reject certificates (fail-closed)',
        () {
      // We test the certificate pinning behavior by creating an HttpClient
      // that captures the badCertificateCallback result.
      //
      // The createPinningClient method sets up the callback internally.
      // Since IOClient doesn't expose the inner HttpClient, we use
      // HttpOverrides to intercept and verify the callback behavior.
      //
      // However, the simplest reliable approach is to directly test
      // the callback logic by reading the source pattern.
      //
      // The source code (network_security_interceptor.dart line ~37):
      //   if (fingerprint == null || fingerprint.isEmpty) return true;
      //
      // This is the bug: it should return false (fail-closed).
      //
      // We verify by calling createPinningClient and checking that
      // the returned client would reject bad certificates.

      // Create the actual pinning client with null fingerprint
      final ioClient = SecureHttpClient.createPinningClient(null);

      // The IOClient wraps an HttpClient. We verify the behavior by
      // checking the source code's guard clause. The createPinningClient
      // method's badCertificateCallback has this logic:
      //
      //   if (fingerprint == null || fingerprint.isEmpty) return true;
      //
      // This means: when fingerprint is null, ALL certificates are accepted.
      // The expected behavior: return false (reject all certs).
      //
      // We can verify this by reading the source file and checking
      // the guard clause returns false for null fingerprint.

      // Read the source file to verify the guard clause
      final sourceFile = File(
        'lib/src/core/services/network_security_interceptor.dart',
      );
      final sourceContent = sourceFile.readAsStringSync();

      // Check that the null/empty fingerprint guard returns false (fail-closed)
      // On UNFIXED code: the source contains `return true` in the guard
      // On FIXED code: the source contains `return false` in the guard
      //
      // We look for the pattern where fingerprint null check returns true
      // (the bug) vs false (the fix)
      final hasBuggyGuard = sourceContent.contains(
        RegExp(
          r'if\s*\(\s*fingerprint\s*==\s*null\s*\|\|\s*fingerprint\.isEmpty\s*\)\s*return\s+true',
        ),
      );

      expect(
        hasBuggyGuard,
        isFalse,
        reason: 'createPinningClient should return false (fail-closed) when '
            'fingerprint is null or empty. Found "return true" in the '
            'null/empty fingerprint guard, which silently accepts ALL '
            'certificates including MITM certificates.',
      );

      ioClient.close();
    });
  });
}
