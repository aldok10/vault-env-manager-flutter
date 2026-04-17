import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;

  bool _isInitialized = false;
  final Map<String, String> _secureInMemoryFallback = {};
  bool _usingFallback = false;

  static StorageService get to => Get.find<StorageService>();

  Future<StorageService> init() async {
    if (_isInitialized) return this;

    try {
      // Standard configuration for secure storage
      _secureStorage = const FlutterSecureStorage(
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint(
        'StorageService: Standard secure storage initialized successfully.',
      );
    } on PlatformException catch (e) {
      debugPrint(
        'StorageService: Platform Channel Error during init: ${e.message}',
      );
      debugPrint('Details: ${e.details}');
      _usingFallback = true;
      _isInitialized = true;
    } catch (e) {
      debugPrint(
        'StorageService: Generic initialization warning. Falling back to in-memory: $e',
      );
      _usingFallback = true;
      _isInitialized = true;
    }
    return this;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'StorageService: Accessing storage before init() completion.',
      );
    }
  }

  Future<void> saveSecure(String key, String value) async {
    _ensureInitialized();
    if (_usingFallback) {
      _secureInMemoryFallback[key] = value;
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> saveNormal(String key, String value) async {
    _ensureInitialized();
    if (_usingFallback) {
      _secureInMemoryFallback[key] = value;
      return;
    }
    await _prefs.setString(key, value);
  }

  Future<String?> get(String key, {bool isSecure = true}) async {
    _ensureInitialized();
    if (_usingFallback) {
      return _secureInMemoryFallback[key];
    }
    if (isSecure) {
      return await _secureStorage.read(key: key);
    } else {
      return _prefs.getString(key);
    }
  }

  Future<void> delete(String key, {bool isSecure = true}) async {
    _ensureInitialized();
    if (_usingFallback) {
      _secureInMemoryFallback.remove(key);
      return;
    }
    if (isSecure) {
      await _secureStorage.delete(key: key);
    } else {
      await _prefs.remove(key);
    }
  }

  Future<void> clear() async {
    _ensureInitialized();
    if (_usingFallback) {
      _secureInMemoryFallback.clear();
      return;
    }
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
