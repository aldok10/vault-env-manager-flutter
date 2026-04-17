import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/error/exceptions.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/core/services/compute_service.dart';

import '../../domain/repositories/i_vault_repository.dart';

class VaultRepositoryImpl implements IVaultRepository {
  final http.Client _client;
  final AppConfigService _config;

  VaultRepositoryImpl(this._client, this._config);

  @override
  Future<Either<VaultFailure, List<String>>> listKeys(String path) async {
    try {
      final url = _buildVaultUrl(
        _config.scrapingUrl.value,
        'metadata',
        path,
        queryParams: {'list': 'true'},
      );
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = await ComputeService.to.parseJson(response.body);
        final List<dynamic> keys = data['data']['keys'] ?? [];
        return Right(keys.map((e) => e.toString()).toList());
      }
      return _handleFailure(response.statusCode);
    } on SecurityException catch (e) {
      return Left(VaultSecurityFailure(e.message));
    } catch (e) {
      return Left(VaultNetworkFailure('Connection failed: $e'));
    }
  }

  Future<Either<VaultFailure, ({Map<String, dynamic> data, int? version})>>
  getMetadataAndData(String path) async {
    try {
      final url = _buildVaultUrl(_config.scrapingUrl.value, 'data', path);
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final dataMap = await ComputeService.to.parseJson(response.body);
        final payload = dataMap['data']['data'] as Map<String, dynamic>?;
        if (payload == null) {
          return const Left(VaultPathFailure('Malformed secret structure.'));
        }

        final metadata = dataMap['data']['metadata'] as Map<String, dynamic>?;
        return Right((data: payload, version: metadata?['version'] as int?));
      }
      return _handleFailure(response.statusCode, msg: 'Secret fetch failed');
    } on SecurityException catch (e) {
      return Left(VaultSecurityFailure(e.message));
    } catch (e) {
      return Left(VaultNetworkFailure('Secret fetch failed: $e'));
    }
  }

  @override
  Future<Either<VaultFailure, Map<String, dynamic>>> getSecret(
    String path, {
    int? version,
  }) async {
    try {
      final url = _buildVaultUrl(
        _config.scrapingUrl.value,
        'data',
        path,
        queryParams: version != null ? {'version': version.toString()} : null,
      );
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = await ComputeService.to.parseJson(response.body);
        return Right(data['data']['data'] as Map<String, dynamic>);
      }
      return _handleFailure(response.statusCode);
    } on SecurityException catch (e) {
      return Left(VaultSecurityFailure(e.message));
    } catch (e) {
      return Left(VaultNetworkFailure('Secret retrieval failed: $e'));
    }
  }

  @override
  Future<Either<VaultFailure, Map<String, dynamic>>> getMetadata(
    String path,
  ) async {
    try {
      final url = _buildVaultUrl(_config.scrapingUrl.value, 'metadata', path);
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = await ComputeService.to.parseJson(response.body);
        return Right(data['data'] as Map<String, dynamic>);
      }
      return _handleFailure(response.statusCode);
    } on SecurityException catch (e) {
      return Left(VaultSecurityFailure(e.message));
    } catch (e) {
      return Left(VaultNetworkFailure('Metadata retrieval failed: $e'));
    }
  }

  @override
  Future<Either<VaultFailure, void>> putSecret(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = _buildVaultUrl(_config.scrapingUrl.value, 'data', path);
      final response = await _client.post(
        url,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: json.encode({'data': data}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      }
      return _handleFailure(response.statusCode);
    } on SecurityException catch (e) {
      return Left(VaultSecurityFailure(e.message));
    } catch (e) {
      return Left(VaultNetworkFailure('Secret write failed: $e'));
    }
  }

  Map<String, String> get _headers => {
    'X-Vault-Token': _config.vaultToken.value,
    'Accept': 'application/json',
    if (_config.vaultNamespace.value.isNotEmpty)
      'X-Vault-Namespace': _config.vaultNamespace.value,
  };

  Either<VaultFailure, T> _handleFailure<T>(int statusCode, {String? msg}) {
    if (statusCode == 403 || statusCode == 401) {
      return const Left(VaultAuthFailure('Unauthorized or expired session.'));
    } else if (statusCode == 404) {
      return const Left(VaultPathFailure('Resource not found.'));
    }
    return Left(VaultNetworkFailure(msg ?? 'Vault error: $statusCode'));
  }

  Uri _buildVaultUrl(
    String rawMount,
    String segment,
    String rawPath, {
    Map<String, String>? queryParams,
  }) {
    final origin = _config.vaultOrigin.value.replaceAll(RegExp(r'/+$'), '');
    final mount = rawMount
        .replaceAll(RegExp(r'^/+|/+$'), '')
        .replaceFirst('v1/', '')
        .replaceFirst('metadata', '')
        .replaceFirst('data', '')
        .replaceAll(RegExp(r'^/+|/+$'), '');

    final path = _normalizePath(rawPath).replaceAll(RegExp(r'^/+|/+$'), '');
    final finalPath = path.isEmpty
        ? 'v1/$mount/$segment/'
        : 'v1/$mount/$segment/$path${rawPath.endsWith('/') ? '/' : ''}';

    final uri = Uri.parse(origin);
    return uri.replace(
      path: '${uri.path}/$finalPath'.replaceAll(RegExp(r'/+'), '/'),
      queryParameters: queryParams,
    );
  }

  String _normalizePath(String path) {
    if (path.contains('../') || path.contains('./')) {
      throw const FormatException('Blocked.');
    }
    return path.replaceAll(RegExp(r'/+'), '/');
  }
}
