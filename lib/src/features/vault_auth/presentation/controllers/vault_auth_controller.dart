import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/local_auth_service.dart';
import 'package:vault_env_manager/src/core/app/routes/app_routes.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/repositories/i_vault_auth_repository.dart';

class VaultAuthController extends GetxController {
  final IVaultAuthRepository _repository;
  final AppConfigService config;
  final LocalAuthService _localAuthService;

  VaultAuthController(this._repository, this.config, this._localAuthService);

  // Form State
  final RxString selectedMethod = 'Token'.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;

  // LDAP State
  final RxBool isAdvancedSettingsOpen = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isBiometricSupported = false.obs;

  // Controllers
  final tokenController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final mountController = TextEditingController(text: 'ldap');

  // Focus Nodes
  final tokenFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final List<String> methods = ['Token', 'LDAP'];

  @override
  void onInit() {
    super.onInit();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    isBiometricSupported.value = await _localAuthService.isBiometricAvailable();
  }

  @override
  void onClose() {
    tokenController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    mountController.dispose();

    tokenFocusNode.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }


  void toggleMethod(String method) {
    selectedMethod.value = method;
    errorMsg.value = '';
  }

  void toggleAdvancedSettings() {
    isAdvancedSettingsOpen.value = !isAdvancedSettingsOpen.value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signIn() async {
    errorMsg.value = '';

    if (selectedMethod.value == 'Token' &&
        tokenController.text.trim().isEmpty) {
      errorMsg.value = 'Token is required';
      return;
    }
    if (selectedMethod.value == 'LDAP' &&
        (usernameController.text.trim().isEmpty ||
            passwordController.text.isEmpty)) {
      errorMsg.value = 'Username and Password are required';
      return;
    }

    isLoading.value = true;

    final result = selectedMethod.value == 'Token'
        ? await _repository.loginWithToken(tokenController.text.trim())
        : await _repository.loginWithLdap(
            username: usernameController.text.trim(),
            password: passwordController.text,
            mountPath: mountController.text.trim().isEmpty
                ? 'ldap'
                : mountController.text.trim(),
          );

    await result.fold(
      (failure) async {
        errorMsg.value = failure.message;
        isLoading.value = false;
      },
      (token) async {
        // Success
        await config.setVaultToken(token);
        await Get.offAllNamed(AppRoutes.workbench);
      },
    );
  }

  Future<void> authenticateWithBiometrics() async {
    final isAvailable = await _localAuthService.isBiometricAvailable();

    if (!isAvailable) {
      errorMsg.value = 'Biometrics not available on this device';
      return;
    }

    final authenticated = await _localAuthService.authenticate();
    if (authenticated) {
      final savedToken = config.vaultToken.value;
      if (savedToken.isNotEmpty) {
        // We already have a token, just unlock
        await Get.offAllNamed(AppRoutes.workbench);
      } else {
        errorMsg.value =
            'No saved session found. Please sign in with Token/LDAP first.';
      }
    }
  }

  Future<bool> canUseBiometrics() async {
    return await _localAuthService.isBiometricAvailable();
  }

  void skipLogin() {
    Get.offAllNamed(AppRoutes.workbench);
  }
}
