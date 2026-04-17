import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vault_env_manager/src/core/error/exceptions.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';

final class VaultService extends GetxService {
  /// Fetches environment keys from Vault.
  /// Returns `Either<Failure, List<String>>`.
  Future<Either<Failure, List<String>>> getEnvKeys(
    String origin,
    String token,
    String scrapingUrl,
  ) async {
    try {
      final client = Get.find<http.Client>();
      final uri = Uri.parse(origin + scrapingUrl);

      final response = await client
          .get(uri, headers: {'X-Vault-Token': token})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('data')) {
          final vaultData = data['data'];
          if (vaultData is Map && vaultData.containsKey('keys')) {
            final keys = vaultData['keys'];
            if (keys is List) {
              return Right(keys.cast<String>());
            }
          }
        }
        return const Left(ParseFailure('Unexpected Vault response format.'));
      } else {
        return Left(
          ServerFailure(
            'Vault Error (${response.statusCode}): ${response.reasonPhrase}',
          ),
        );
      }
    } on SecurityException catch (e) {
      return Left(VaultSecurityFailure(e.message));
    } on http.ClientException catch (e) {
      return Left(NetworkFailure('Connection failed: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
