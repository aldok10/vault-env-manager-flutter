# 🔄 Versioning Protocol (V4.1)

This workflow ensures that the project versioning maintains **High-Fidelity Distribution Readiness**. We follow standard Semantic Versioning (`Major.Minor.Patch+Build`).

---

## 🚀 Version Commands (CLI)

Use the automated versioning tool to safely increment `pubspec.yaml`:

- **Increment Patch**: `dart bin/version_bump.dart --patch`
- **Increment Build**: `dart bin/version_bump.dart --build`
- **Increment Minor**: `dart bin/version_bump.dart --minor`
- **Increment Major**: `dart bin/version_bump.dart --major`
- **Current Status**: `dart bin/version_bump.dart --status` (Non-destructive)

---

## 📦 Lifecycle Hooks

1.  **Pre-Commit (Release Branch)**: Before merging to `main`, run `dart bin/version_bump.dart --patch`.
2.  **CI Build (Artifact Generation)**: The CI/CD pipeline should use the build number `+N` for artifact uniqueness.
3.  **Sync**: Ensure `CHANGELOG.md` (or the equivalent section in `AGENT_STATE.md`) references the new version.

---

*Status: Automated. Tooling: bin/version_bump.dart.*
