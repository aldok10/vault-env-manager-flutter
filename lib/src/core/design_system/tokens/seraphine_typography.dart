import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 💎 SeraphineUI Typography Tokens
/// Modern, legible, and spatial.
class SeraphineTypography {
  // Primary (Modern Tech Sans)
  static TextStyle get primaryFont => GoogleFonts.plusJakartaSans();

  // Mono (Developer Optimized)
  static TextStyle get monoFont => GoogleFonts.jetBrainsMono();

  static TextStyle get h1 => primaryFont.copyWith(
    fontSize: 42,
    fontWeight: FontWeight.w900, // Extreme bold (Samsung-ish)
    letterSpacing: -2.0,
  );

  static TextStyle get h2 => primaryFont.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
  );

  static TextStyle get h3 => primaryFont.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  static TextStyle get h4 =>
      primaryFont.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge => primaryFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static TextStyle get bodyMedium =>
      primaryFont.copyWith(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get bodySmall =>
      primaryFont.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get label => primaryFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static TextStyle get caption =>
      primaryFont.copyWith(fontSize: 11, fontWeight: FontWeight.w500);

  static TextStyle get code =>
      monoFont.copyWith(fontSize: 13, fontWeight: FontWeight.w500, height: 1.5);

  // --- Semantic Aliases for Migration ---
  static TextStyle get console => code;
  static TextStyle get boldTracking => label;
  static TextStyle get bodyBold =>
      bodyMedium.copyWith(fontWeight: FontWeight.w700);
}
