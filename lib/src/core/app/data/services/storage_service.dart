import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception raised when [StorageService.init] cannot bring up a backing
/// store that is safe to hold secrets in.
///
/// Previously `init()` swallowed `PlatformException` / generic errors from
/// `flutter_secure_storage` and transparently switched every secure key
/// to an in-memory `Map<String, String>` — a silent downgrade from
/// OS-keychain-protected storage to plaintext RAM. Callers persisting a
/// vault master hash or an auth token would have no idea that the secret
/// was (a) never reaching the keychain and (b) gone the moment the
/// process exited. This exception is now thrown in preference to that
/// fallback so the app can surface a clear, user-visible error.
final class SecureStorageUnavailableException implements Exception {
  final String message;
  final Object? cause;
  const SecureStorageUnavailableException(this.message, {this.cause});

  @override
  String toString() => cause == null
      ? 'SecureStorageUnavailableException: $message'
      : 'SecureStorageUnavailableException: $message (cause: $cause)';
}

/// Thin façade over [FlutterSecureStorage] (keychain-backed) and
/// [SharedPreferences] (disk plaintext).
///
/// The contract is simple and explicit:
///
///  * `saveSecure` / `get(..., isSecure: true)` / `delete(..., isSecure: true)`
///    always go to the OS secure store. If the secure store is unavailable
///    they throw — they never silently write plaintext.
///  * `saveNormal` / `get(..., isSecure: false)` / `delete(..., isSecure: false)`
///    always go to `SharedPreferences`. Those values are **not** secret;
///    callers must not use them for passwords, hashes, or auth tokens.
///
/// See [SecureStorageUnavailableException] for the rationale behind the
/// fail-loud behaviour.
class StorageService extends GetxService {
  StorageService({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  }) : _secureStorageOverride = secureStorage,
       _prefsOverride = sharedPreferences;

  /// Test-only override for the secure store. When non-null, [init]
  /// skips construction of the real `FlutterSecureStorage` and uses
  /// this instance instead.
  final FlutterSecureStorage? _secureStorageOverride;

  /// Test-only override for shared preferences. When non-null, [init]
  /// skips `SharedPreferences.getInstance()` and uses this instance.
  final SharedPreferences? _prefsOverride;

  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  bool _isInitialized = false;

  static StorageService get to => Get.find<StorageService>();

  /// Brings up both backing stores. Throws
  /// [SecureStorageUnavailableException] if either store cannot be
  /// initialised — secret data must never live in RAM-only fallback.
  Future<StorageService> init() async {
    if (_isInitialized) return this;

    try {
      _secureStorage =
          _secureStorageOverride ??
          const FlutterSecureStorage(
            mOptions: MacOsOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

      // Probe the secure store once so that a missing keychain entitlement
      // or a locked keyring surfaces here, at startup, rather than on the
      // first write deep inside an unlock flow where the failure is far
      // less actionable. We read a throw-away key; `null` is fine.
      if (_secureStorageOverride == null) {
        await _secureStorage.read(key: '__storage_service_probe__');
      }
    } on PlatformException catch (e) {
      throw SecureStorageUnavailableException(
        'Secure storage backend (FlutterSecureStorage) is unavailable: '
        '${e.message}. Refusing to fall back to in-memory plaintext for '
        'secret data.',
        cause: e,
      );
    } catch (e) {
      throw SecureStorageUnavailableException(
        'Secure storage backend (FlutterSecureStorage) could not be '
        'initialised. Refusing to fall back to in-memory plaintext for '
        'secret data.',
        cause: e,
      );
    }

    try {
      _prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    } catch (e) {
      throw SecureStorageUnavailableException(
        'SharedPreferences could not be initialised: $e',
        cause: e,
      );
    }

    _isInitialized = true;
    debugPrint('StorageService: secure storage + SharedPreferences ready.');
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
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> saveNormal(String key, String value) async {
    _ensureInitialized();
    await _prefs.setString(key, value);
  }

  Future<String?> get(String key, {bool isSecure = true}) async {
    _ensureInitialized();
    if (isSecure) {
      return _secureStorage.read(key: key);
    }
    return _prefs.getString(key);
  }

  Future<void> delete(String key, {bool isSecure = true}) async {
    _ensureInitialized();
    if (isSecure) {
      await _secureStorage.delete(key: key);
      return;
    }
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    _ensureInitialized();
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
