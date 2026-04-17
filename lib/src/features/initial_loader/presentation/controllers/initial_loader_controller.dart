import 'dart:async';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/encryption_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/laravel_env_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/local_auth_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/vault_service.dart';
import 'package:vault_env_manager/src/core/app/routes/app_routes.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';
import 'package:vault_env_manager/src/core/services/network_security_interceptor.dart';
import 'package:vault_env_manager/src/core/services/security_service.dart';

class InitialLoaderController extends GetxController {
  final status = 'INITIALIZING SECURE CORE...'.obs;
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(_startInitialization());
  }

  Future<void> _startInitialization() async {
    try {
      // 1. Storage
      status.value = 'MAPPING PERSISTENT STORSeraphineE...';
      await StorageService.to.init();

      // 2. Local Auth
      status.value = 'SECURING BIOMETRIC PROTOCOL...';
      await Get.putAsync(() => LocalAuthService().init(), permanent: true);

      // 3. Compute Service (Isolates) - Needed by Config Service for JSON parsing
      status.value = 'OPTIMIZING PROCESSOR THREADS...';
      await Get.putAsync(() => ComputeService().init(), permanent: true);

      // 4. Encryption
      status.value = 'READYING VAULT CRYPTOGRAPHY...';
      await Get.putAsync(() => EncryptionService().init(), permanent: true);

      // 5. App Config
      status.value = 'LOADING WORKBENCH PREFERENCES...';
      await AppConfigService.to.init();

      // Mark as initialized so other listeners can be notified if needed
      isInitialized.value = true;

      // 6. Security Service (Keys)
      status.value = 'ESTABLISHING SECURITY CONTEXT...';
      await Get.putAsync(() => SecurityService().init(), permanent: true);

      // 4.5 Initialize Secure HTTP Client (AES-GCM + Pinning)
      status.value = 'SECURING NETWORK LAYER (PINNING ENFORCED)...';
      final config = AppConfigService.to;

      final innerClient = SecureHttpClient.createPinningClient(
        config.vaultFingerprint.value,
      );

      final secureClient = SecureHttpClient(
        innerClient,
        SecurityService.to.payloadKey,
        certificateFingerprint: config.vaultFingerprint.value,
      );
      Get.put<http.Client>(secureClient, permanent: true);

      // 5. Vault API Service
      status.value = 'CONNECTING VAULT PROTOCOL...';
      Get.put(VaultService(), permanent: true);

      // 6. Laravel Env
      Get.put(LaravelEnvService(), permanent: true);

      // Final Transition
      status.value = 'ACCESS GRANTED';

      // Delay for visual satisfaction
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to AuthPage
      await Get.offAllNamed(AppRoutes.initial);
    } catch (e) {
      status.value = 'SYSTEM FAILURE: ${e.toString()}';
    }
  }
}
