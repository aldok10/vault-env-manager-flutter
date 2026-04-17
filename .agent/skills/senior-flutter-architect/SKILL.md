---
name: senior-flutter-architect
description: Use this skill when tasked to design enterprise Flutter architectures, perform high-stakes code reviews, or refactor core modules for performance and maintainability. It enforces strict Clean Architecture (Feature-Oriented), Interface-Based DI, and advanced Desktop/Impeller optimizations.
---

# Senior Flutter Architect: Enterprise Execution Protocol (v2026)

### 🚀 Performance Orchestration (Sam-Sam Standard)
Maintain **Zero-Lag (120 FPS)** by adhering to these diagnostic and remediation tokens:
- **Repaint Boundaries**: Wrap complex or static drawing layers (e.g., `Glassmorphism`, `Lottie`) in `RepaintBoundary` to prevent redundant layer repaints.
- **Opacity Optimization**: **FORBIDDEN** to use `Opacity` widget for stationary widgets with constant alpha. Use `Color.withValues(alpha: ...)` or `withOpacity(...)` on the `Container` or `DecoratedBox`.
- **Layout Efficiency**: Use `SliverFixedExtentList` for large scrollable areas to achieve `O(1)` layout calculations.
- **Diagnostics**: Always verify frame times in DevTools; identify "Jank" if frames exceed **8ms** (120Hz) or **16ms** (60Hz).

### 🛡️ System Resilience & Reliability
Implement backend-grade reliability for handling intermittent failures:
- **Retry Logic (Exponential Backoff)**: Use for idempotent, retryable failures (e.g., `503 Service Unavailable`). Implement jitter to avoid "Thundering Herd" problems.
- **Circuit Breakers**: Prevent cascading failures by failing fast if a dependent service (e.g., Vault Cloud Sync) is unresponsive.
- **Consistency**: Map all technical `Exceptions` (Socket, Timeout, Host) to domain-specific `Failures` immediately at the Repository boundary.
- **Optimistic UI**: Use a **Cache-First** strategy; show the local Vault state immediately while background synchronization (Fetch/Push) happens silently.

## 1. Overview / Goal
The primary objective of this skill is to ensure every Flutter codebase meets **Production-Grade** standards. It mandates strict adherence to **Feature-Oriented Clean Architecture**, automated testing, and optimized rendering (Impeller). This protocol eliminates technical debt by enforcing separation of concerns, immutability, and modular scalability from day one.

## 2. Boundaries
*   **Logical Scope**: This skill governs Architecture, State Management, Performance, and CI/CD standards. It does not handle non-Flutter frontend tasks.
*   **Decision Authority**: Architecture Decision Records (ADRs) are mandatory for major structural changes. Do not implement core libraries without a documented ADR.
*   **Infrastructure**: Assumes a Unix-like environment with `flutter` SDK installed.

## 3. Decision Matrix (If/Then)

| Scenario | Requirement | Implementation Strategy |
| :--- | :--- | :--- |
| **Functional logic & Type safety** | **Use GetX + Records** | Leverage `GetxController` for reactive state and **Dart 3 Records** for multi-value returns. |
| **Dependency Injection** | **Interface-Based Registry** | All repositories MUST be registered with their interface type: `Get.lazyPut<IVaultRepository>(() => VaultRepositoryImpl(...), fenix: true);`. |
| **Error Handling** | **Result Pattern (Either)** | Use `Either<Failure, T>` from `dartz` for all domain/data operations. Define Failures: `SecurityFailure`, `AuthFailure`. |
| **New Feature** | **Feature-Oriented Clean Arch** | Scaffold features into `lib/src/features/[feature_name]/` with separate `domain`, `data`, and `presentation`. |
| **Large Data Set Display** | **Lazy Loading** | Must use `ListView.builder` or `Slivers`. Direct `Column` usage is strictly forbidden. |
| **State Updates** | **Reactive & Obx** | Wrap ONLY the smallest possible changing widget in `Obx` for high-density reactive UI. |
| **Desktop Navigation** | **Focus & Shortcuts** | MUST handle `FocusNode` and `ShortcutRegistry`. Mouse hover effects should be first-class citizens. |

## 4. Desktop & Rendering Optimization (Impeller)

*   **Keyboard & Mouse Focus**: Use `FocusScope.of(context).nextFocus()` and `CallbackShortcuts` for professional desktop UX. Handle `RawKeyboardListener` for low-level shortcut control.
*   **Impeller Specifics (Critical)**: 
    - **Avoid `BackdropFilter`** on large layers unless strictly necessary; it is expensive on Impeller.
    - **Avoid `SaveLayer`**: Excessive use of sub-layer clipping (`saveLayer`) impacts frame budget. Prefer `CustomPainter` with direct clipping bounds.
    - **Path Optimization**: Use simpler paths and avoid `addPolygon` with thousands of points; prefer `drawVertices` for complex geometry.
*   **Multi-Split Views**: Use `multi_split_view` for resizable sidebars and editors to maximize desktop productivity.

## 5. Sequential Workflow: Feature Implementation & Review

1.  **Architecture Alignment (ADR)**: Verify if the feature requires a new package. If yes, generate an `ADR.md`.
2.  **Domain Definition**: Define the `Entity` (models) and `IRepository` interface in `domain/`. No Flutter imports allowed here.
3.  **Data Layer Implementation**: Create `RepositoryImpl` and `DataSource` in `data/`. Map exceptions to `Failure` types.
4.  **State Logic Construction**:
    *   Create `Controller` in `presentation/`.
    *   Initialize dependencies via Feature `Binding` using `Get.lazyPut(..., fenix: true)`.
5.  **Presentation Construction**:
    *   Isolate rebuilds using **`Obx`**.
    *   Use `core/design_system` tokens (Squircle 14.0 radius, standard contrast).
    *   **Impeller Audit**: Run with `--enable-impeller` and check for jank in the shader compilation.
6.  **Performance Audit**: Check for excessive nesting or unnecessary widget rebuilds.
7.  **Verification**: Write Unit tests for repositories and controllers. Run `flutter test`.

## 6. Strict Guardrails (DO NOT)

*   **DO NOT** import `data/` layer inside a `presentation/` controller. Use interfaces.
*   **DO NOT** instantiate a Repository Implementation directly in a Controller. Use `Get.find<IRepository>()`.
*   **DO NOT** implement business logic or computation inside a `build()` method.
*   **DO NOT** call `setState()` — use GetX reactive state (`.obs`).
*   **DO NOT** bypass the DI layer; registration in `Bindings` is mandatory.
*   **DO NOT** use `print()`; use `debugPrint()` or a logging system.
*   **DO NOT** leave mutable variables in State; everything must be `final` or `Rx`.
