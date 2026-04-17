# 🛠️ Maintenance SOP: Zero Tech-Debt Policy

This document defines the mandatory maintenance procedures to ensure the **Vault Env Manager** project remains standardized, secure, and maintainable. All developers and AI agents must follow these protocols.

## 🏁 The Sam-Sam Standard

1.  **Rule of 200**: No single Dart file shall exceed **200 lines**. No single `build()` method shall exceed **100 lines**.
2.  **Result Pattern Absolute**: All fallible side-effects (IO, API, Crypto) must return `Either<Failure, T>`.
3.  **DI Purity**: Use interfaces for all repository and service injections. No concrete implementation imports in the presentation layer.
4.  **Zero-Leak Analysis**: No task is complete until `flutter analyze` reports **0 issues**.

---

## 🔍 One-Command Audit

Run the following command to identify any files violating the **Rule of 200**:

```bash
find lib -name "*.dart" | xargs wc -l | sort -nr | awk '$1 > 200 {print $0}'
```

### Protocol for Large Files (>200 lines)
If a file exceeds 200 lines, you **MUST** refactor it before proceeding with new features:
1.  **Extract Widgets**: Move sub-widgets into `lib/src/features/[feature]/presentation/widgets/`.
2.  **Extract Logic**: Move business logic into `UseCases` or `LogicManagers`.
3.  **Extract Helpers**: Move non-core utilities into `lib/src/shared/utils/`.

---

## 🛡️ Security Audit

Before every release or major PR, verify that sensitive data is stored securely:
1.  **Grep for Unsafe Storage**:
    ```bash
    grep -r "saveNormal" lib | grep "token"
    ```
2.  **Requirement**: Any token or credential must use `saveSecure()`.

---

## 📈 Milestone Updates

Always update `AGENT_STATE.md` after:
- Completing a Phase of the Implementation Plan.
- Resolving a critical architectural violation.
- Achieving a new 100% Green test suite.

---
*Protocol: Active. Quality: Absolute. Tech-Debt: Zero.*
