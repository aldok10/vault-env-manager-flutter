import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_color_extension.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';

/// 💎 SeraphineUI Master Theme
/// Bridges tokens to Material 3 themes.
class SeraphineTheme {
  static ThemeData createTheme({
    required String colorTheme,
    required String osStyle,
    required bool isDark,
  }) {
    final palette = SeraphinePalette.fromId(colorTheme);
    final baseExtension =
        isDark ? SeraphineColorExtension.dark : SeraphineColorExtension.light;

    // Apply OS Style Overrides
    double glassBlur = 20.0;
    double glassOpacity = isDark ? 0.15 : 0.1;
    double cardRadius = 14.0;
    String designStyle = osStyle.toLowerCase();

    switch (designStyle) {
      case 'glass':
        glassBlur = 40.0;
        glassOpacity = isDark ? 0.1 : 0.05;
        cardRadius = 16.0;
        break;
      case 'flat':
        glassBlur = 0.0;
        glassOpacity = isDark ? 0.2 : 0.15;
        cardRadius = 8.0;
        break;
      case 'neumorphic':
        glassBlur = 5.0;
        glassOpacity = isDark ? 0.12 : 0.08;
        cardRadius = 24.0;
        break;
      case 'hyperos':
      default:
        designStyle = 'hyperos';
        glassBlur = 20.0;
        glassOpacity = isDark ? 0.15 : 0.1;
        cardRadius = 14.0;
        break;
    }

    final SeraphineColorExtension extension = baseExtension.copyWith(
      primary: palette.primary,
      secondary: palette.secondary,
      accent: palette.accent,
      glassBlur: glassBlur,
      glassOpacity: glassOpacity,
      cardRadius: cardRadius,
      designStyle: designStyle,
    ) as SeraphineColorExtension;

    final base = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: extension.background,
      primaryColor: extension.primary,
    );

    return base.copyWith(
      extensions: [extension],
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: extension.textPrimary,
        displayColor: extension.textPrimary,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: extension.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: extension.surface,
        onSurface: extension.textPrimary,
        primary: extension.primary,
        secondary: extension.secondary,
        error: extension.primary,
      ),
      dividerTheme: DividerThemeData(color: extension.divider, thickness: 1),
      cardTheme: CardThemeData(
        color: extension.surface,
        shape: SeraphineShapes.squircle(radius: cardRadius),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.inputBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: extension.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: extension.primary),
        ),
      ),
    );
  }

  // Deprecated: Use createTheme instead
  static ThemeData get dark =>
      createTheme(colorTheme: 'default', osStyle: 'hyperos', isDark: true);
  static ThemeData get light =>
      createTheme(colorTheme: 'default', osStyle: 'hyperos', isDark: false);
}
