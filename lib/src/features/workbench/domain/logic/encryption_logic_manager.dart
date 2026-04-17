import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/decrypt_data.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/encrypt_data.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/encryption_algorithm.dart';
import 'package:vault_env_manager/src/features/workbench/domain/value_objects/secret_key.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

class EncryptionLogicManager extends GetxService {
  final EncryptData _encryptData;
  final DecryptData _decryptData;
  final LogService _log = Get.find<LogService>();

  EncryptionLogicManager(this._encryptData, this._decryptData);

  final isProcessing = false.obs;
  final selectedAlgorithm = 'aes-256-cbc'.obs;
  final algorithms = [
    'aes-256-cbc',
    'aes-256-gcm',
    'aes-128-gcm',
    'aes-128-cbc',
  ].obs;

  final masterKey = ''.obs;
  final decryptedReference = ''.obs;

  String get secureKeyMasked {
    if (masterKey.value.isEmpty) return 'No Master Key Set';
    if (masterKey.value.length < 8) return '*' * masterKey.value.length;
    return '${masterKey.value.substring(0, 4)}${'*' * (masterKey.value.length - 8)}${masterKey.value.substring(masterKey.value.length - 4)}';
  }

  Future<void> encrypt(String plaintext, Function(String) onSuccess) async {
    if (masterKey.value.isEmpty) return;
    isProcessing.value = true;

    final result = await _encryptData(
      plaintext,
      SecretKey(masterKey.value),
      EncryptionAlgorithm(selectedAlgorithm.value),
    );

    result.fold((f) => _log.error('Encryption failed: ${f.message}'), (s) {
      String clean = s;
      if (clean.startsWith('base64:')) clean = clean.substring(7);
      if (clean.startsWith(':')) clean = clean.substring(1);
      onSuccess(clean);
      _log.success('Data encrypted.');
    });
    isProcessing.value = false;
  }

  Future<void> decrypt(String ciphertext, Function(String) onSuccess) async {
    if (masterKey.value.isEmpty) return;
    isProcessing.value = true;

    final result = await _decryptData(
      ciphertext,
      SecretKey(masterKey.value),
      EncryptionAlgorithm(selectedAlgorithm.value),
    );

    result.fold((f) => _log.error('Decryption failed: ${f.message}'), (s) {
      onSuccess(s);
      _log.success('Data decrypted.');
    });
    isProcessing.value = false;
  }

  Future<String> silentDecrypt(String ciphertext) async {
    if (ciphertext.isEmpty || masterKey.value.isEmpty) return '';

    final result = await _decryptData(
      ciphertext,
      SecretKey(masterKey.value),
      EncryptionAlgorithm(selectedAlgorithm.value),
    );

    return result.fold((_) => '', (s) => s);
  }

  void regenKey(Function(String) onGenerated) {
    final bytes = List.generate(32, (_) => Random().nextInt(256));
    final key = 'base64:${base64Url.encode(bytes)}';
    onGenerated(key);
    _log.info('New secure key generated.');
  }
}
