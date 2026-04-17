import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/repositories/i_vault_auth_repository.dart';

class VaultAuthRepositoryImpl implements IVaultAuthRepository {
  final http.Client _client;
  final AppConfigService _config;

  VaultAuthRepositoryImpl(this._client, this._config);

  @override
  Future<Either<VaultFailure, String>> loginWithToken(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${_config.vaultOrigin.value}/v1/auth/token/lookup-self'),
        headers: {'X-Vault-Token': token},
      );

      if (response.statusCode == 200) {
        return Right(token); // Valid token, just return it
      } else if (response.statusCode == 403) {
        return const Left(VaultAuthFailure('Invalid Vault Token'));
      } else {
        return Left(VaultFailure('Vault API Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(VaultNetworkFailure('Network Error: $e'));
    }
  }

  @override
  Future<Either<VaultFailure, String>> loginWithLdap({
    required String username,
    required String password,
    required String mountPath,
  }) async {
    try {
      final mount = mountPath.isEmpty ? 'ldap' : mountPath;
      final uri = Uri.parse(
        '${_config.vaultOrigin.value}/v1/auth/$mount/login/$username',
      );

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['auth']?['client_token'];

        if (token != null) {
          return Right(token);
        } else {
          return const Left(
            VaultAuthFailure('No token returned in auth response'),
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        final errorMsg = _extractErrorMessage(response.body);
        return Left(VaultAuthFailure('Authentication Failed: $errorMsg'));
      } else {
        return Left(VaultFailure('Vault API Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(VaultNetworkFailure('Network Error: $e'));
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = json.decode(body);
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        return data['errors'].join(', ');
      }
      return 'Unknown Error';
    } catch (_) {
      return 'Invalid Response Format';
    }
  }
}
