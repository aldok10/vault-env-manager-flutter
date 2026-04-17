---
name: flutter-testing-expert
description: Enterprise-grade testing protocols for multi-platform high-fidelity applications.
---

# 🤖 Flutter Testing Expert

Use this skill to maintain the "Sam-Sam" standard (Security, Aesthetics, Performance) via automated verification.

## 📊 1. The 4 Testing Pillars

1.  **Unit Tests**: Logic verification in Domain (UseCases) and Data (Mappers). Use `mocktail` for dependency isolation.
2.  **Widget Tests**: UI component verification. Use `Robot Pattern` to abstract finders.
3.  **Golden Tests**: Pixel-perfect UI verification. Ensure **SF Symbols** and **Outfit Fonts** are loaded.
4.  **Integration Tests**: End-to-end (E2E) verification on real/emulated hardware.

## 🚀 2. Robot UI Pattern (AAA)

Encapsulate interactable UI elements into "Robot" classes (`test/robots/`) to keep tests scannable and maintainable.

```dart
// test/robots/vault_robot.dart
class VaultRobot {
  final WidgetTester tester;
  VaultRobot(this.tester);

  Future<void> enterPassword(String pwd) async {
    await tester.enterText(find.byType(TextField), pwd);
  }
}
```

## 🏗️ 3. CI/CD Build Matrix (GitHub Actions)

Deploy for all supported platforms (macOS, Windows, Linux, iOS, Android).

### Matrix Strategy:
- **macOS**: `flutter build macos --release`. Needs Apple Developer ID for signing.
- **Windows**: `flutter build windows --release`. Needs `.msix` packaging.
- **Linux**: `flutter build linux --release`. Needs `libayatana-appindicator3-dev`.

## 🧪 4. Gherkin BDD Strategy

For complex flows, use `.feature` files to define user scenarios before implementation.

```gherkin
Feature: Vault Locking
  Scenario: Automated lock after inactivity
    Given I have an open vault
    When I am inactive for 5 minutes
    Then the vault should be locked automatically
```

---
*Protocol: Active. Quality: Guaranteed.*
