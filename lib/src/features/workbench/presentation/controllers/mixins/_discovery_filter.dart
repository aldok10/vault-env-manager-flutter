import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/models/ui_node.dart';

mixin DiscoveryFilter on GetxController {
  final discoveredNodes = <UiNode>[].obs;
  final filteredNodes = <UiNode>[].obs;
  final searchQuery = ''.obs;
  final collapsedPaths = <String>{}.obs;
  final searchController = TextEditingController();

  Future<void> applyFilter() async {
    final query = searchQuery.value.toLowerCase().trim();
    final nodes = List<UiNode>.from(discoveredNodes);
    final collapsed = Set<String>.from(collapsedPaths);

    // Offload to background isolate if list is large (> 100 nodes)
    if (nodes.length > 100) {
      final result = await compute(_filterTask, {
        'nodes': nodes,
        'query': query,
        'collapsed': collapsed,
      });
      filteredNodes.assignAll(result);
    } else {
      // Sync filtering for small lists
      filteredNodes.assignAll(
        _filterTask({'nodes': nodes, 'query': query, 'collapsed': collapsed}),
      );
    }
  }

  static List<UiNode> _filterTask(Map<String, dynamic> params) {
    final List<UiNode> nodes = params['nodes'];
    final String query = params['query'];
    final Set<String> collapsed = params['collapsed'];

    // Sort nodes before filtering if needed
    nodes.sort((a, b) => a.fullPath.compareTo(b.fullPath));

    if (query.isEmpty) {
      final visibleNodes = <UiNode>[];
      for (final node in nodes) {
        bool isParentCollapsed = false;
        for (final cPath in collapsed) {
          if (node.fullPath != cPath && node.fullPath.startsWith(cPath)) {
            isParentCollapsed = true;
            break;
          }
        }
        if (!isParentCollapsed) {
          visibleNodes.add(node);
        }
      }
      return visibleNodes;
    } else {
      return nodes
          .where(
            (node) =>
                node.name.toLowerCase().contains(query) ||
                node.fullPath.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  void toggleFolder(String path) {
    if (collapsedPaths.contains(path)) {
      collapsedPaths.remove(path);
    } else {
      collapsedPaths.add(path);
    }
  }

  void setSearchQuery(String query) {
    searchController.text = query;
    searchQuery.value = query;
    applyFilter();
  }

  void handleClearSearch() {
    searchController.clear();
    searchQuery.value = '';
    applyFilter();
  }
}
