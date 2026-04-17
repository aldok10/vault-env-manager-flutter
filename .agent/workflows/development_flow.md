# 🚀 Development Flow Workflow

This workflow ensures strict and systematic development, bug fixing, and review processes with a focus on high-fidelity results and low cognitive load.

## 🟢 Path A: Feature Development (ADD_FEATURE)
1.  **Specification (BDD)**: Write Gherkin scenarios in `test/features/` to lock system behavior.
2.  **Domain/Entities**: Define **UseCase** and **Entity** in `lib/src/features/[feature]/domain/`.
3.  **Data/Infrastructure**: Implement **Repository** interfaces and API/Local data sources.
4.  **Presentation/UI**: Build **Atoms** first, then Molecules/Organisms, and connect to **GetX Controllers**.
5.  **Binding**: Register dependencies in the feature's `Binding` using `fenix: true`.

## 🟡 Path B: Bug Fixing (FIX_BUG / FIX_UI)
1.  **Reproduction**: Create a failing test case in `test/reproduction/` or verify using `flutter_driver`.
2.  **Root Cause Analysis (RCA)**: Identify the technical debt or logic error.
3.  **Atomic Fix**: Apply the fix while respecting the **Rule of 200** lines.
4.  **Regression Check**: Run full test suites to ensure zero side-effects.

## 🔵 Path C: Review & Hardening (REVIEW_PROTOCOL)
1.  **Static Analysis**: Run `flutter analyze` and `dart fix --apply`.
2.  **Cognitive Audit**: Ensure no file exceeds 200 lines and no method exceeds 50 lines.
3.  **Security Audit**: Verify encryption (AES-GCM) and key derivation (PBKDF2) compliance.
4.  **Aesthetics Audit**: Check for Squircle corners (14dp), glassmorphism, and contrast (4.5:1).

## 🔬 Testing Cycle (TDD)
- **RED**: Write failing unit/widget/integration tests.
- **GREEN**: Write minimal code to pass tests.
- **REFACTOR**: Cleanup code without breaking tests.

---
*Status: Active. Workflow: Consolidated & Optimized.*
