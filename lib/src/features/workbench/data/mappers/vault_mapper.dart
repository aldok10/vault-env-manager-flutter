import 'package:vault_env_manager/src/features/workbench/domain/entities/vault_secret.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/scout_node.dart';

class VaultMapper {
  /// Maps a raw Vault secret response into a VaultSecret entity.
  static VaultSecret toEntity(String fullPath, Map<String, dynamic> data) {
    final name = fullPath.split('/').where((s) => s.isNotEmpty).last;
    return VaultSecret(name: name, fullPath: fullPath, data: data);
  }

  /// Maps a metadata/data record into a ScoutNode entity.
  static ScoutNode toNode(
    String fullPath, {
    bool isFolder = false,
    int? version,
    List<String>? subKeys,
    Map<String, dynamic>? dataCache,
  }) {
    final name = fullPath.split('/').where((s) => s.isNotEmpty).last;
    return ScoutNode(
      name: name,
      fullPath: fullPath,
      lastDiscovered: DateTime.now(),
      isFolder: isFolder,
      version: version,
      subKeys: subKeys,
      dataCache: dataCache,
    );
  }
}
