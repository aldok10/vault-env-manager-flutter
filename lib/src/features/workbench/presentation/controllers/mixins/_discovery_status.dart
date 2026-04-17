import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';

mixin DiscoveryStatus on GetxController {
  final isScouting = false.obs;
  final statusText = 'System Ready'.obs;
  final statusColor = SeraphineColors.textDetail.obs;

  void updateStatus(String text, Color color) {
    statusText.value = text;
    statusColor.value = color;
  }
}
