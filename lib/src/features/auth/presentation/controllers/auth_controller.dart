import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/routes/app_routes.dart';
import 'package:vault_env_manager/src/features/auth/domain/models/auth_state.dart';
import 'package:vault_env_manager/src/features/auth/domain/repositories/i_auth_repository.dart';

class AuthController extends GetxController {
  final IAuthRepository _repository;

  AuthController(this._repository);

  final Rx<AuthState> state = AuthState.initial().obs;
  final passwordController = TextEditingController();
  final focusNode = FocusNode();
  final RxString errorMsg = ''.obs;
  final RxBool isError = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkStatus();
  }

  @override
  void onClose() {
    passwordController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void _checkStatus() {
    if (_repository.isSetup()) {
      state.value = state.value.copyWith(status: AuthStatus.locked);
    } else {
      state.value = state.value.copyWith(status: AuthStatus.initial);
    }
  }

  bool get isNew => state.value.status == AuthStatus.initial;

  Future<void> initializeWorkbench() async {
    final passwordValue = passwordController.text;
    if (passwordValue.isEmpty) return;

    isLoading.value = true;
    isError.value = false;
    errorMsg.value = '';

    if (isNew) {
      final result = await _repository.setupMasterPassword(passwordValue);
      result.fold((failure) {
        errorMsg.value = failure.message;
        isError.value = true;
      }, (_) => _completeAuth());
    } else {
      final result = await _repository.unlock(passwordValue);
      result.fold((failure) {
        errorMsg.value = failure.message;
        isError.value = true;
      }, (_) => _completeAuth());
    }

    isLoading.value = false;
  }

  void _completeAuth() {
    state.value = state.value.copyWith(status: AuthStatus.unlocked);

    if (AppConfigService.to.vaultToken.value.isEmpty) {
      Get.offAllNamed(AppRoutes.vaultAuth);
    } else {
      Get.offAllNamed(AppRoutes.workbench);
    }
  }

  void lock() {
    _repository.lock();
    state.value = state.value.copyWith(status: AuthStatus.locked);
    Get.offAllNamed(AppRoutes.initial);
  }
}
