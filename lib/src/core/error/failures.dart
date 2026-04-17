import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error']);
}

final class SecurityFailure extends Failure {
  const SecurityFailure([super.message = 'Security Protocol Error']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage Access Error']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid Master Password']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network Connection Error']);
}

final class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Data Parsing Error']);
}

final class VaultFailure extends Failure {
  const VaultFailure([super.message = 'Vault Protocol Error']);
}

final class VaultAuthFailure extends VaultFailure {
  const VaultAuthFailure([
    super.message = 'Vault Authentication Failed (Invalid Token)',
  ]);
}

final class VaultPathFailure extends VaultFailure {
  const VaultPathFailure([
    super.message = 'Vault Path Not Found or Access Denied',
  ]);
}

final class VaultNetworkFailure extends VaultFailure {
  const VaultNetworkFailure([
    super.message = 'Vault Network Connectivity Issue',
  ]);
}

final class VaultSecurityFailure extends VaultFailure {
  const VaultSecurityFailure([
    super.message = 'Vault Security Violation Detected',
  ]);
}
