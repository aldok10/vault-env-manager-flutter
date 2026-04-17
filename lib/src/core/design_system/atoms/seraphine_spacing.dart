import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';

/// 📏 SeraphineUI Spacing & Layout Tokens
/// Unified spacing system based on a 4px grid.
class SeraphineSpacing {
  // --- Basic Units ---
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // --- Horizontal Spacers ---
  static const SizedBox xxsH = SizedBox(width: xxs);
  static const SizedBox xsH = SizedBox(width: xs);
  static const SizedBox smH = SizedBox(width: sm);
  static const SizedBox mdH = SizedBox(width: md);
  static const SizedBox lgH = SizedBox(width: lg);
  static const SizedBox xlH = SizedBox(width: xl);
  static const SizedBox xxlH = SizedBox(width: xxl);

  // --- Vertical Spacers ---
  static const SizedBox xxsV = SizedBox(height: xxs);
  static const SizedBox xsV = SizedBox(height: xs);
  static const SizedBox smV = SizedBox(height: sm);
  static const SizedBox mdV = SizedBox(height: md);
  static const SizedBox lgV = SizedBox(height: lg);
  static const SizedBox xlV = SizedBox(height: xl);
  static const SizedBox xxlV = SizedBox(height: xxl);
  static const SizedBox xxxlV = SizedBox(height: xxxl);

  // --- Edge Insets ---
  static const EdgeInsets pNone = EdgeInsets.zero;
  static const EdgeInsets pAllXXS = EdgeInsets.all(xxs);
  static const EdgeInsets pAllXS = EdgeInsets.all(xs);
  static const EdgeInsets pAllSM = EdgeInsets.all(sm);
  static const EdgeInsets pAllMD = EdgeInsets.all(md);
  static const EdgeInsets pAllLG = EdgeInsets.all(lg);
  static const EdgeInsets pAllXL = EdgeInsets.all(xl);

  static const EdgeInsets pHMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pVMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets pHLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pVLG = EdgeInsets.symmetric(vertical: lg);

  // --- Radius Helpers ---
  /// Global Squircle Radius (14.0)
  static BorderRadius get radius => SeraphineShapes.squircleRadius;

  /// Smaller items radius (8.0)
  static BorderRadius get radiusSM => BorderRadius.circular(xs);

  // --- Responsive Utils ---
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return pAllMD;
    if (width < 1200) return pAllLG;
    return pAllXL;
  }
}

/// Shorthand extension for responsive layout
extension SpacingExtension on BuildContext {
  EdgeInsets get responsivePadding => SeraphineSpacing.responsivePadding(this);
}
