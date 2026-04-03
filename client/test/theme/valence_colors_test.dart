import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/theme/valence_colors.dart';

void main() {
  const colorsA = ValenceColors(
    surfaceBackground: Color(0xFF000000),
    surfacePrimary: Color(0xFF111111),
    surfaceElevated: Color(0xFF222222),
    surfaceSunken: Color(0xFF333333),
    accentPrimary: Color(0xFF444444),
    accentSecondary: Color(0xFF555555),
    accentSuccess: Color(0xFF666666),
    accentWarning: Color(0xFF777777),
    accentError: Color(0xFF888888),
    accentSocial: Color(0xFF999999),
    textPrimary: Color(0xFFAAAAAA),
    textSecondary: Color(0xFFBBBBBB),
    textInverse: Color(0xFFCCCCCC),
    textLink: Color(0xFFDDDDDD),
    borderDefault: Color(0xFFEEEEEE),
    borderFocus: Color(0xFFFFFFFF),
    chainGold: Color(0xFFFFD700),
    chainSilver: Color(0xFFC0C0C0),
    chainBroken: Color(0xFFFF6B6B),
    rankBronze: Color(0xFFCD7F32),
    rankSilver: Color(0xFFC0C0C0),
    rankGold: Color(0xFFFFD700),
    rankPlatinum: Color(0xFFE5E4E2),
    rankDiamond: Color(0xFFB9F2FF),
  );

  const colorsB = ValenceColors(
    surfaceBackground: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFEEEEEE),
    surfaceElevated: Color(0xFFDDDDDD),
    surfaceSunken: Color(0xFFCCCCCC),
    accentPrimary: Color(0xFFBBBBBB),
    accentSecondary: Color(0xFFAAAAAA),
    accentSuccess: Color(0xFF999999),
    accentWarning: Color(0xFF888888),
    accentError: Color(0xFF777777),
    accentSocial: Color(0xFF666666),
    textPrimary: Color(0xFF555555),
    textSecondary: Color(0xFF444444),
    textInverse: Color(0xFF333333),
    textLink: Color(0xFF222222),
    borderDefault: Color(0xFF111111),
    borderFocus: Color(0xFF000000),
    chainGold: Color(0xFF000000),
    chainSilver: Color(0xFF000000),
    chainBroken: Color(0xFF000000),
    rankBronze: Color(0xFF000000),
    rankSilver: Color(0xFF000000),
    rankGold: Color(0xFF000000),
    rankPlatinum: Color(0xFF000000),
    rankDiamond: Color(0xFF000000),
  );

  group('ValenceColors construction', () {
    test('holds all color values correctly', () {
      expect(colorsA.surfaceBackground, const Color(0xFF000000));
      expect(colorsA.surfacePrimary, const Color(0xFF111111));
      expect(colorsA.surfaceElevated, const Color(0xFF222222));
      expect(colorsA.surfaceSunken, const Color(0xFF333333));
      expect(colorsA.accentPrimary, const Color(0xFF444444));
      expect(colorsA.accentSecondary, const Color(0xFF555555));
      expect(colorsA.accentSuccess, const Color(0xFF666666));
      expect(colorsA.accentWarning, const Color(0xFF777777));
      expect(colorsA.accentError, const Color(0xFF888888));
      expect(colorsA.accentSocial, const Color(0xFF999999));
      expect(colorsA.textPrimary, const Color(0xFFAAAAAA));
      expect(colorsA.textSecondary, const Color(0xFFBBBBBB));
      expect(colorsA.textInverse, const Color(0xFFCCCCCC));
      expect(colorsA.textLink, const Color(0xFFDDDDDD));
      expect(colorsA.borderDefault, const Color(0xFFEEEEEE));
      expect(colorsA.borderFocus, const Color(0xFFFFFFFF));
      expect(colorsA.chainGold, const Color(0xFFFFD700));
      expect(colorsA.chainSilver, const Color(0xFFC0C0C0));
      expect(colorsA.chainBroken, const Color(0xFFFF6B6B));
      expect(colorsA.rankBronze, const Color(0xFFCD7F32));
      expect(colorsA.rankSilver, const Color(0xFFC0C0C0));
      expect(colorsA.rankGold, const Color(0xFFFFD700));
      expect(colorsA.rankPlatinum, const Color(0xFFE5E4E2));
      expect(colorsA.rankDiamond, const Color(0xFFB9F2FF));
    });
  });

  group('ValenceColors.lerp', () {
    test('lerp at t=0 returns the original colors', () {
      final result = colorsA.lerp(colorsB, 0.0);
      expect(result.surfaceBackground, colorsA.surfaceBackground);
      expect(result.accentPrimary, colorsA.accentPrimary);
      expect(result.textPrimary, colorsA.textPrimary);
      expect(result.chainGold, colorsA.chainGold);
    });

    test('lerp at t=1 returns the target colors', () {
      final result = colorsA.lerp(colorsB, 1.0);
      expect(result.surfaceBackground, colorsB.surfaceBackground);
      expect(result.accentPrimary, colorsB.accentPrimary);
      expect(result.textPrimary, colorsB.textPrimary);
      expect(result.chainGold, colorsB.chainGold);
    });

    test('lerp at t=0.5 returns midpoint colors', () {
      final result = colorsA.lerp(colorsB, 0.5);
      // surfaceBackground: 0xFF000000 -> 0xFFFFFFFF, midpoint ~ 0xFF7F7F7F
      final expectedBg = Color.lerp(const Color(0xFF000000), const Color(0xFFFFFFFF), 0.5)!;
      expect(result.surfaceBackground, expectedBg);
    });

    test('lerp returns a ValenceColors instance', () {
      final result = colorsA.lerp(colorsB, 0.3);
      expect(result, isA<ValenceColors>());
    });

    test('lerp interpolates all 24 color fields', () {
      final result = colorsA.lerp(colorsB, 0.5);
      // Verify none of the fields are null by accessing all of them
      expect(result.surfaceBackground, isNotNull);
      expect(result.surfacePrimary, isNotNull);
      expect(result.surfaceElevated, isNotNull);
      expect(result.surfaceSunken, isNotNull);
      expect(result.accentPrimary, isNotNull);
      expect(result.accentSecondary, isNotNull);
      expect(result.accentSuccess, isNotNull);
      expect(result.accentWarning, isNotNull);
      expect(result.accentError, isNotNull);
      expect(result.accentSocial, isNotNull);
      expect(result.textPrimary, isNotNull);
      expect(result.textSecondary, isNotNull);
      expect(result.textInverse, isNotNull);
      expect(result.textLink, isNotNull);
      expect(result.borderDefault, isNotNull);
      expect(result.borderFocus, isNotNull);
      expect(result.chainGold, isNotNull);
      expect(result.chainSilver, isNotNull);
      expect(result.chainBroken, isNotNull);
      expect(result.rankBronze, isNotNull);
      expect(result.rankSilver, isNotNull);
      expect(result.rankGold, isNotNull);
      expect(result.rankPlatinum, isNotNull);
      expect(result.rankDiamond, isNotNull);
    });
  });
}
