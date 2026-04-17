---
name: Vault Cryptography & Security
description: Implementation of industrial-grade encryption, key derivation, and secure payload handling for the Vault Env Manager project.
---

# 🔐 Vault Cryptography & Security

This skill defines the mandatory cryptographic standards and implementation patterns for the **Vault Env Manager**

## 🛡️ 1. Mandatory Primitives

All cryptographic operations must use the `package:cryptography` library for high-performance, platform-optimized execution.

### ✅ AES-GCM (Authenticated Encryption)
Mandatory for all sensitive payloads. AES-GCM ensures both **Confidentiality** and **Integrity** (Authenticity). 
- **Encryption**: Use `AesGcm.with256bits()`.
- **Nonce (IV)**: MUST be unique for every single encryption operation. Never reuse a (key, nonce) pair.
- **MAC (Tag)**: GCM provides a 16-byte authentication tag. Verification is mandatory and handled by `decryptString`.
- **Persistence**: Store the `SecretBox` (Nonce + Ciphertext + MAC) as a concatenated recovery byte array.

### ✅ PBKDF2 (Key Derivation)
Used to derive a strong 256-bit key from a user-provided password.
- **Algorithm**: `Pbkdf2` with `Hmac.sha256()`.
- **Iterations**: Mandatory **100,000+** iterations.
- **Salt**: MUST be a unique, cryptographically secure random 16-byte value per password/vault. Never hardcode.
- **Performance**: Always offload to a background `Isolate` (see Section 2).

---

## 🏗️ 2. Performance & Isolate Offloading

Cryptographic operations (especially PBKDF2) are CPU-intensive and will cause "jank" if run on the main UI thread.

### The "Isolate Rule" (Modern Dart)
Perform all key derivation and bulk encryption inside a background `Isolate` using `Isolate.run()` for single tasks.

```dart
static Future<SecretKey> deriveKey(String password, List<int> salt) async {
  return await Isolate.run(() async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
  });
}
```

---

## 🏗️ 3. macOS Security & Keychain (Critical)

For the Desktop environment, sensitive keys must be stored in the System Keychain.

### ✅ Entitlements Configuration
You must explicitly configure these in **both** `DebugProfile.entitlements` and `Release.entitlements`.

**Required Keys**:
```xml
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)$(CFBundleIdentifier)</string>
</array>
```

### ✅ Biometric Authentication (local_auth)
Use `local_auth` for Touch ID verification before accessing the encrypted master key.

```dart
final auth = LocalAuthentication();
final bool didAuthenticate = await auth.authenticate(
  localizedReason: 'Authorize access to Secure Vault',
  options: const AuthenticationOptions(
    biometricOnly: true,
    stickyAuth: true,
  ),
);
```

---

## 🧬 4. Logic Parity & Standards Reference

Maintain 100% logic parity with the Vault core engine (e.g., Svelte/Go implementations).

| Component | standard (Dart) | Parity Target |
| :--- | :--- | :--- |
| **KDF** | `Pbkdf2` (100k) | `PBKDF2-HMAC-SHA256` |
| **Cipher** | `AesGcm` (256-bit) | `AES-GCM-256` |
| **MAC** | `Hmac.sha256()` | `HMAC-SHA256` |
| **Storage** | `Secure Box` | `Nonce[12] + Cipher[n] + Tag[16]` |

### Nonce & Salt Reuse Rule
- **Salt**: Randomly generated ONCE per vault/user. Stored in plaintext alongside the encrypted data.
- **Nonce**: Randomly generated for EVERY encryption call. Prepended to the ciphertext.

---

## 🧪 5. Verification Protocol

1.  **Reproduction Tests**: All security logic changes must have a corresponding test case in `test/reproduction/`.
2.  **Logic Parity Checks**: Verify that derived keys match expected test vectors from the Go/JS reference implementations.
3.  **Sanity Check**: Ensure no sensitive keys are ever logged to the console via `debugPrint`.

---
*Protocol: Hardened. Security: AES-GCM. Status: Industrial.*
Standards & Vault Security Policy*
