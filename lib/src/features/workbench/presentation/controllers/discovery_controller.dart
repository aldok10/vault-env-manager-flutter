import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/features/workbench/domain/usecases/scout_vault_path.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/mixins/_discovery_filter.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/mixins/_discovery_status.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/models/ui_node.dart';

class DiscoveryController extends GetxController
    with DiscoveryStatus, DiscoveryFilter {
  final ScoutVaultPath _scoutVaultPath;
  late final AppConfigService _config;
  late final WorkbenchController _workbench;

  DiscoveryController(this._scoutVaultPath);

  // States moved to mixins:
  // - isScouting, statusText, statusColor (DiscoveryStatus)
  // - discoveredNodes, filteredNodes, searchQuery, collapsedPaths, searchController (DiscoveryFilter)

  // Compat for widgets using 'nodes'
  List<UiNode> get nodes => filteredNodes;

  // Selection State (Proxied from Workbench)
  String get selectedPath => _workbench.selectedEnvPath.value;
  String get selectedKey => _workbench.lastSelectedKey.value;

  @override
  void onInit() {
    super.onInit();
    _config = AppConfigService.to;
    _workbench = Get.find<WorkbenchController>();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
      applyFilter();
    });

    debounce(
      discoveredNodes,
      (_) => applyFilter(),
      time: const Duration(milliseconds: 200),
    );
    ever(collapsedPaths, (_) => applyFilter());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> handleScout() async {
    if (isScouting.value) return;

    if (_config.vaultToken.value.isEmpty) {
      updateStatus('Error: Vault Token Missing', SeraphineColors.primary);
      return;
    }

    discoveredNodes.clear();
    collapsedPaths.clear();
    isScouting.value = true;
    updateStatus('Initiating Scout Protocol...', SeraphineColors.primary);

    try {
      final rootPath = _config.vaultDiscoveryPath.value;

      final result = await _scoutVaultPath(
        rootPath,
        onNodeDiscovered: (node) {
          final uiNode = UiNode(node);
          uiNode.syncFromDomain();
          discoveredNodes.add(uiNode);
          updateStatus('Found: ${node.name}', SeraphineColors.primary);
        },
      );

      result.fold(
        (failure) {
          updateStatus(
            'Discovery Failed: ${failure.message}',
            SeraphineColors.primary,
          );
        },
        (nodes) {
          updateStatus(
            'Discovered ${nodes.length} Nodes!',
            SeraphineColors.primary,
          );
        },
      );
    } catch (e) {
      updateStatus('Protocol Error: ${e.toString()}', SeraphineColors.primary);
    } finally {
      isScouting.value = false;
      Future.delayed(const Duration(seconds: 3), () {
        if (!isScouting.value) {
          updateStatus('System Ready', SeraphineColors.textDetail);
        }
      });
    }
  }

  void handlePurge() {
    discoveredNodes.clear();
    collapsedPaths.clear();
    updateStatus('Metadata Purged', SeraphineColors.textDetail);
  }

  Future<void> selectNode(UiNode node) async {
    if (node.isFolder) {
      toggleFolder(node.fullPath);
      return;
    }

    if (node.subKeys != null && node.subKeys!.length > 1) {
      toggleFolder(node.fullPath);
      updateStatus(
        'Keys detected: ${node.subKeys!.length}',
        SeraphineColors.primary,
      );
      return;
    }

    updateStatus('Executing Sync: ${node.name}...', SeraphineColors.primary);

    final result = await _workbench.fetchVaultData(node.fullPath);

    await result.fold(
      (failure) async {
        updateStatus(
          'Fetch Failed: ${failure.message}',
          SeraphineColors.primary,
        );
      },
      (data) async {
        final keys = data.keys.toList();
        if (keys.length > 1) {
          node.subKeys = keys;
          node.dataCache = data;
          toggleFolder(node.fullPath);
          updateStatus('Multiple keys detected.', SeraphineColors.primary);
        } else {
          await _workbench.handleVaultSync(
            node.fullPath,
            displayName: node.name,
            specificKey: keys.isNotEmpty ? keys.first : null,
            version: node.version,
          );
          Get.back();
        }
      },
    );
  }

  Future<void> selectSubKey(UiNode parentNode, String keyName) async {
    await handleKeySelection(parentNode, keyName);
  }

  Future<void> handleKeySelection(UiNode parentNode, String keyName) async {
    updateStatus('Context: $keyName', SeraphineColors.primary);

    await _workbench.handleVaultSync(
      parentNode.fullPath,
      displayName: '${parentNode.name}/$keyName',
      specificKey: keyName,
      version: parentNode.version,
    );

    Get.back();
  }
}
