import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_color_extension.dart';

/// 💎 SeraphineUI Color Palette
class SeraphinePalette {
  final Color primary;
  final Color secondary;
  final Color accent;

  const SeraphinePalette({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  static const defaultPalette = SeraphinePalette(
    primary: Color(0xFF007AFF),
    secondary: Color(0xFF6366F1),
    accent: Color(0xFF00E5FF),
  );

  static const cobalt = SeraphinePalette(
    primary: Color(0xFF3B82F6),
    secondary: Color(0xFF8B5CF6),
    accent: Color(0xFF06B6D4),
  );

  static const emerald = SeraphinePalette(
    primary: Color(0xFF10B981),
    secondary: Color(0xFF3B82F6),
    accent: Color(0xFF22D3EE),
  );

  static const rose = SeraphinePalette(
    primary: Color(0xFFF43F5E),
    secondary: Color(0xFFD946EF),
    accent: Color(0xFFFB7185),
  );

  static const amber = SeraphinePalette(
    primary: Color(0xFFF59E0B),
    secondary: Color(0xFFEF4444),
    accent: Color(0xFFFBBF24),
  );

  static SeraphinePalette fromId(String? id) {
    if (id == null) return defaultPalette;
    switch (id.toLowerCase()) {
      case 'default':
      case 'cobalt':
        return defaultPalette;
      case 'emerald':
        return emerald;
      case 'rose':
        return rose;
      case 'amber':
        return amber;
      default:
        return defaultPalette;
    }
  }
}

/// 💎 SeraphineUI Color Tokens
/// Optimized for "Weightless" UI with high spatial depth.
class SeraphineColors {
  static SeraphineColorExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<SeraphineColorExtension>();
    return extension ?? SeraphineColorExtension.dark;
  }

  // Core Brand (Reactive)
  static Color primaryColor(BuildContext context) => of(context).primary;
  static Color secondaryColor(BuildContext context) => of(context).secondary;
  static Color accentColor(BuildContext context) => of(context).accent;

  // Legacy Constants (DO NOT USE for new UI, use SeraphineColors.of(context).primary instead)
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryGlow = Color(0x33007AFF); // 20% Opacity
  static const Color primaryGlowIntense = Color(0x66007AFF); // 40% Opacity

  static const Color secondary = Color(0xFF6366F1); // Modern Indigo
  static const Color accent = Color(0xFF00E5FF); // Vibrant Cyan
  static const Color accentGlow = Color(0x3300E5FF); // 20% Opacity

  // Semantic Aliases for legacy compatibility
  static const Color accentPrimary = primary;
  static const Color accentSecondary = secondary;

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // --- Dark Mode (HyperOS Deep Space) ---
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0C0C0D); // Slightly deeper plate
  static const Color surfaceHighlight = Color(0xFF1A1A1C); // Floating Plate
  static const Color surfaceLight = Color(0x0FFFFFFF); // 6% Opacity White
  static const Color surfaceLightIntense = Color(
    0x1FFFFFFF,
  ); // 12% Opacity White

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xCCFFFFFF); // 80% Opacity
  static const Color textDetail = Color(0x80FFFFFF); // 50% Opacity

  static const Color divider = Color(0x14FFFFFF); // 8% Opacity
  static const Color border = Color(0x1FFFFFFF); // 12% Opacity
  static const Color inputBg = Color(0xFF121214);

  // --- HyperOS Plates (Modern Glass) ---
  static const Color glassBackground = Color(0x26000000); // 15% Opacity Black
  static const Color glassSurface = Color(
    0x330C0C0D,
  ); // 20% Opacity Dark Surface
  static const Color glassBorder = Color(0x1FFFFFFF); // Subtle Frosty Border
  static const double glassBlur = 32.0;

  // --- Shadows (Soft & Layered) ---
  static const Color shadowColor = Color(0x0D000000);
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 40, offset: Offset(0, 20)),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 80, offset: Offset(0, 40)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 40, offset: Offset(0, 20)),
  ];

  // --- 2026 Liquid Glass (Refractive) ---
  static const Color glassRefraction = Color(0x1A00D1FF);
  static const Color glassReflection = Color(0x4DFFFFFF);
  static const Color glassGlow = Color(0x0D3D7EFF);

  // Syntax Highlighting (Developer Context)
  static const Color syntaxKeyword = primary;
  static const Color syntaxString = success;
  static const Color syntaxNumber = warning;
  static const Color syntaxFunction = Color(0xFF8B5CF6);
  static const Color syntaxComment = Color(0xFF555555);

  // --- Semantic Aliases for Migration ---
  static const Color textPrimaryDark = Color(0xFF1E1E1E);
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0x1AFFFFFF);
  static const Color primaryLight = Color(0x333D7EFF);
}
