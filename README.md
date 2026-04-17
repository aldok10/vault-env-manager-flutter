# 🛡️ Vault Env Manager (V5.0)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean--Feature-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![Security](https://img.shields.io/badge/Security-AES--GCM--256-red.svg)](https://en.wikipedia.org/wiki/Galois/Counter_Mode)
[![License](https://img.shields.io/badge/License-Proprietary-black.svg)](#)

**Vault Env Manager** is an elite, industrial-grade desktop application designed for secure environment variable management. Built on the "Sam-Sam" standard, it combines **Industrial-Grade Security** with a **Premium Apple-Inspired UI/UX**.

---

## 🏛️ Core Pillars

### 1. Industrial-Grade Security
Built for high-stakes environments where data integrity and privacy are non-negotiable.
- **AES-GCM (256-bit)**: Galois/Counter Mode for authenticated encryption, ensuring both confidentiality and authenticity.
- **PBKDF2 Derivation**: HMAC-SHA256 with 100,000 iterations for bulletproof key derivation from master passwords.
- **macOS Keychain**: Native platform-secure persistence for sensitive tokens and keys.
- **Isolate-Offloaded**: Heavy cryptographic operations are offloaded to background threads to ensure zero UI jank.

### 2. Premium UI/UX (Pro Max)
A "Wowed at first glance" experience following Apple's Human Interface Guidelines.
- **G2/G3 Continuity**: Squircle corners (`SmoothRectangleBorder`) with 14.0 radius and 0.6 smoothing.
- **Vibrant Glassmorphism**: High-blur backdrops with saturation-boosted overlays.
- **Micro-Animations**: Purposeful, 250-300ms transitions for a "living" interface.
- **San Francisco Typography**: Precise typographic hierarchies for maximum legibility.

### 3. Feature-Oriented Clean Architecture
Standardized on the **Result Pattern** and strict layer separation.
- **Domain**: Pure Dart business logic, models, and interfaces.
- **Data**: Infrastructure implementation via repository interfaces.
- **Presentation**: GetX-powered reactive UI decoupled from data implementations.
- **DI Mastery**: 3-Tier dependency injection for performance and testability.

---

## 🚀 Feature Matrix

| Feature | Status | Description |
| :--- | :--- | :--- |
| **Workbench** | `🟢 ACTIVE` | Visual editor for environment variables with multi-vault support. |
| **Vault Auth** | `🟢 ACTIVE` | Secure entry with PBKDF2-derived master key validation. |
| **Secure Logic** | `🟢 ACTIVE` | AES-GCM encryption/decryption in background isolates. |
| **Settings** | `🟢 ACTIVE` | Global configuration and theme management. |
| **Automation** | `🟡 PENDING` | CI/CD build versioning and wiki generation. |

---

## 🛠️ Technical Deep Dive

### Security Primitive (V5.1)
```dart
// Example: Secure Payload Encryption
final cipher = AesGcm.with256bits();
final nonce = Uint8List.fromList(SecureRandom().nextBytes(12));
final encrypted = await cipher.encrypt(
  payload, 
  secretKey: masterKey, 
  nonce: nonce,
);
```

### Performance Budget
- **Startup Time**: < 800ms (Desktop).
- **Frame Target**: Stable 120 FPS via Isolate offloading.
- **Security Latency**: < 5ms encryption overhead per 10KB payload.

---

## 🏁 Getting Started

### Prerequisites
- **Flutter**: 3.x+
- **macOS**: 13.0+ (for native keychain/local_auth)
- **Dart**: ^3.11.4

### Installation
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-org/vault_env_manager.git
    ```
2.  **Synchronize Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run Pre-flight Checks**:
    ```bash
    flutter analyze && flutter test
    ```
4.  **Launch the Workbench**:
    ```bash
    flutter run -d macos
    ```

---

## ⚖️ License
This project is proprietary. All rights reserved. 2026.
