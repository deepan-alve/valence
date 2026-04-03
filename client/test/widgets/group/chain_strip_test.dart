import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/group/chain_strip.dart';

Widget wrap(Widget child, {bool isDark = false}) {
  final tokens = ValenceTokens.fromColors(
    colors: daybreakColors,
    isDark: isDark,
  );
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Helper to build 7 chain links with mixed types.
List<ChainLink> buildLinks() {
  final now = DateTime(2026, 3, 30);
  return [
    ChainLink(date: now.subtract(const Duration(days: 6)), type: ChainLinkType.gold),
    ChainLink(date: now.subtract(const Duration(days: 5)), type: ChainLinkType.gold),
    ChainLink(date: now.subtract(const Duration(days: 4)), type: ChainLinkType.silver),
    ChainLink(date: now.subtract(const Duration(days: 3)), type: ChainLinkType.gold),
    ChainLink(date: now.subtract(const Duration(days: 2)), type: ChainLinkType.broken),
    ChainLink(date: now.subtract(const Duration(days: 1)), type: ChainLinkType.gold),
    ChainLink(date: now, type: ChainLinkType.future),
  ];
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final links = buildLinks();

  testWidgets('renders streak count in label', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
      ),
    ));
    await tester.pump();

    expect(find.textContaining('12 day streak'), findsOneWidget);
  });

  testWidgets('renders fire emoji in streak label', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 5,
        tier: 'spark',
      ),
    ));
    await tester.pump();

    expect(find.textContaining('🔥'), findsOneWidget);
  });

  testWidgets('renders tier badge text', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
      ),
    ));
    await tester.pump();

    expect(find.text('EMBER'), findsOneWidget);
  });

  testWidgets('renders tier badge uppercased', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 25,
        tier: 'flame',
      ),
    ));
    await tester.pump();

    expect(find.text('FLAME'), findsOneWidget);
  });

  testWidgets('renders exactly 7 link pills (one Expanded per link)', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
      ),
    ));
    await tester.pump();

    // Each link is wrapped in an Expanded widget inside the Row
    expect(find.byType(Expanded), findsNWidgets(7));
  });

  testWidgets('broken link shows X close icon', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
      ),
    ));
    await tester.pump();

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    int tapCount = 0;
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
        onTap: () => tapCount++,
      ),
    ));
    await tester.pump();

    await tester.tap(find.textContaining('12 day streak'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('no GestureDetector when onTap is null', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
      ),
    ));
    await tester.pump();

    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('renders in dark mode', (tester) async {
    await tester.pumpWidget(wrap(
      ChainStrip(
        links: links,
        currentStreak: 12,
        tier: 'ember',
      ),
      isDark: true,
    ));
    await tester.pump();

    expect(find.textContaining('12 day streak'), findsOneWidget);
  });

  testWidgets('renders all link types without error', (tester) async {
    final allTypeLinks = [
      ChainLink(date: DateTime(2026, 3, 24), type: ChainLinkType.gold),
      ChainLink(date: DateTime(2026, 3, 25), type: ChainLinkType.silver),
      ChainLink(date: DateTime(2026, 3, 26), type: ChainLinkType.broken),
      ChainLink(date: DateTime(2026, 3, 27), type: ChainLinkType.future),
      ChainLink(date: DateTime(2026, 3, 28), type: ChainLinkType.gold),
      ChainLink(date: DateTime(2026, 3, 29), type: ChainLinkType.silver),
      ChainLink(date: DateTime(2026, 3, 30), type: ChainLinkType.future),
    ];

    await tester.pumpWidget(wrap(
      ChainStrip(
        links: allTypeLinks,
        currentStreak: 3,
        tier: 'spark',
      ),
    ));
    await tester.pump();

    expect(find.textContaining('3 day streak'), findsOneWidget);
    expect(find.text('SPARK'), findsOneWidget);
  });
}
