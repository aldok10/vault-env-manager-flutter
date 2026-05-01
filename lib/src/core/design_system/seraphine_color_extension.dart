import 'package:flutter/material.dart';

/// 💎 SeraphineUI Color Extension
/// Handles reactive theme-dependent colors.
class SeraphineColorExtension extends ThemeExtension<SeraphineColorExtension> {
  final Color primary;
  final Color primaryGlow;
  final Color primaryGlowIntense;
  final Color accentGlow;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceHighlight;
  final Color surfaceLight;
  final Color surfaceLightIntense;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDetail;
  final Color divider;
  final Color border;
  final Color inputBg;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  // Syntax Highlighting
  final Color syntaxKeyword;
  final Color syntaxString;
  final Color syntaxNumber;
  final Color syntaxFunction;
  final Color syntaxComment;

  final Color glassBackground;
  final Color glassSurface;
  final Color glassBorder;
  final double glassBlur;
  final double glassOpacity;
  final double cardRadius;
  final String designStyle;

  const SeraphineColorExtension({
    required this.primary,
    required this.primaryGlow,
    required this.primaryGlowIntense,
    required this.accentGlow,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.surfaceLight,
    required this.surfaceLightIntense,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDetail,
    required this.divider,
    required this.border,
    required this.inputBg,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.syntaxKeyword,
    required this.syntaxString,
    required this.syntaxNumber,
    required this.syntaxFunction,
    required this.syntaxComment,
    required this.glassBackground,
    required this.glassSurface,
    required this.glassBorder,
    required this.glassBlur,
    required this.glassOpacity,
    required this.cardRadius,
    required this.designStyle,
  });

  @override
  ThemeExtension<SeraphineColorExtension> copyWith({
    Color? primary,
    Color? primaryGlow,
    Color? primaryGlowIntense,
    Color? accentGlow,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? surfaceHighlight,
    Color? surfaceLight,
    Color? surfaceLightIntense,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDetail,
    Color? divider,
    Color? border,
    Color? inputBg,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? syntaxKeyword,
    Color? syntaxString,
    Color? syntaxNumber,
    Color? syntaxFunction,
    Color? syntaxComment,
    Color? glassBackground,
    Color? glassSurface,
    Color? glassBorder,
    double? glassBlur,
    double? glassOpacity,
    double? cardRadius,
    String? designStyle,
  }) {
    return SeraphineColorExtension(
      primary: primary ?? this.primary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      primaryGlowIntense: primaryGlowIntense ?? this.primaryGlowIntense,
      accentGlow: accentGlow ?? this.accentGlow,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      surfaceLightIntense: surfaceLightIntense ?? this.surfaceLightIntense,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDetail: textDetail ?? this.textDetail,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      inputBg: inputBg ?? this.inputBg,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      syntaxKeyword: syntaxKeyword ?? this.syntaxKeyword,
      syntaxString: syntaxString ?? this.syntaxString,
      syntaxNumber: syntaxNumber ?? this.syntaxNumber,
      syntaxFunction: syntaxFunction ?? this.syntaxFunction,
      syntaxComment: syntaxComment ?? this.syntaxComment,
      glassBackground: glassBackground ?? this.glassBackground,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBlur: glassBlur ?? this.glassBlur,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      cardRadius: cardRadius ?? this.cardRadius,
      designStyle: designStyle ?? this.designStyle,
    );
  }

  @override
  SeraphineColorExtension lerp(
    covariant SeraphineColorExtension? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return SeraphineColorExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      primaryGlowIntense: Color.lerp(
        primaryGlowIntense,
        other.primaryGlowIntense,
        t,
      )!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHighlight: Color.lerp(
        surfaceHighlight,
        other.surfaceHighlight,
        t,
      )!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceLightIntense: Color.lerp(
        surfaceLightIntense,
        other.surfaceLightIntense,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDetail: Color.lerp(textDetail, other.textDetail, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      syntaxKeyword: Color.lerp(syntaxKeyword, other.syntaxKeyword, t)!,
      syntaxString: Color.lerp(syntaxString, other.syntaxString, t)!,
      syntaxNumber: Color.lerp(syntaxNumber, other.syntaxNumber, t)!,
      syntaxFunction: Color.lerp(syntaxFunction, other.syntaxFunction, t)!,
      syntaxComment: Color.lerp(syntaxComment, other.syntaxComment, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBlur: glassBlur + (other.glassBlur - glassBlur) * t,
      glassOpacity: glassOpacity + (other.glassOpacity - glassOpacity) * t,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      designStyle: t < 0.5 ? designStyle : other.designStyle,
    );
  }

  static const dark = SeraphineColorExtension(
    primary: Color(0xFF007AFF),
    primaryGlow: Color(0x33007AFF),
    primaryGlowIntense: Color(0x66007AFF),
    accentGlow: Color(0x3300E5FF),
    secondary: Color(0xFF6366F1),
    accent: Color(0xFF00E5FF),
    background: Color(0xFF000000),
    surface: Color(0xFF0C1117),
    surfaceHighlight: Color(0xFF161B22),
    surfaceLight: Color(0x0FFFFFFF),
    surfaceLightIntense: Color(0x1FFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xCCFFFFFF),
    textDetail: Color(0x80FFFFFF),
    divider: Color(0x14FFFFFF),
    border: Color(0x1FFFFFFF),
    inputBg: Color(0xFF0D1117),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    syntaxKeyword: Color(0xFF007AFF),
    syntaxString: Color(0xFF10B981),
    syntaxNumber: Color(0xFFF59E0B),
    syntaxFunction: Color(0xFF8B5CF6),
    syntaxComment: Color(0xFF555555),
    glassBackground: Color(0x26000000),
    glassSurface: Color(0x330C0C0D),
    glassBorder: Color(0x1FFFFFFF),
    glassBlur: 20.0,
    glassOpacity: 0.15,
    cardRadius: 14.0,
    designStyle: 'hyperos',
  );

  static const light = SeraphineColorExtension(
    primary: Color(0xFF007AFF),
    primaryGlow: Color(0x33007AFF),
    primaryGlowIntense: Color(0x66007AFF),
    accentGlow: Color(0x3300E5FF),
    secondary: Color(0xFF6366F1),
    accent: Color(0xFF00E5FF),
    background: Color(0xFFF6F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceHighlight: Color(0xFFEFF2F5),
    surfaceLight: Color(0x0D000000),
    surfaceLightIntense: Color(0x1A000000),
    textPrimary: Color(0xFF1F2328),
    textSecondary: Color(0xFF656D76),
    textDetail: Color(0xFF57606A),
    divider: Color(0xFFD0D7DE),
    border: Color(0xFFD0D7DE),
    inputBg: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    error: Color(0xFFCF222E),
    warning: Color(0xFF9A6700),
    info: Color(0xFF0969DA),
    syntaxKeyword: Color(0xFF0550AE),
    syntaxString: Color(0xFF116329),
    syntaxNumber: Color(0xFF9A6700),
    syntaxFunction: Color(0xFF8250DF),
    syntaxComment: Color(0xFF6E7781),
    glassBackground: Color(0xD9FFFFFF),
    glassSurface: Color(0x0D000000),
    glassBorder: Color(0x26000000),
    glassBlur: 20.0,
    glassOpacity: 0.1,
    cardRadius: 14.0,
    designStyle: 'hyperos',
  );
}
