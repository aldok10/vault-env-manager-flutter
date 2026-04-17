---
name: coding_standards.md
trigger: glob
globs: lib/**/*.dart, test/**/*.dart
description: Mandatory Dart/Flutter coding standards and Desktop-specific patterns.
---

# 🧬 Coding Standards & Style Guide

This project maintains high-quality standards for maintainability and consistency. Every Dart file must adhere to these conventions.

## 🏷️ Naming Convention Rule
-   **Files**: All files and folders must be `snake_case.dart`.
-   **Private Members**: Must start with an underscore (e.g., `_isProcessing`, `_handleTap`).
-   **Public Members**: Must be descriptive and follow `camelCase` (e.g., `executeVaultSync()`).
-   **Booleans**: Name boolean variables with descriptive prefixes (`is`, `has`, `should`, `can`).

## 🧩 Structure & Immutability Rule
-   **Immutability**: Prioritize `final` and `const` for all objects to optimize memory performance.
-   **Equatable**: Use **Equatable** for all models, states, and entities. Limit state mutation to strictly defined controller methods.
-   **Constructors**: Use `const` constructors where possible to improve Flutter rendering performance.
-   **Final Locals**: Use `final` for all local variables that are not reassigned.

## ⚡ Async/Await & Performance Rule
-   **Parallel Execution**: Use `Future.wait` when executing multiple independent asynchronous calls.
-   **Heavy Work**: Move JSON parsing or encryption for payloads >10KB to background threads via `ComputeService` (Isolates).
-   **Constructors**: Use `const` constructors wherever possible to maximize Flutter rendering performance.
-   **Assets**: Prioritize **SVG** for icons and **WebP** for images. Run the `/asset_management` workflow periodically.
-   **Animations**: Wrap complex or high-frequency animations in `RepaintBoundary`.

## 📝 Comment & Documentation Rule
-   **Public API**: Every public class and repository method MUST have Dart documentation comments (`///`).
-   **Complex Logic**: Mandatory documentation for every Logic/Business Use Case that exceeds simple CRUD operations.
-   **TODOs**: Use `// TODO: [Context]` to mark incomplete work.

---

## 🔒 Security Standards Rule
-   **Encryption**: Mandatory use of **AES-GCM (256-bit)** for sensitive data persistence.
-   **Key Derivation**: Use **PBKDF2 (100k iterations)** with a random salt for user-defined keys.
-   **Sanitization**: All user input must be sanitized against path traversal before being used in filesystem operations.
-   **Zero Secrets**: Hardcoded API keys or secrets are FORBIDDEN. Use `AppConfigService` or `.env` injection.

---

## ✅ DOs
-   **DO** use **Equatable** to simplify value comparisons.
-   **DO** organize Imports: (1) Dart (2) Flutter (3) Packages (4) Project Internal.
-   **DO** keep methods focused (Single Responsibility). If a method exceeds 50 lines, refactor it.
-   **DO** follow the **Rule of 200**: No file should exceed 200 lines (Refactor into molecules/mixins).

## ❌ DON'Ts
-   **DON'T** use `print()` for logging; use `AppLogger` or `debugPrint`.
-   **DON'T** use dynamic types unless absolutely necessary. Be explicit with typing.
-   **DON'T** use `Colors.all(Colors.red)` for styling; use `AppColors`.

---

## 🔍 Linter Alignment
This project syncs with `analysis_options.yaml`. Key enforced rules:
- `always_declare_return_types`: Mandates explicit return types.
- `prefer_final_locals`: Enforces immutability for local variables.
- `unawaited_futures`: Prevents starting futures without handling them.
- `prefer_const_constructors`: Maximizes rendering performance.
