enum AuthStatus {
  initial, // First time setup required
  locked, // Password set but session locked
  unlocked, // Session active
  error, // Cryptographic error
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({required this.status, this.errorMessage});

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
