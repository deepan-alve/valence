import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/valence_colors.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/valence_typography.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/themes/nocturnal_sanctuary.dart';

// Minimal typography that doesn't trigger GoogleFonts network calls.
// We use copyWith on a plain TextStyle-based typography for testing.
ValenceTypography _makeTypography(Color color) {
  final base = TextStyle(color: color, fontSize: 16);
  return ValenceTypography(
    display: base,
    h1: base,
    h2: base,
    h3: base,
    bodyLarge: base,
    body: base,
    caption: base,
    overline: base,
    numbersDisplay: base,
    numbersBody: base,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ValenceTokens construction', () {
    test('creates dark tokens with correct colors and isDark flag', () {
      final typo = _makeTypography(nocturnalSanctuaryColors.textPrimary);
      final tokens = ValenceTokens(
        colors: nocturnalSanctuaryColors,
        typography: typo,
        isDark: true,
      );

      expect(tokens.isDark, isTrue);
      expect(tokens.colors, equals(nocturnalSanctuaryColors));
      expect(tokens.typography, same(typo));
    });

    test('creates light tokens with correct colors and isDark flag', () {
      final typo = _makeTypography(daybreakColors.textPrimary);
      final tokens = ValenceTokens(
        colors: daybreakColors,
        typography: typo,
        isDark: false,
      );

      expect(tokens.isDark, isFalse);
      expect(tokens.colors, equals(daybreakColors));
      expect(tokens.typography, same(typo));
    });

    testWidgets('fromColors factory wires typography color to textPrimary',
        (tester) async {
      // Use testWidgets so the test runner can properly drain async work
      // triggered by GoogleFonts inside ValenceTypography.fromColor.
      final tokens = ValenceTokens.fromColors(
        colors: daybreakColors,
        isDark: false,
      );

      // Pump to allow any pending async font work to settle.
      await tester.pump();

      expect(tokens.isDark, isFalse);
      expect(tokens.colors, equals(daybreakColors));
      expect(tokens.typography, isNotNull);
      // Obviously font styles (not GoogleFonts) carry color directly — safe.
      expect(tokens.typography.display.color, equals(daybreakColors.textPrimary));
      expect(tokens.typography.h1.color, equals(daybreakColors.textPrimary));
    });
  });

  group('ValenceTokens copyWith', () {
    test('copyWith preserves unchanged fields', () {
      final typo = _makeTypography(daybreakColors.textPrimary);
      final original = ValenceTokens(
        colors: daybreakColors,
        typography: typo,
        isDark: false,
      );
      final copy = original.copyWith(isDark: true);

      expect(copy.isDark, isTrue);
      expect(copy.colors, equals(original.colors));
      expect(copy.typography, same(original.typography));
    });

    test('copyWith replaces specified color field', () {
      final typo = _makeTypography(daybreakColors.textPrimary);
      final original = ValenceTokens(
        colors: daybreakColors,
        typography: typo,
        isDark: false,
      );
      final copy = original.copyWith(colors: nocturnalSanctuaryColors);

      expect(copy.colors, equals(nocturnalSanctuaryColors));
      expect(copy.isDark, isFalse);
      expect(copy.typography, same(original.typography));
    });

    test('copyWith replaces typography', () {
      final typoA = _makeTypography(daybreakColors.textPrimary);
      final typoB = _makeTypography(nocturnalSanctuaryColors.textPrimary);
      final original = ValenceTokens(
        colors: daybreakColors,
        typography: typoA,
        isDark: false,
      );
      final copy = original.copyWith(typography: typoB);

      expect(copy.typography, same(typoB));
    });
  });

  group('ValenceTokens lerp', () {
    ValenceTokens makeTokens(ValenceColors colors, bool dark) {
      return ValenceTokens(
        colors: colors,
        typography: _makeTypography(colors.textPrimary),
        isDark: dark,
      );
    }

    test('lerp with null returns self', () {
      final tokens = makeTokens(daybreakColors, false);
      final result = tokens.lerp(null, 0.5);
      expect(result, same(tokens));
    });

    test('lerp at t=0 returns colors from self', () {
      final a = makeTokens(daybreakColors, false);
      final b = makeTokens(nocturnalSanctuaryColors, true);

      final result = a.lerp(b, 0.0);

      expect(
        result.colors.surfaceBackground,
        equals(daybreakColors.surfaceBackground),
      );
      expect(result.isDark, isFalse);
    });

    test('lerp at t=1 returns colors from other', () {
      final a = makeTokens(daybreakColors, false);
      final b = makeTokens(nocturnalSanctuaryColors, true);

      final result = a.lerp(b, 1.0);

      expect(
        result.colors.surfaceBackground,
        equals(nocturnalSanctuaryColors.surfaceBackground),
      );
      expect(result.isDark, isTrue);
    });

    test('lerp isDark switches at t=0.5 boundary', () {
      final a = makeTokens(daybreakColors, false);
      final b = makeTokens(nocturnalSanctuaryColors, true);

      expect(a.lerp(b, 0.4).isDark, isFalse);
      expect(a.lerp(b, 0.5).isDark, isTrue);
      expect(a.lerp(b, 0.6).isDark, isTrue);
    });

    test('lerp interpolates surfaceBackground at t=0.5', () {
      final a = makeTokens(daybreakColors, false);
      final b = makeTokens(nocturnalSanctuaryColors, true);

      final result = a.lerp(b, 0.5);
      final expected = Color.lerp(
        daybreakColors.surfaceBackground,
        nocturnalSanctuaryColors.surfaceBackground,
        0.5,
      )!;

      expect(result.colors.surfaceBackground, equals(expected));
    });

    test('lerp interpolates typography at t=0.5', () {
      final a = makeTokens(daybreakColors, false);
      final b = makeTokens(nocturnalSanctuaryColors, true);

      final result = a.lerp(b, 0.5);
      final expectedBodyColor = Color.lerp(
        daybreakColors.textPrimary,
        nocturnalSanctuaryColors.textPrimary,
        0.5,
      )!;

      expect(result.typography.body.color, equals(expectedBodyColor));
    });
  });

  group('ValenceTokens ThemeData extension', () {
    test('can be retrieved from ThemeData via extension key', () {
      final typo = _makeTypography(daybreakColors.textPrimary);
      final tokens = ValenceTokens(
        colors: daybreakColors,
        typography: typo,
        isDark: false,
      );
      final theme = ThemeData(extensions: [tokens]);

      final retrieved = theme.extension<ValenceTokens>();
      expect(retrieved, isNotNull);
      expect(retrieved!.isDark, isFalse);
      expect(retrieved.colors, equals(daybreakColors));
    });

    test('dark tokens survive ThemeData round-trip', () {
      final typo = _makeTypography(nocturnalSanctuaryColors.textPrimary);
      final tokens = ValenceTokens(
        colors: nocturnalSanctuaryColors,
        typography: typo,
        isDark: true,
      );
      final theme = ThemeData(extensions: [tokens]);

      final retrieved = theme.extension<ValenceTokens>()!;
      expect(retrieved.isDark, isTrue);
      expect(
        retrieved.colors.surfaceBackground,
        equals(nocturnalSanctuaryColors.surfaceBackground),
      );
    });

    testWidgets('BuildContext extension retrieves tokens from widget tree',
        (tester) async {
      final typo = _makeTypography(daybreakColors.textPrimary);
      final tokens = ValenceTokens(
        colors: daybreakColors,
        typography: typo,
        isDark: false,
      );
      final theme = ThemeData(extensions: [tokens]);

      late ValenceTokens retrievedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              retrievedTokens = context.tokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(retrievedTokens.isDark, isFalse);
      expect(
        retrievedTokens.colors.accentPrimary,
        equals(daybreakColors.accentPrimary),
      );
    });
  });
}
