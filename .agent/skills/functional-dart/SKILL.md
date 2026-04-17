---
name: functional-dart
description: Functional programming patterns (Either, Option) and value equality for enterprise Dart/Flutter applications.
---

# 🧩 Functional Dart & Logic

This skill defines the patterns for type-safe error handling and data integrity using the Result Pattern and value equality.

## ⚖️ 1. Value Equality (`equatable`)

Use `package:equatable` to ensure that Two objects with the same properties are considered equal. This is critical for preventing unnecessary UI rebuilds in GetX and for unit testing.

### ✅ Entity Implementation
```dart
class User extends Equatable {
  final String id;
  final String email;

  const User({required this.id, required this.email});

  @override
  List<Object?> get props => [id, email];
}
```

---

## 🏗️ 2. Result Pattern (`dartz`)

Mandatory for all `Repository` and `UseCase` methods to ensure that errors are handled as **values**, not exceptions.

### ✅ The `Either<Failure, T>` Pattern
- `Left`: Contains a `Failure` object (Logic/Business error).
- `Right`: Contains the successful `Result`.

```dart
Future<Either<Failure, String>> encrypt(String data) async {
  try {
    final result = await _crypto.encrypt(data);
    return Right(result);
  } catch (e) {
    return Left(SecurityFailure('Encryption failed: $e'));
  }
}
```

### ✅ Consumption (Fold)
```dart
final result = await useCase.execute();

result.fold(
  (failure) => _handleError(failure),
  (data) => _handleSuccess(data),
);
```
### Async Operations (TaskEither)
For complex, multi-step async operations, use `TaskEither` to compose logic without nested try/catch.

```dart
TaskEither<Failure, User> getUser() => 
  TaskEither.tryCatch(
    () => api.fetchUser(),
    (e, s) => ServerFailure(message: e.toString()),
  );
```

## 🎯 3. Logical Guardrails

- **Avoid `null`**: Use `Option<T>` instead of nullable types when a value might be missing.
- **Side Effects**: Encapsulate all side effects (I/O, Network) in `TaskEither` or `Future<Either>`.
- **Pure Domain**: The Domain layer MUST use these functional types to remain pure and testable.

---
*Reference: dartz and equatable Documentation*
