import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';
import 'package:valence/widgets/group/streak_freeze_sheet.dart';

Widget _wrap(Widget child, GroupProvider provider) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: ChangeNotifierProvider<GroupProvider>.value(
      value: provider,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('StreakFreezeSheet — basic rendering', () {
    testWidgets('renders personality-on title by default', (tester) async {
      final provider = GroupProvider();
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      // personalityOn = true → "Deploy the freeze? ❄️🛡️"
      expect(find.textContaining('freeze'), findsWidgets);
    });

    testWidgets('shows cost and balance rows', (tester) async {
      final provider = GroupProvider();
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Your balance'), findsOneWidget);
      // Default balance is 42, cost is 10
      // "10 consistency points" appears in body copy AND the info row value
      expect(find.textContaining('10 consistency points'), findsWidgets);
      expect(find.textContaining('42 points'), findsOneWidget);
    });

    testWidgets('shows Use Freeze and Cancel buttons', (tester) async {
      final provider = GroupProvider();
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      expect(find.widgetWithText(ValenceButton, 'Use Freeze'), findsOneWidget);
      expect(find.widgetWithText(ValenceButton, 'Cancel'), findsOneWidget);
    });
  });

  group('StreakFreezeSheet — sufficient points', () {
    testWidgets('Use Freeze button is enabled when balance >= cost', (tester) async {
      final provider = GroupProvider(); // balance=42, cost=10
      expect(provider.canAffordFreeze, true);
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      final btn = tester.widget<ValenceButton>(
        find.widgetWithText(ValenceButton, 'Use Freeze'),
      );
      expect(btn.onPressed, isNotNull);
    });
  });

  group('StreakFreezeSheet — freeze already active', () {
    testWidgets('shows Freeze Active Today when freeze is active', (tester) async {
      final provider = GroupProvider();
      // Activate freeze
      provider.useStreakFreeze();
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      expect(find.textContaining('Freeze Active Today'), findsOneWidget);
    });

    testWidgets('Use Freeze button is disabled when freeze already active', (tester) async {
      final provider = GroupProvider();
      provider.useStreakFreeze();
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      final btn = tester.widget<ValenceButton>(
        find.widgetWithText(ValenceButton, 'Use Freeze'),
      );
      expect(btn.onPressed, isNull);
    });
  });

  group('StreakFreezeSheet — personality OFF mode', () {
    testWidgets('renders personality-off title', (tester) async {
      final provider = GroupProvider();
      provider.togglePersonality();
      await tester.pumpWidget(_wrap(const StreakFreezeSheet(), provider));
      await tester.pump();
      expect(find.text('Use a Streak Freeze?'), findsOneWidget);
    });
  });

  group('StreakFreezeSheet — Cancel closes sheet', () {
    testWidgets('Cancel button closes the bottom sheet', (tester) async {
      final provider = GroupProvider();
      bool popped = false;

      final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(extensions: [tokens]),
          home: ChangeNotifierProvider<GroupProvider>.value(
            value: provider,
            child: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: ctx,
                        builder: (sheetCtx) => ChangeNotifierProvider<GroupProvider>.value(
                          value: provider,
                          child: const StreakFreezeSheet(),
                        ),
                      );
                      popped = true;
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(ValenceButton, 'Cancel'));
      await tester.tap(find.widgetWithText(ValenceButton, 'Cancel'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(popped, true);
    });
  });
}
