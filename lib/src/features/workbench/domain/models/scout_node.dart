import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/core/utils/json_validator_mixin.dart';

class ScoutNode with JsonValidatorMixin {
  final String name;
  final String fullPath;
  final DateTime lastDiscovered;
  final bool isFolder;
  final int? version;
  final List<String>? subKeys;
  final Map<String, dynamic>? dataCache;

  ScoutNode({
    required this.name,
    required this.fullPath,
    required this.lastDiscovered,
    this.isFolder = false,
    this.version,
    this.subKeys,
    this.dataCache,
  });

  factory ScoutNode.fromPath(
    String path, {
    bool isFolder = false,
    int? version,
  }) {
    final name = path.split('/').where((s) => s.isNotEmpty).last;
    return ScoutNode(
      name: name,
      fullPath: path,
      lastDiscovered: DateTime.now(),
      isFolder: isFolder,
      version: version,
    );
  }

  /// Secure factory that returns Either a Failure or a Validated ScoutNode.
  static Either<Failure, ScoutNode> fromMapSecure(Map<String, dynamic> map) {
    final validator = _ScoutNodeValidator();
    final result = validator.validate(map, ['name', 'fullPath']);

    return result.map(
      (validMap) => ScoutNode(
        name: validMap['name'],
        fullPath: validMap['fullPath'],
        lastDiscovered:
            DateTime.tryParse(validMap['lastDiscovered'] ?? '') ??
            DateTime.now(),
        isFolder: validMap['isFolder'] ?? false,
        version: validMap['version'],
        subKeys: (validMap['subKeys'] as List?)?.cast<String>(),
        dataCache: validMap['dataCache'],
      ),
    );
  }

  String get environment {
    final upper = fullPath.toUpperCase();
    if (upper.contains('PROD')) return 'PRODUCTION';
    if (upper.contains('STSeraphine')) return 'STSeraphineING';
    if (upper.contains('DEV')) return 'DEVELOPMENT';
    return '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoutNode &&
          runtimeType == other.runtimeType &&
          fullPath == other.fullPath;

  @override
  int get hashCode => fullPath.hashCode;
}

class _ScoutNodeValidator with JsonValidatorMixin {}
