import 'package:flutter/material.dart';

enum EnvVariant {
  prod(label: 'PROD', color: Colors.white, bg: Color(0xFFD32F2F)), // Red
  staging(
    label: 'STAGING',
    color: Colors.black,
    bg: Color(0xFFFFA000),
  ), // Amber
  dev(label: 'DEV', color: Colors.white, bg: Color(0xFF388E3C)), // Green
  test(label: 'TEST', color: Colors.white, bg: Color(0xFF1976D2)), // Blue
  local(label: 'LOCAL', color: Colors.white, bg: Color(0xFF616161)), // Grey
  unknown(label: 'ENV', color: Colors.white, bg: Color(0xFF607D8B)); // BlueGrey

  final String label;
  final Color color;
  final Color bg;

  const EnvVariant({
    required this.label,
    required this.color,
    required this.bg,
  });
}

class EnvClassifier {
  static EnvVariant classify(String? name) => switch (name?.toLowerCase()) {
    null || '' => EnvVariant.unknown,
    final String s when s.contains('prod') => EnvVariant.prod,
    final String s
        when s.contains('uat') || s.contains('stag') || s.contains('pre') =>
      EnvVariant.staging,
    final String s when s.contains('dev') => EnvVariant.dev,
    final String s when s.contains('test') || s.contains('qa') =>
      EnvVariant.test,
    final String s when s.contains('local') || s.contains('lab') =>
      EnvVariant.local,
    _ => EnvVariant.unknown,
  };
}
