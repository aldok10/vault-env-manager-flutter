import 'package:flutter/material.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// ⚛️ SeraphineText Atom
/// Utility for semantic typography within the SeraphineUI system.
class SeraphineText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const SeraphineText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  factory SeraphineText.h1(String text, {Color? color, TextAlign? textAlign}) =>
      SeraphineText(
        text,
        style: SeraphineTypography.h1,
        color: color,
        textAlign: textAlign,
      );

  factory SeraphineText.h2(String text, {Color? color, TextAlign? textAlign}) =>
      SeraphineText(
        text,
        style: SeraphineTypography.h2,
        color: color,
        textAlign: textAlign,
      );

  factory SeraphineText.h3(String text, {Color? color, TextAlign? textAlign}) =>
      SeraphineText(
        text,
        style: SeraphineTypography.h3,
        color: color,
        textAlign: textAlign,
      );

  factory SeraphineText.body(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) =>
      SeraphineText(
        text,
        style: SeraphineTypography.bodyMedium,
        color: color,
        textAlign: textAlign,
      );

  factory SeraphineText.label(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) =>
      SeraphineText(
        text,
        style: SeraphineTypography.label,
        color: color,
        textAlign: textAlign,
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? SeraphineTypography.bodyMedium).copyWith(color: color),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
