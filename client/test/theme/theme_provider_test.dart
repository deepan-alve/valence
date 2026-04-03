import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/theme_provider.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/themes/nocturnal_sanctuary.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ThemeProvider defaults', () {
    test('default theme is daybreak', () {
      final provider = ThemeProvider();
      expect(provider.activeThemeId, equals('daybreak'));
    });

    test('daybreak is a light theme', () {
      final provider = ThemeProvider();
      expect(provider.isDark, isFalse);
    });

    testWidgets('default tokens use daybreak colors', (tester) async {
      final provider = ThemeProvider();
      final tokens = provider.tokens;
      await tester.pump();
      expect(
        tokens.colors.surfaceBackground,
        equals(daybreakColors.surfaceBackground),
      );
    });
  });

  group('ThemeProvider setTheme', () {
    test('switches to nocturnal_sanctuary', () {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      expect(provider.activeThemeId, equals('nocturnal_sanctuary'));
    });

    test('nocturnal_sanctuary is a dark theme', () {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      expect(provider.isDark, isTrue);
    });

    testWidgets('nocturnal_sanctuary tokens use correct colors',
        (tester) async {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      final tokens = provider.tokens;
      await tester.pump();
      expect(
        tokens.colors.surfaceBackground,
        equals(nocturnalSanctuaryColors.surfaceBackground),
      );
      expect(tokens.isDark, isTrue);
    });

    test('can switch back to daybreak', () {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      provider.setTheme('daybreak');
      expect(provider.activeThemeId, equals('daybreak'));
      expect(provider.isDark, isFalse);
    });

    test('ignores unknown theme ids', () {
      final provider = ThemeProvider();
      provider.setTheme('unknown_theme');
      expect(provider.activeThemeId, equals('daybreak'));
    });

    test('setting the same theme does not change state', () {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      final idBefore = provider.activeThemeId;
      provider.setTheme('nocturnal_sanctuary');
      expect(provider.activeThemeId, equals(idBefore));
    });

    test('notifies listeners on valid theme change', () {
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setTheme('nocturnal_sanctuary');
      expect(notifyCount, equals(1));

      provider.setTheme('daybreak');
      expect(notifyCount, equals(2));
    });

    test('does not notify listeners for unknown theme', () {
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setTheme('ghost_theme');
      expect(notifyCount, equals(0));
    });

    test('does not notify listeners when same theme is set again', () {
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setTheme('daybreak'); // already daybreak
      expect(notifyCount, equals(0));
    });
  });

  group('ThemeProvider themeData', () {
    testWidgets('themeData has ValenceTokens extension for daybreak',
        (tester) async {
      final provider = ThemeProvider();
      final theme = provider.themeData;

      // Pump to drain any async font work.
      await tester.pump();

      final tokens = theme.extension<ValenceTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.isDark, isFalse);
      expect(
        tokens.colors.accentPrimary,
        equals(daybreakColors.accentPrimary),
      );
    });

    testWidgets('themeData has ValenceTokens extension for nocturnal_sanctuary',
        (tester) async {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      final theme = provider.themeData;

      await tester.pump();

      final tokens = theme.extension<ValenceTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.isDark, isTrue);
      expect(
        tokens.colors.accentPrimary,
        equals(nocturnalSanctuaryColors.accentPrimary),
      );
    });

    testWidgets('themeData brightness matches isDark for daybreak',
        (tester) async {
      final provider = ThemeProvider();
      final theme = provider.themeData;
      await tester.pump();
      expect(theme.brightness, equals(Brightness.light));
    });

    testWidgets('themeData brightness matches isDark for nocturnal_sanctuary',
        (tester) async {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      final theme = provider.themeData;
      await tester.pump();
      expect(theme.brightness, equals(Brightness.dark));
    });

    testWidgets('themeData scaffoldBackgroundColor matches surfaceBackground',
        (tester) async {
      final provider = ThemeProvider();
      final theme = provider.themeData;
      await tester.pump();
      expect(
        theme.scaffoldBackgroundColor,
        equals(daybreakColors.surfaceBackground),
      );
    });
  });
}
