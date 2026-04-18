import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/scout_node.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_vault_repository.dart';

class VaultScoutService {
  final IVaultRepository _repository;

  VaultScoutService(this._repository);

  Future<({Either<VaultFailure, List<ScoutNode>> result, int nodesFound})>
      scout(
    String rootPath, {
    void Function(ScoutNode node)? onNodeDiscovered,
  }) async {
    // 🛡️ Security Guard: Prevent path traversal and absolute path leaks
    if (rootPath.contains('..') || rootPath.startsWith('/')) {
      return (
        result: const Left<VaultFailure, List<ScoutNode>>(
          VaultSecurityFailure('MALICIOUS_PATH_DETECTED'),
        ),
        nodesFound: 0,
      );
    }

    try {
      final List<ScoutNode> results = [];
      final String normalizedRoot =
          rootPath.endsWith('/') ? rootPath : '$rootPath/';

      await _recursiveCrawl(
        normalizedRoot,
        results,
        onNodeDiscovered: onNodeDiscovered,
      );

      return (
        result: Right<VaultFailure, List<ScoutNode>>(results),
        nodesFound: results.length,
      );
    } catch (e) {
      return (
        result: Left<VaultFailure, List<ScoutNode>>(
          VaultNetworkFailure('Discovery failed: $e'),
        ),
        nodesFound: 0,
      );
    }
  }

  /// Recursively crawls the vault structure.
  /// Returns a Record indicating if secrets were found in this branch and the count.
  Future<({bool hasSecrets, int count})> _recursiveCrawl(
    String path,
    List<ScoutNode> results, {
    void Function(ScoutNode node)? onNodeDiscovered,
  }) async {
    final response = await _repository.listKeys(path);
    bool branchHasSecrets = false;
    int branchCount = 0;

    await response.fold(
      (failure) async {
        // Log & Skip: Maintain robust discovery even if sub-paths are restricted
        debugPrint('Skipping path $path: ${failure.message}');
      },
      (keys) async {
        final sortedKeys = List<String>.from(keys)..sort();

        // 🚀 High-Performance Discovery: Parallelize sibling entry checks
        final tasks = sortedKeys.map((key) async {
          final fullPath = '$path$key';

          if (key.endsWith('/')) {
            // Recurse into directory
            final subResult = await _recursiveCrawl(
              fullPath,
              results,
              onNodeDiscovered: onNodeDiscovered,
            );

            if (subResult.hasSecrets) {
              final folderNode = ScoutNode.fromPath(fullPath, isFolder: true);
              results.add(folderNode);
              onNodeDiscovered?.call(folderNode);
              return (hasSecrets: true, count: subResult.count);
            }
          } else {
            // Process secret leaf
            final metaResult = await _repository.getMetadata(fullPath);
            return metaResult.fold((_) => (hasSecrets: false, count: 0), (
              meta,
            ) {
              final node = ScoutNode.fromPath(
                fullPath,
                version: meta['current_version'] as int?,
              );
              results.add(node);
              onNodeDiscovered?.call(node);
              return (hasSecrets: true, count: 1);
            });
          }
          return (hasSecrets: false, count: 0);
        });

        final taskResults = await Future.wait(tasks);
        for (final res in taskResults) {
          if (res.hasSecrets) {
            branchHasSecrets = true;
            branchCount += res.count;
          }
        }
      },
    );

    return (hasSecrets: branchHasSecrets, count: branchCount);
  }
}
