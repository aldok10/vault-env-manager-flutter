---
name: secure-storage-patterns
description: Platform-specific secure persistence strategies for the Master Key.
---

# 🔐 Secure Storage Patterns

Use this skill to ensure the "Industrial Security" pillar of the Vault Master project.

## 🧩 1. macOS Integration: Keychain

For **macOS Desktop**, always configure `MacOsOptions` to ensure the vault remains accessible even after reboots or app restarts.

```dart
const storage = FlutterSecureStorage(
  mOptions: MacOSOptions(
    accessibility: KeychainAccessibility.after_first_unlock,
    useKeychainServiceFromAppGroup: false, 
  ),
);
```

### Accessibility Levels:
- **`first_unlock`**: Accessible while the device is locked after its first unlock.
- **`after_first_unlock`**: Highest security for background processes.
- **`when_unlocked`**: Recommended for high-sensitivity data while the app is in the foreground.

## 🚨 2. Error Recovery: Initialization Protocol

Keychain operations can fail with native OS errors (e.g. `-34018` for missing entitlements). Always "Warm-up" the storage on app start.

```dart
Future<void> warmUpStorage() async {
  try {
    await _storage.read(key: 'initialized_check');
  } catch (e) {
    if (e.toString().contains('-34018')) {
      // Trigger user-recovery flow (Entitlement mismatch)
    }
  }
}
```

## 🏗️ 3. Strategy: Key Separation (Industrial)

- **The Gold Rule**: Never store the Encrypted Vault Payload and the Master Key in the same physical storage.
- **Master Key**: Keychain (`FlutterSecureStorage`).
- **Payload**: Local file system (Encrypted via AesGcm).

## ⚠️ 4. Anti-Patterns

- **Plain Text Persistence**: Never assumption that `shared_preferences` is secure. It is NOT encrypted on disk.
- **Hardcoded Salts**: Every vault MUST generate a random salt (`16-32 bytes`) and store it alongside the encrypted data.

---
*Protocol: Active. Storage: Hardened.*
