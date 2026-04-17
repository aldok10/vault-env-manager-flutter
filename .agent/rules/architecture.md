---
name: architecture.md
trigger: always_on
description: Mandatory Clean Architecture and Layered Dependency rules.
---

# 🏗️ Architecture Guildelines

This project strictly follows **Feature-Oriented Clean Architecture**. Every feature must be encapsulated within its own directory under `lib/src/features/`, following the layer separation below.

## 🏗️ Clean Architecture Rule

1.  **Domain (Core)**: 
    - Contains strictly **Business Logic**. 
    - Includes `models`, `repositories` (interfaces), and `usecases`.
    - **DEPENDENCY RULE**: Must NOT import from `Data` or `Presentation` layers. Must be **Pure Dart** (no Flutter imports).
2.  **Data (Infrastructure)**: 
    - Implementation of repository interfaces.
    - Contains `data_sources` (remote/local api calls) and `mappers`.
    - **DEPENDENCY RULE**: Imports `Domain` to implement its interfaces.
3.  **Presentation (UI/UX)**: 
    - Front-end logic.
    - Contains `pages`, `controllers` (GetX), and `widgets`.
    - **DEPENDENCY RULE**: Imports `Domain` to execute business logic. Must NOT import from `Data`.
    - **Strict Constraint**: UI logic must be decoupled from data implementations via interfaces.
    - **Reactivity Pattern**: Standardize on `Obx` for high-density reactive UI; wrap ONLY the smallest possible changing widget.

---

## ✅ DOs
- **DO** use GetX `Bindings` to inject dependencies at the feature level.
- **DO** return `Either<Failure, Success>` (Result Pattern) from repository methods and usecases.
- **DO** keep the `Domain` layer pure Dart (avoid Flutter-specific imports where possible).
- **DO** use the `core/design_system` for all UI components.
- **DO** ensure all Side-Effects are encapsulated within `Controllers` or `UseCases`.

## ❌ DON'Ts
- **DON'T** instantiate a Repository Implementation directly in a Controller. Use Dependency Injection.
- **DON'T** let the `Domain` models depend on JSON serialization logic (keep that in the `Data` layer models if possible, or use `Equatable`).
- **DON'T** import `lib/src/features/x/data/...` inside `lib/src/features/y/presentation/...`.
- **DON'T** use `Get.find<RepositoryImpl>()` — always resolve by **interface** type (`Get.find<IRepository>()`).
- **DON'T** register feature-level dependencies in `InitialBinding` if they depend on async services.
- **DON'T** bypass the DI layer for any unit-testable component. **DI is mandatory**.
- **DON'T** attempt to access reactive state before it's registered in `main.dart`.

---

## 💉 Dependency Injection Rules (GetX)

1.  **Interface-Based DI**: All repositories MUST be registered with their interface type:
    ```dart
    // ✅ Get.lazyPut<IVaultRepository>(() => VaultRepositoryImpl(...), fenix: true);
    // ❌ Get.lazyPut(() => VaultRepositoryImpl(...));
    ```
2.  **3-Tier Registration**:
    - **Tier 1 (InitialBinding)**: Zero-dependency globals only (`http.Client`).
    - **Tier 2 (InitialLoaderController)**: Async services via `Get.putAsync(permanent: true)` — MUST be awaited in `main.dart` before `runApp`.
    - **Tier 3 (Route Binding)**: Feature repos, use cases, controllers — all `fenix: true`.
3.  **No Cross-Feature DI**: A feature's binding should not register another feature's dependencies.
4. **Security Primitives (Infrastructure)**:
    - All encryption MUST use `AesGcm` (256-bit).
    - All key derivation MUST use PBKDF2 with 100,000 iterations.
    - Sensitive data MUST be stored in `flutter_secure_storage` with platform-specific secure options.
5. **Error Handling & Failure Types**:
    - Use `Either<Failure, T>` from `dartz` for all domain/data operations.
    - Define domain-specific failures: `SecurityFailure`, `AuthFailure`, `VaultFailure`.
    - Always preserve the original stack-trace in `AnalyticalFailure` for debugging.

---

## 🛠️ Code Examples

### Good Practice (Repository Interface)
```dart
// lib/features/workbench/domain/repositories/vault_repository.dart
abstract class VaultRepository {
  Future<Either<Failure, String>> encryptData(String plainText, String key);
}
```

### Bad Practice (Bypassing Layers)
```dart
// lib/features/workbench/presentation/controllers/workbench_controller.dart
// ❌ BAD: Directly importing implementation and calling HTTP
import '../../data/repositories/vault_repository_impl.dart';

class WorkbenchController extends GetxController {
  final repo = VaultRepositoryImpl(); // ❌ NO: Use DI/Get.find()
}
```

### Recommended Tooling
- Use `/add_feature` workflow to scaffold new features correctly.
