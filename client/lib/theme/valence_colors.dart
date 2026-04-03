import 'package:flutter/material.dart';

class ValenceColors {
  final Color surfaceBackground;
  final Color surfacePrimary;
  final Color surfaceElevated;
  final Color surfaceSunken;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color accentSuccess;
  final Color accentWarning;
  final Color accentError;
  final Color accentSocial;
  final Color textPrimary;
  final Color textSecondary;
  final Color textInverse;
  final Color textLink;
  final Color borderDefault;
  final Color borderFocus;
  final Color chainGold;
  final Color chainSilver;
  final Color chainBroken;
  final Color rankBronze;
  final Color rankSilver;
  final Color rankGold;
  final Color rankPlatinum;
  final Color rankDiamond;

  const ValenceColors({
    required this.surfaceBackground, required this.surfacePrimary,
    required this.surfaceElevated, required this.surfaceSunken,
    required this.accentPrimary, required this.accentSecondary,
    required this.accentSuccess, required this.accentWarning,
    required this.accentError, required this.accentSocial,
    required this.textPrimary, required this.textSecondary,
    required this.textInverse, required this.textLink,
    required this.borderDefault, required this.borderFocus,
    required this.chainGold, required this.chainSilver, required this.chainBroken,
    required this.rankBronze, required this.rankSilver, required this.rankGold,
    required this.rankPlatinum, required this.rankDiamond,
  });

  ValenceColors lerp(ValenceColors other, double t) {
    return ValenceColors(
      surfaceBackground: Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentSuccess: Color.lerp(accentSuccess, other.accentSuccess, t)!,
      accentWarning: Color.lerp(accentWarning, other.accentWarning, t)!,
      accentError: Color.lerp(accentError, other.accentError, t)!,
      accentSocial: Color.lerp(accentSocial, other.accentSocial, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      chainGold: Color.lerp(chainGold, other.chainGold, t)!,
      chainSilver: Color.lerp(chainSilver, other.chainSilver, t)!,
      chainBroken: Color.lerp(chainBroken, other.chainBroken, t)!,
      rankBronze: Color.lerp(rankBronze, other.rankBronze, t)!,
      rankSilver: Color.lerp(rankSilver, other.rankSilver, t)!,
      rankGold: Color.lerp(rankGold, other.rankGold, t)!,
      rankPlatinum: Color.lerp(rankPlatinum, other.rankPlatinum, t)!,
      rankDiamond: Color.lerp(rankDiamond, other.rankDiamond, t)!,
    );
  }
}
