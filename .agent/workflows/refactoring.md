---
description: AI-driven workflow for detecting and resolving code smells.
---

# 🧹 Automated Refactoring Workflow (Rule of 200)

Use this workflow periodically to ensure the codebase remains at the **"Sam-Sam" standard** of technical excellence and high-fidelity architecture.

## 🔍 Phase 1: Structural & Boundary Audit
- **Action**: Use `list_dir` on `lib/features/` to verify folder symmetry.
- **Boundary Check**: Ensure all feature folders follow the strict `{domain, data, presentation}` structure.
- **Leaky Layer Check**: Search for `_impl.dart` or `data/` imports inside any `presentation/` or `domain/` directories.
    - *Fix*: Decouple via Domain Interfaces and Dependency Injection.

## 📏 Phase 2: Cognitive Load Audit (The Rule of 200)
- **Limit**: NO file should exceed **200 lines**.
- **Target**: Classes with too many methods or Widgets with massive `build()` methods.
- **Action**:
    - Split complex Widgets into smaller **Atoms**, **Molecules**, or **Organisms** in `lib/src/shared/design_system/`.
    - Extract business logic from Controllers into dedicated **Mixins** or **UseCases**.
- **Constraint**: If a file exceeds 200 lines, refactoring is MANDATORY before any new feature work.

## 🧪 Phase 3: Code Smell Detection (The "High-Fidelity" Filter)
- **Token Infringement**: Search for hardcoded `Colors.*`, `EdgeInsets.*`, or `TextStyle`.
    - *Action*: Refactor to use `AppColors`, `AppSpacing`, and `AppTypography` from the Design System.
- **Logic in UI**: Identify `if/else`, `loops`, or `async` calls directly in `build()` or `onTap`.
    - *Action*: Move to a `Controller` or `UseCase`.
- **Magic Strings/Numbers**: Search for hardcoded IDs, URL segments, or timeout durations.
    - *Action*: Move to `AppConstants` or Environment Variables.
- **Nested Ternaries**: High-complexity UI logic in build methods.
    - *Action*: Extract into private helper methods or dedicated getter widgets.

// turbo
## 🛠️ Phase 4: Automated Correction & Formatting
- **Action**: Run `dart fix --apply` to resolve all "fixable" lints.
- **Action**: Run `dart format .` to ensure 100% style consistency.
- **Action**: Run `flutter analyze` to verify the project is "Issue-Free".

// turbo
## 📑 Phase 5: Technical Debt Logging
- **Action**: Update `AGENT_STATE.md` with:
    - **Refactored Components**: List of files touched.
    - **Aesthetic Improvements**: Token transitions made.
    - **Remaining Debt**: Any "Rule of 200" violations that require human architectural decisions.

---
*Status: Active. Code Quality: Mandatory. Debt: Zero.*
