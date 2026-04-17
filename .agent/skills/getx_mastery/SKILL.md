---
name: GetX Mastery for Flutter
description: Professional-grade GetX patterns for state management, dependency injection, and asynchronous service initialization in enterprise Flutter apps.
---

# 🚀 GetX Mastery: Enterprise Patterns

This skill provides comprehensive guidance on building scalable, reactive, and robust Flutter applications using the **GetX** ecosystem.

## 🏗️ 1. Asynchronous Service Initialization

Enterprise apps often require services (e.g., `StorageService`, `DatabaseService`, `AppConfigService`) to be initialized before the UI is rendered.

### The `initServices()` Pattern
Register critical services in `main()` using `Get.putAsync`.

```dart
Future<void> initServices() async {
  debugPrint('Starting services...');
  
  // 1. Storage (Persistent service)
  await Get.putAsync<IStorageService>(() async => await StorageService().init());
  
  // 2. Core Configuration (Persistent service)
  await Get.putAsync<IAppConfigService>(() async => await AppConfigService().init());

  debugPrint('All services started');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services before runApp()
  await initServices();

  runApp(const MyApp());
}
```

### `GetxService` for Persistence
Use `GetxService` instead of `GetxController` for long-lived components that must **persist across route changes** and never be automatically disposed.

```dart
class AppConfigService extends GetxService implements IAppConfigService {
  final isReady = false.obs;

  Future<AppConfigService> init() async {
    // 1. Perform initialization logic
    await registerStorage();
    await loadEnv();
    
    // 2. Mark as ready
    isReady.value = true;
    return this;
  }
}
```

### Dependency Precedence
When initializing via `Get.putAsync`, ensure dependencies are loaded in the correct order to avoid `DependencyNotRegistered` errors.
1. **Low-Level Platform Plugins**: `SharedPreferences`, `SecureStorage`.
2. **Infrastructure Services**: `HttpService`, `AuthService`.
3. **Core Application Services**: `AppConfigService`, `StateNavigator`.

---

## 💉 2. Reactive Dependency Injection (DI)

Control the lifecycle of your dependencies with precision, always using interfaces.

- **`Get.lazyPut<IType>(() => Implementation(), fenix: true)`**: Mandatory for feature-level controllers and use cases. `fenix: true` ensures that if the dependency is disposed (e.g., on route exit), it can be re-instantiated when needed again.
- **`Get.find<IType>()`**: Always resolve by interface type to maximize testability.

### Feature Bindings
Decouple dependency registration from the UI view.

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IHomeRepository>(() => HomeRepositoryImpl(), fenix: true);
    Get.lazyPut(() => HomeController(Get.find()), fenix: true);
  }
}
```

---

## ⚡ 3. Reactive State Management & Obx Scoping

### The "Smallest Rebuild" Rule
Wrap only the specific widget that needs to rebuild when the state changes. This is critical for high-performance UIs on Desktop.

```dart
// ❌ BAD: Rebuilds the entire Scaffold
Obx(() => Scaffold(
  body: Text(controller.count.value.toString()),
))

// ✅ GOOD: Rebuilds only the Text widget
Scaffold(
  body: Center(
    child: Obx(() => Text(controller.count.value.toString())),
  ),
)
```

### Workers (Side-Effects)
Use Workers in your `onInit` for automatic reactions to state changes.
- `ever(obs, (_) => ...)`: Called every time the state changes.
- `once(obs, (_) => ...)`: Called only the first time the state changes.
- `debounce(obs, (_) => ..., time: 500.ms)`: Called when the user stops typing for 500ms.

---

## 🎨 4. Reactive Theme Management

Tie `GetMaterialApp` directly to the `AppConfigService` observables.

```dart
GetMaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: Get.find<IAppConfigService>().themeMode.value,
  // ...
)
```

---

## 🧪 5. Testing GetX Components

Use **Mocktail** to mock dependencies and `Get.put` to inject them into the test environment.

```dart
setUp(() {
  final mockRepo = MockHomeRepository();
  Get.put<IHomeRepository>(mockRepo); // Inject mock
  controller = HomeController(Get.find());
});

tearDown(() => Get.reset());
```

---
*Reference: jonataslaw/getx Documentation & Senior Architect Patterns*
