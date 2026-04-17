import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';

enum LogLevel {
  info,
  success,
  warning,
  error;

  String get icon {
    return switch (this) {
      LogLevel.info => 'ℹ',
      LogLevel.success => '✓',
      LogLevel.warning => '⚠',
      LogLevel.error => '✕',
    };
  }

  Color color(BuildContext context) {
    final colors = SeraphineColors.of(context);
    switch (this) {
      case LogLevel.info:
        return colors.textSecondary;
      case LogLevel.success:
        return colors.success;
      case LogLevel.warning:
        return colors.warning;
      case LogLevel.error:
        return colors.error;
    }
  }
}

class SystemLog {
  final String message;
  final DateTime timestamp;
  final LogLevel level;

  SystemLog({
    required this.message,
    DateTime? timestamp,
    this.level = LogLevel.info,
  }) : timestamp = timestamp ?? DateTime.now();

  String get timeFormatted {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
