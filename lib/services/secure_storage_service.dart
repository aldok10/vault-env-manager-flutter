import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> writeEncryptedEnvironmentVariables(Map<String, String> envVars) async {
    for (final entry in envVars.entries) {
      await writeSecureData(entry.key, entry.value);
    }
  }

  Future<Map<String, String>> readAllEnvironmentVariables() async {
    final allKeys = await _storage.readAll();
    return allKeys;
  }

  Future<void> deleteAllEnvironmentVariables() async {
    await _storage.deleteAll();
  }
}