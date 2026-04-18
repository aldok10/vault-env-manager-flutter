import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';

class SecurityConfigService extends GetxService {
  static SecurityConfigService get to => Get.find();

  StorageService get _storage => Get.find<StorageService>();
  String? _activeProfileId;

  static const String _kCipherPass = 'cipher_pass';

  final RxString cipherPass = ''.obs;

  Future<SecurityConfigService> init(String profileId) async {
    _activeProfileId = profileId;

    final String prefix = '${profileId}_';
    cipherPass.value =
        await _storage.get('$prefix$_kCipherPass', isSecure: true) ?? '';
    return this;
  }

  Future<void> setCipherPass(String hash) async {
    cipherPass.value = hash;
    final String prefix =
        _activeProfileId != null ? '${_activeProfileId}_' : '';
    await _storage.saveSecure('$prefix$_kCipherPass', hash);
  }
}
