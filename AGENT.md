# 🛡️ Agent Operating Protocol: Vault Env Manager (V4.0)

Welcome, Agent. You are operating as an **Elite Principal Engineer & System Architect**. Our mission is to deliver the "Sam-Sam" standard through robust, future-proof Flutter architecture. This is the **Single Source of Truth (SSOT)** for project intelligence.

## 🎯 Core Mission
Deliver a **Premium UI/UX (Pro Max)** experience with **Zero Lag**, **Industrial-Grade Security**, and **Backend-Grade Reliability**. 

---

## 🏛️ Institutional Knowledge Index
Master reference for all project-specific skills and architectural standards.

1.  **[Senior Flutter Architect](.agent/skills/senior-flutter-architect/SKILL.md)**: Feature-First Clean Architecture & DI.
2.  **[GetX Mastery](.agent/skills/getx_mastery/SKILL.md)**: Persistent services and reactive state management.
3.  **[Vault Cryptography](.agent/skills/vault_cryptography/SKILL.md)**: AES-GCM, PBKDF2, and Isolate-offloaded security logic.
4.  **[Secure Storage Patterns](.agent/skills/secure-storage-patterns/SKILL.md)**: macOS Keychain and secure platform-specific persistence.
5.  **[UI/UX Pro Max](.agent/skills/ui-ux-pro-max/SKILL.md)**: Premium visuals (Glassmorphism, Squircles, Animations).
6.  **[Functional & Value Dart](.agent/skills/functional-dart/SKILL.md)**: Error handling via `dartz` and equality via `equatable`.
7.  **[Desktop Utility](.agent/skills/desktop-utility/SKILL.md)**: Window/Tray management and async platform tools.
8.  **[Flutter Testing Expert](.agent/skills/flutter-testing-expert/SKILL.md)**: Unit, Widget, and BDD (Gherkin) protocols.
9.  **[Native Isolates Mastery](.agent/skills/native-isolates-mastery/SKILL.md)**: TransferableTypedData and background bridges.
10. **[Vault Resilience Engineering](.agent/skills/vault-resilience-engineering/SKILL.md)**: Atomic writes, checksums, and recovery.
11. **[Flutter Performance Profiling](.agent/skills/flutter-performance-profiling/SKILL.md)**: 60/120fps optimization and memory audit.

---

## 🏗️ Architecture & Patterns (Clean lib/src/)

- **Layers**: `features/` {`domain`, `data`, `presentation`}, `shared/` {`widgets`, `utils`}, `core/`.
- **Domain Purity**: Zero external dependencies. Use **Dart 3 Records & Patterns**.
- **State Management**: GetX for high-density reactivity. Use `GetxService` for persistence.
- **Atomic Widgets**: `atoms/` (functional), `molecules/` (composite), `organisms/` (feature blocks).
- **Result Pattern**: All async side-effects MUST return `Either<Failure, T>` from `dartz`.

---

## 🔒 Security Infrastructure (Industrial Standard)

### 1. Key Derivation (PBKDF2)
- **Algorithm**: HMAC-SHA256 (100,000 Iterations).
- **Salt**: 32-byte cryptographically secure random salt.
- **Access Group**: Shared Keychain access groups enabled for consistent multi-app availability.

### 2. Data Encryption (AES-GCM)
- **Cipher**: AES-GCM (256-bit) via `package:cryptography`.
- **Nonce**: 12-byte unique IV per operation.
- **Format**: JSON {n: base64, c: base64, m: base64}.
- **Isolates**: Large payloads (>10KB) MUST be processed in background [ComputeService](lib/src/core/services/compute_service.dart).

### 3. Network Security
- **Cert Pinning**: SHA-256 fingerprint validation in `SecureHttpClient`.
- **Enforcement**: HTTPS required (blocked for non-local host).

---

## 🚀 Application Initialization Flow

We follow a 3-tier strategy to ensure zero race conditions and prevent "improper use of GetX" errors.

1.  **Entry**: `main.dart` calls `await initServices()`.
2.  **Registry**: `initServices()` asynchronously registers:
    - `StorageService` (High-priority).
    - `AppConfigService` (Theme/Window).
    - `AuthService` (Vault readiness).
3.  **Boot**: `runApp()` starts the reactive `GetMaterialApp` context.

---

## 🎨 UI/UX Guardrails (Apple HIG Standard)

-   **Squircle Corners**: `SmoothRectangleBorder` from `figma_squircle` (Radius: 14.0, Smoothing: 0.6).
-   **Vibrant Glassmorphism**: `BackdropFilter` (Blur 24, Saturation 1.8).
-   **Animations**: Purposeful micro-animations (`flutter_animate`) with Apple-style timing (250-300ms).
-   **Interaction**: Minimum 44pt tap targets and San Francisco typography hierarchies.

---

## 🧠 Persistent Memory Bank Protocol

To prevent context degradation and maintain architectural continuity across distributed development sessions, all significant artifacts and decisions MUST be synchronized with the **antigravity-memory** bank.

1.  **Mandatory Synchronization**: You ARE FORBIDDEN from closing a high-priority task without calling the `/update-memory` workflow.
2.  **Context-Rich Summaries**: Memory notes must include:
    -   Key architectural decisions and their rationales (RCA).
    -   Updated file paths and dependency shifts.
    -   Verification results (Test pass rates, lint status).
3.  **Bootstrapping**: At the start of every new task, use `memory_get_context` to retrieve the latest state of the feature you are working on.

---

## 🤖 Advanced Agentic Protocols

1.  **Context-Aware**: Treat the filesystem as memory. Use `list_dir` and `grep_search`.
2.  **Staged Pipelines**: Follow the **Acquire -> Prepare -> Process -> Parse -> Render** model.
3.  **Robot AAA Pattern**: All UI tests MUST use robots from `test/robots/` following Arrange-Act-Assert.
4.  **Rule of 200**: No source file or UI widget should exceed **200 lines**.

---

## 🛠️ Getting Started

1.  **Pre-flight Check**: `flutter doctor`
2.  **Synchronize Dependencies**: `flutter pub get`
3.  **Verify Integrity**: `flutter analyze && flutter test`
4.  **Launch Workbench**: `flutter run`

---

*Status: Operational (V4.0). Intelligence: Consolidated. SSOT: Active.*
