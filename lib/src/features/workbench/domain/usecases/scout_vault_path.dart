import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/scout_node.dart';
import 'package:vault_env_manager/src/features/workbench/domain/services/vault_scout_service.dart';

class ScoutVaultPath {
  final VaultScoutService _scoutService;

  ScoutVaultPath(this._scoutService);

  Future<Either<VaultFailure, List<ScoutNode>>> call(
    String rootPath, {
    void Function(ScoutNode node)? onNodeDiscovered,
  }) async {
    final (result: result, nodesFound: _) = await _scoutService.scout(
      rootPath,
      onNodeDiscovered: onNodeDiscovered,
    );
    return result;
  }
}
