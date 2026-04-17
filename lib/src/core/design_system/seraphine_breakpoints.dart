import 'package:flutter/material.dart';

/// 💎 SeraphineUI Breakpoints
/// Standardized for 2026 platform scales (Foldables, Ultrawides, Handhelds).
class SeraphineBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

extension SeraphineBreakpointX on BuildContext {
  bool get isMobile =>
      MediaQuery.sizeOf(this).width < SeraphineBreakpoints.mobile;
  bool get isTablet =>
      MediaQuery.sizeOf(this).width >= SeraphineBreakpoints.mobile &&
      MediaQuery.sizeOf(this).width < SeraphineBreakpoints.tablet;
  bool get isDesktop =>
      MediaQuery.sizeOf(this).width >= SeraphineBreakpoints.tablet;

  bool get isMini => MediaQuery.sizeOf(this).width < 400;
}
