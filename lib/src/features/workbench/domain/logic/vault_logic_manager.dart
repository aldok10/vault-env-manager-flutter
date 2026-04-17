import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_vault_repository.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/sync_vault_secret.dart';
import 'package:vault_env_manager/src/shared/services/log_service.dart';

class VaultLogicManager extends GetxController {
  final SyncVaultSecret _syncVaultSecret;
  final IVaultRepository _repository;
  final LogService log = Get.find<LogService>();

  VaultLogicManager(this._syncVaultSecret, this._repository);

  final isConnected = false.obs;
  final isLoading = false.obs;
  final lastPath = ''.obs;
  final lastKey = ''.obs;
  final selectedPath = ''.obs;
  final selectedName = ''.obs;
  final selectedVersion = RxnInt();
  final vaultDecryptedBaseline = ''.obs;

  void updateConnection(String origin, String token) {
    if (origin.isNotEmpty && token.isNotEmpty) {
      isConnected.value = true;
      log.info('Vault Connection Verified: $origin');
    } else {
      isConnected.value = false;
    }
  }

  Future<void> sync({
    required String path,
    String? name,
    String? specificKey,
    int? version,
    required Function(String) onDataFetched,
    required Function() onBeforeDecrypt,
  }) async {
    isLoading.value = true;
    selectedPath.value = path;
    selectedName.value = name ?? path.split('/').last;
    selectedVersion.value = version;

    final result = await _syncVaultSecret(path, version: version);

    result.fold(
      (f) {
        log.error('Vault Sync Failed: ${f.message}');
        isLoading.value = false;
      },
      (data) {
        lastPath.value = path;
        final key =
            specificKey ?? (data.keys.isNotEmpty ? data.keys.first : null);

        if (key != null) {
          lastKey.value = key;
          final val = data[key];
          final content = val is String ? val : val.toString();
          onDataFetched(content);
          onBeforeDecrypt();
          log.success('Synced: ${selectedName.value}');
        } else {
          // If no key found, pretty print the whole data map
          final content = const JsonEncoder.withIndent('  ').convert(data);
          onDataFetched(content);
          onBeforeDecrypt();
          log.warning('No specific key found at $path, returning raw data.');
        }
        isLoading.value = false;
      },
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> fetchRaw(
    String fullPath,
  ) async {
    return _repository.getSecret(fullPath);
  }

  void reset() {
    lastPath.value = '';
    lastKey.value = '';
    selectedPath.value = '';
    selectedName.value = '';
    selectedVersion.value = null;
    vaultDecryptedBaseline.value = '';
  }
}
