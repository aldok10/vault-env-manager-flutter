import 'package:vault_env_manager/src/features/workbench/domain/models/scout_node.dart';

class UiNode {
  final ScoutNode domainNode;
  bool isExpanded;
  List<String>? subKeys;
  Map<String, dynamic>? dataCache;

  UiNode(
    this.domainNode, {
    this.isExpanded = false,
    this.subKeys,
    this.dataCache,
  });

  String get name => domainNode.name;
  String get fullPath => domainNode.fullPath;
  bool get isFolder => domainNode.isFolder;
  int? get version => domainNode.version;
  String get environment => domainNode.environment;

  // Convenience helper to sync with domainNode's pre-populated data if any
  void syncFromDomain() {
    subKeys ??= domainNode.subKeys;
    dataCache ??= domainNode.dataCache;
  }
}
