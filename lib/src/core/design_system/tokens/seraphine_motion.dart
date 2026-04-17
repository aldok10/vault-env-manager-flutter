import 'package:flutter/animation.dart';

/// 💎 SeraphineUI Motion Tokens
/// Focused on smooth, weightless transitions.
class SeraphineMotion {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// Default animation duration
  static const Duration standard = medium;

  // Curves (Smoother than standard ease)
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve emphasize = Curves.easeInOutQuart;

  // --- 2026 Biological Motion ---
  static const Curve gravity = Curves.easeOutBack;
  static const Curve friction = Curves.decelerate;
  static const Curve snap = Curves.easeOutExpo;

  /// Project Standard Curve
  static const Curve standardCurve = smooth;

  // Animation Staggers
  static const Duration stagger = Duration(milliseconds: 100);
}
