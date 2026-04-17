import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// A centralized service for Isolates management.
///
/// Offloads heavy processing (JSON parsing, encryption, large data mapping)
/// to separate Isolates to maintain 60/120 FPS on the main UI thread.
class ComputeService extends GetxService {
  static ComputeService get to => Get.find();

  Future<ComputeService> init() async {
    return this;
  }

  /// Parse a JSON string into a Map in a separate Isolate.
  Future<Map<String, dynamic>> parseJson(String jsonString) async {
    return await compute(_decodeJson, jsonString);
  }

  /// Parse a large JSON string into a List in a separate Isolate.
  Future<List<dynamic>> parseJsonList(String jsonString) async {
    return await compute(_decodeJsonList, jsonString);
  }

  /// Static helper for compute (must be top-level or static)
  static Map<String, dynamic> _decodeJson(String source) {
    return json.decode(source) as Map<String, dynamic>;
  }

  static List<dynamic> _decodeJsonList(String source) {
    return json.decode(source) as List<dynamic>;
  }

  /// Convert an object to a JSON string in a separate Isolate.
  Future<String> stringifyJson(dynamic data) async {
    return await compute(_encodeJson, data);
  }

  static String _encodeJson(dynamic source) {
    return json.encode(source);
  }

  /// Map dynamic list to a specific type using a mapper function in an Isolate.
  ///
  /// Note: [mapper] must be a top-level or static function.
  Future<List<T>> mapList<T, S>(List<S> items, T Function(S) mapper) async {
    return await compute(_mapInternal<T, S>, _MapArgs(items, mapper));
  }

  static List<T> _mapInternal<T, S>(_MapArgs<T, S> args) {
    return args.items.map(args.mapper).toList();
  }
}

class _MapArgs<T, S> {
  final List<S> items;
  final T Function(S) mapper;
  _MapArgs(this.items, this.mapper);
}
