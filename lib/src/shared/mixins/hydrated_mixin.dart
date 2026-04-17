import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/app/data/services/storage_service.dart';

/// A mixin that provides automatic state persistence for GetxControllers.
///
/// To use it, simply add the mixin to your controller and implement [toJson]
/// and [fromJson]. The state will be automatically loaded on initialization
/// and saved whenever [updateHydrated] is called.
mixin HydratedMixin on GetLifeCycleBase {
  /// Unique key for storage. Defaults to the controller's runtime type name.
  String get storageKey => runtimeType.toString();

  /// The [StorageService] instance used for persistence.
  StorageService get _storage => Get.find<StorageService>();

  /// Whether the state has been successfully loaded from storage.
  final RxBool _isLoaded = false.obs;
  bool get isHydrated => _isLoaded.value;

  @override
  @mustCallSuper
  void onInit() {
    super.onInit();
    unawaited(_loadState());
  }

  /// Loads the persisted state from storage.
  Future<void> _loadState() async {
    try {
      final jsonData = await _storage.get(storageKey, isSecure: false);
      if (jsonData != null) {
        final Map<String, dynamic> data = jsonDecode(jsonData);
        fromJson(data);
        debugPrint('HydratedMixin: State restored for $storageKey');
      }
    } catch (e) {
      debugPrint('HydratedMixin: Failed to restore state for $storageKey: $e');
    } finally {
      _isLoaded.value = true;
    }
  }

  /// Saves the current state to storage.
  /// This should be called whenever the state changes.
  Future<void> updateHydrated() async {
    if (!_isLoaded.value) return; // Prevent overwriting during initial load

    try {
      final data = toJson();
      final jsonData = jsonEncode(data);
      await _storage.saveNormal(storageKey, jsonData);
    } catch (e) {
      debugPrint('HydratedMixin: Failed to save state for $storageKey: $e');
    }
  }

  /// Clears the persisted state for this controller.
  Future<void> clearHydrated() async {
    await _storage.delete(storageKey, isSecure: false);
  }

  /// Converts the current state to a JSON-encodable Map.
  Map<String, dynamic> toJson();

  /// Restores the state from a JSON Map.
  void fromJson(Map<String, dynamic> json);
}
