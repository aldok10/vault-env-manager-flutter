// Copyright (c) 2024 Vault Env Manager
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/encryption_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_service.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';
import 'package:vault_env_manager/src/core/services/security_service.dart';
import 'package:vault_env_manager/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vault_env_manager/src/features/workbench/data/repositories/workbench_repository_impl.dart';
import 'package:vault_env_manager/src/features/workbench/domain/logic/encryption_logic_manager.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/decrypt_data.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/encrypt_data.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

import 'test_mocks.dart';

/// Bug Condition Exploration Tests for Critical Security Bugs (Bugs 1-3)
///
/// These tests MUST FAIL on unfixed code - failure confirms the bugs exist.
/// They encode the expected behavior and will validate the fixes when they pass.
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6**

void main() {
  setUp(() {
    // Reset GetX for each test
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Bug 1 — Predictable Key Generation', () {
    test(
      'regenKey() should produce cryptographically unpredictable keys',
      () async {
        // Setup: Initialize required services
        final storage = FakeStorageService();
        await storage.init();
        Get.put<StorageService>(storage);

        final compute = ComputeService();
        await compute.init();
        Get.put(compute);

        final log = LogService();
        Get.put(log);

        final config = AppConfigService();
        await config.testInit(storage);
        Get.put(config);

        // Create dependencies for EncryptData and DecryptData
        final vaultService = VaultService();
        final encryptionService = EncryptionService();
        final workbenchRepo = WorkbenchRepositoryImpl(
          vaultService,
          encryptionService,
        );

        // Create EncryptionLogicManager with required dependencies
        final encryptData = EncryptData(workbenchRepo);
        final decryptData = DecryptData(workbenchRepo);
        final manager = EncryptionLogicManager(encryptData, decryptData);

        // Generate multiple keys and check for uniqueness
        final keys = <String>[];
        for (int i = 0; i < 10; i++) {
          manager.regenKey((key) {
            keys.add(key);
          });
        }

        // CRITICAL: On UNFIXED code, Random() is seeded from system clock
        // and can produce predictable/identical keys
        // On FIXED code, Random.secure() should produce unique keys

        // Check that all keys are unique (no duplicates)
        final uniqueKeys = keys.toSet();
        expect(
          uniqueKeys.length,
          equals(keys.length),
          reason:
              'All generated keys should be unique. Found ${keys.length - uniqueKeys.length} duplicates.',
        );

        // Check that keys have correct format
        for (final key in keys) {
          expect(key, startsWith('base64:'));
          final decoded = base64Url.decode(key.substring(7));
          expect(decoded.length, equals(32));
        }

        // Check that keys are statistically different (not just shifted)
        // Extract the byte arrays
        final keyBytes =
            keys.map((k) => base64Url.decode(k.substring(7))).toList();

        // Calculate average Hamming distance between keys
        int totalDistance = 0;
        for (int i = 0; i < keyBytes.length; i++) {
          for (int j = i + 1; j < keyBytes.length; j++) {
            for (int b = 0; b < 32; b++) {
              if (keyBytes[i][b] != keyBytes[j][b]) {
                totalDistance++;
              }
            }
          }
        }

        // Expected average distance for truly random 32-byte keys is ~128 bits
        // We allow some variance but expect at least 100 bits average
        final numComparisons = (keyBytes.length * (keyBytes.length - 1)) ~/ 2;
        final avgDistance = totalDistance / numComparisons;

        expect(
          avgDistance,
          greaterThan(100),
          reason:
              'Average Hamming distance should be >100 bits for random keys, got $avgDistance',
        );
      },
    );
  });

  group('Bug 2 — Hardcoded Deterministic Encryption Key', () {
    test(
      'SecurityService.init() should NOT produce the hardcoded key [42..73]',
      () async {
        // Setup: Initialize required services
        final storage = FakeStorageService();
        await storage.init();
        Get.put<StorageService>(storage);

        final compute = ComputeService();
        await compute.init();
        Get.put(compute);

        final config = AppConfigService();
        await config.testInit(storage);
        Get.put(config);

        // Create two separate SecurityService instances
        final service1 = SecurityService();
        final service2 = SecurityService();

        // Initialize both services
        await service1.init();
        await service2.init();

        // Encrypt with service1
        final encrypted = await service1.encrypt('test-message');

        // Decrypt with service2 - if keys are different, this should fail
        // If keys are the same (hardcoded), this should work
        bool decryptionSucceeded = false;
        try {
          final decrypted = await service2.decrypt(encrypted);
          decryptionSucceeded = (decrypted == 'test-message');
        } catch (e) {
          decryptionSucceeded = false;
        }

        // CRITICAL: On UNFIXED code, both services use hardcoded [42..73] key
        // so decryption succeeds (keys are identical)
        // On FIXED code, each service generates/retrieves a unique key
        // so decryption fails (keys are different)

        // This test expects the keys to be DIFFERENT (fail-closed behavior)
        // On unfixed code, this will FAIL because keys are identical
        expect(
          decryptionSucceeded,
          isFalse,
          reason:
              'Two separate SecurityService instances should have different keys. '
              'If decryption succeeds, it means both are using the hardcoded [42..73] key.',
        );

        // Additional check: verify the hardcoded key pattern is NOT used
        // On fixed code, key should be stored in secure storage
        // On unfixed code, key is NOT stored (hardcoded)
        final storedKey = await storage.get(
          'payload_encryption_key',
          isSecure: true,
        );

        // On fixed code, key should be stored
        // On unfixed code, key is NOT stored (hardcoded)
        expect(
          storedKey,
          isNotNull,
          reason:
              'SecurityService should store the encryption key in secure storage. '
              'If null, the key is hardcoded and not persisted.',
        );
      },
    );
  });

  group('Bug 3 — Weak Password Hashing', () {
    test(
      '_generateHash() should use per-user salt and key stretching',
      () async {
        // Setup: Initialize required services
        final storage = FakeStorageService();
        await storage.init();
        Get.put<StorageService>(storage);

        final compute = ComputeService();
        await compute.init();
        Get.put(compute);

        final config = AppConfigService();
        await config.testInit(storage);
        Get.put(config);

        // Create AuthRepositoryImpl
        final authRepo = AuthRepositoryImpl(config);

        // Setup master password on two separate instances
        const testPassword = 'testpass123';

        // First setup
        final result1 = await authRepo.setupMasterPassword(testPassword);
        expect(result1.isRight(), isTrue);

        final hash1 = config.cipherPass.value;

        // Create a new AuthRepositoryImpl (simulating separate instance)
        final authRepo2 = AuthRepositoryImpl(config);

        // Second setup with same password - should produce DIFFERENT hash
        // because each should have unique salt
        final result2 = await authRepo2.setupMasterPassword(testPassword);
        expect(result2.isRight(), isTrue);

        final hash2 = config.cipherPass.value;

        // CRITICAL: On UNFIXED code, both hashes are identical
        // because static salt is used
        // On FIXED code, hashes should be different due to per-user random salt

        // The hashes should be different (per-user salt)
        expect(
          hash1,
          isNot(equals(hash2)),
          reason:
              'Two separate setupMasterPassword calls with the same password '
              'should produce different hashes due to unique per-user salts. '
              'If hashes are identical, a static salt is being used.',
        );

        // Additional verification: unlock should work with the password
        // but only if the salt is properly stored and used
        final unlockResult = await authRepo.unlock(testPassword);
        expect(unlockResult.isRight(), isTrue);

        // Wrong password should fail
        final wrongResult = await authRepo.unlock('wrongpassword');
        expect(wrongResult.isLeft(), isTrue);
      },
    );

    test(
      'Hash output should change when called multiple times with same password',
      () async {
        // Setup
        final storage = FakeStorageService();
        await storage.init();
        Get.put<StorageService>(storage);

        final compute = ComputeService();
        await compute.init();
        Get.put(compute);

        final config = AppConfigService();
        await config.testInit(storage);
        Get.put(config);

        // Generate multiple hashes with same password
        final hashes = <String>[];
        const password = 'mypassword';

        for (int i = 0; i < 5; i++) {
          final authRepo = AuthRepositoryImpl(config);
          await authRepo.setupMasterPassword(password);
          hashes.add(config.cipherPass.value);
        }

        // All hashes should be unique (due to unique salts)
        final uniqueHashes = hashes.toSet();
        expect(
          uniqueHashes.length,
          equals(hashes.length),
          reason:
              'Each call to setupMasterPassword should generate a unique hash '
              'due to random per-user salt. Found ${hashes.length - uniqueHashes.length} duplicates.',
        );
      },
    );
  });
}
