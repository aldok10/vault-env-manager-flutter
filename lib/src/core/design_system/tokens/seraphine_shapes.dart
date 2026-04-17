import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// 💎 SeraphineUI Shape Tokens
/// Enforcing 14.0 Squircle radius as per project guidelines.
class SeraphineShapes {
  static const double baseRadius = 14.0;
  static const double smooth = 0.8; // HyperOS "Alive" super-ellipse smoothness

  static SmoothRectangleBorder squircle({
    BorderSide side = BorderSide.none,
    double radius = baseRadius,
  }) => SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius(
      cornerRadius: radius,
      cornerSmoothing: smooth,
    ),
    side: side,
  );

  static SmoothBorderRadius get borderRadius =>
      SmoothBorderRadius(cornerRadius: baseRadius, cornerSmoothing: smooth);

  static SmoothBorderRadius get borderRadiusLG =>
      SmoothBorderRadius(cornerRadius: 16.0, cornerSmoothing: smooth);

  static SmoothBorderRadius get borderRadiusSM =>
      SmoothBorderRadius(cornerRadius: 8.0, cornerSmoothing: smooth);

  static BorderRadius get squircleRadius =>
      SmoothBorderRadius(cornerRadius: baseRadius, cornerSmoothing: smooth);
}
