import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ValenceTypography {
  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle bodyLarge;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle overline;
  final TextStyle numbersDisplay;
  final TextStyle numbersBody;

  const ValenceTypography({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.bodyLarge,
    required this.body,
    required this.caption,
    required this.overline,
    required this.numbersDisplay,
    required this.numbersBody,
  });

  factory ValenceTypography.fromColor(Color color) {
    final bodyBase = GoogleFonts.plusJakartaSans(color: color);

    return ValenceTypography(
      display: TextStyle(
        fontFamily: 'Obviously',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.0,
        color: color,
      ),
      h1: TextStyle(
        fontFamily: 'Obviously',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      ),
      h2: TextStyle(
        fontFamily: 'Obviously',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.25,
        color: color,
      ),
      h3: TextStyle(
        fontFamily: 'Obviously',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.1,
        color: color,
      ),
      bodyLarge: bodyBase.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.0,
      ),
      body: bodyBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.0,
      ),
      caption: bodyBase.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      overline: bodyBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 1.2,
      ),
      numbersDisplay: TextStyle(
        fontFamily: 'Obviously',
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
        color: color,
      ),
      numbersBody: TextStyle(
        fontFamily: 'Obviously',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.0,
        color: color,
      ),
    );
  }

  ValenceTypography lerp(ValenceTypography other, double t) {
    return ValenceTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
      numbersDisplay: TextStyle.lerp(numbersDisplay, other.numbersDisplay, t)!,
      numbersBody: TextStyle.lerp(numbersBody, other.numbersBody, t)!,
    );
  }
}
