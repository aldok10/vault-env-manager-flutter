import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/app/data/services/laravel_env_service.dart';
import 'package:vault_env_manager/src/shared/utils/code_editor_controller.dart';

mixin WorkbenchEditorActions on GetxController {
  AppConfigService get config;
  LaravelEnvService get laravelEnvService;

  final CodeEditorController plaintextController = CodeEditorController();
  final CodeEditorController ciphertextController = CodeEditorController();

  final selectedSyntax = '.env'.obs;
  final syntaxes = ['.env', '.json', '.yml', '.toml', '.conf'].obs;
  final isEnvParsedView = false.obs;
  final plaintextStats = '0L:0C'.obs;
  final ciphertextStats = '0L:0C'.obs;
  final livePlaintext = ''.obs;

  void updateStats() {
    livePlaintext.value = plaintextController.text;
    plaintextStats.value =
        '${plaintextController.text.split('\n').length}L:${plaintextController.text.length}C';
    ciphertextStats.value =
        '${ciphertextController.text.split('\n').length}L:${ciphertextController.text.length}C';
  }

  void updateSyntax() {
    plaintextController.updateSyntax(selectedSyntax.value);
    ciphertextController.updateSyntax(selectedSyntax.value);
  }

  void toggleEnvView() {
    if (plaintextController.text.isEmpty) return;
    isEnvParsedView.value = !isEnvParsedView.value;
    if (isEnvParsedView.value) {
      final parsed = laravelEnvService.parse(plaintextController.text);
      if (parsed.isEmpty) isEnvParsedView.value = false;
    }
  }

  void swapEditors() => config.setIsFlipped(!config.isFlipped.value);
  void clearPlaintext() => plaintextController.clear();
  void clearCiphertext() => ciphertextController.clear();

  Future<void> pasteToPlaintext() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) plaintextController.text = data!.text!;
  }

  Future<void> pasteToCiphertext() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) ciphertextController.text = data!.text!;
  }

  void disposeEditors() {
    plaintextController.dispose();
    ciphertextController.dispose();
  }
}
