# 🚀 CI/CD & Infrastructure Workflow

This workflow ensures **High-Refresh-Rate Quality** through automated validation, safe migrations, and multi-platform deployment.

## 🛠️ Phase 1: Quality Gate (PR Validation)
- **Static Analysis**: `flutter analyze` and `dart format`.
- **Security Check**: Verify zero plaintext secrets in `lib/`.
- **Testing**: Run all Gherkin and Unit tests via `flutter test`.

## 📦 Phase 2: Deployment (Codemagic & GitHub Actions)
- **Mobile**: Build signed AAB/IPA for stores via Codemagic.
- **Desktop**: Build Universal Binaries for macOS, Windows, and Linux via GitHub Actions.
- **Size Audit**: Compare binary sizes with previous builds; fail if >1MB increase without reason.

## 🔐 Android/Apple Signing (Release)
- **Android**: Set `ANDROID_KEYSTORE_BASE64`, `PASSWORD`, `ALIAS`, and `KEY_PASSWORD` as secrets.
- **Apple**: Set `APPLE_CERTIFICATE_BASE64` and `APPLE_PROVISIONING_PROFILE`.
- **Runner**: Use `macos` and `xcode` tags for iOS/macOS GitLab runners.

## 🔄 Path: Safe Migration (MIGRATION)
1.  **Dependency Audit**: Run `flutter pub outdated` to identify upgrade candidates.
2.  **Staging Test**: Apply updates to a branch and run the full test suite.
3.  **Breaking Change Review**: Check changelogs for major version bumps.
4.  **Final Sync**: Run `flutter pub get` and commit the updated `pubspec.lock`.

## 🎨 Path: Design System Sync (DESIGN_SYSTEM)
1.  **Token Update**: Modify variables in `lib/src/shared/design_system/tokens/`.
2.  **Component Audit**: Verify all **Atoms** use the updated tokens.
3.  **Visual Regression**: Run widget tests to ensure UI integrity across themes.
4.  **Squircle Check**: Ensure all corners maintain the 14dp "RadiusOS" standard.

## 🔑 Phase 5: Secret Hardening
- **Environment**: Never store `.env` in the repo.
- **Vault Parity**: Ensure the `APP_KEY` used in CI matches the project's **Laravel-standard AES** expectations.

---
*Status: Active. Automation: 100%. Distribution: Multi-Platform.*
