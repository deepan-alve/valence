import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/group/leaderboard_row.dart';

Widget wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

WeeklyScore _score({
  int rank = 1,
  String name = 'Nitil',
  String memberId = 'u1',
  int percent = 98,
  bool isTied = false,
  int habitsCompleted = 45,
  int groupContrib = 15,
  int kudosReceived = 8,
  int perfectDays = 10,
}) {
  return WeeklyScore(
    rank: rank,
    memberId: memberId,
    memberName: name,
    consistencyPercent: percent,
    isTied: isTied,
    breakdown: ContributionBreakdown(
      habitsCompleted: habitsCompleted,
      groupStreakContributions: groupContrib,
      kudosReceived: kudosReceived,
      perfectDays: perfectDays,
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LeaderboardRow — collapsed state', () {
    testWidgets('shows member name', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(name: 'Nitil')),
      ));
      await tester.pump();
      expect(find.textContaining('Nitil'), findsOneWidget);
    });

    testWidgets('shows rank number with # prefix', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(rank: 2, name: 'Diana')),
      ));
      await tester.pump();
      expect(find.text('#2'), findsOneWidget);
    });

    testWidgets('shows consistency percentage', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(percent: 87)),
      ));
      await tester.pump();
      expect(find.textContaining('87%'), findsOneWidget);
    });

    testWidgets('shows member initials in avatar circle', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(name: 'Diana')),
      ));
      await tester.pump();
      expect(find.text('DI'), findsOneWidget);
    });

    testWidgets('breakdown is NOT visible in collapsed state', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score()),
      ));
      await tester.pump();
      // Breakdown panel label should not be visible
      expect(find.textContaining('Total points'), findsNothing);
    });
  });

  group('LeaderboardRow — expand / collapse', () {
    testWidgets('tapping expands the row and shows breakdown', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score()),
      ));
      await tester.pump();

      // Tap the row
      await tester.tap(find.byType(LeaderboardRow));
      await tester.pumpAndSettle();

      expect(find.textContaining('Total points'), findsOneWidget);
    });

    testWidgets('tapping again collapses the row', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score()),
      ));
      await tester.pump();

      // Expand
      await tester.tap(find.byType(LeaderboardRow));
      await tester.pumpAndSettle();
      expect(find.textContaining('Total points'), findsOneWidget);

      // Collapse
      await tester.tap(find.byType(LeaderboardRow));
      await tester.pumpAndSettle();
      expect(find.textContaining('Total points'), findsNothing);
    });

    testWidgets('expanded state shows all four breakdown categories', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(
          habitsCompleted: 45,
          groupContrib: 15,
          kudosReceived: 8,
          perfectDays: 10,
        )),
      ));
      await tester.pump();

      await tester.tap(find.byType(LeaderboardRow));
      await tester.pumpAndSettle();

      expect(find.textContaining('Habits Completed'), findsOneWidget);
      expect(find.textContaining('Group Contributions'), findsOneWidget);
      expect(find.textContaining('Kudos Received'), findsOneWidget);
      expect(find.textContaining('Perfect Days'), findsOneWidget);
    });

    testWidgets('total points sum is correct', (tester) async {
      // 45 + 15 + 8 + 10 = 78
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(
          habitsCompleted: 45,
          groupContrib: 15,
          kudosReceived: 8,
          perfectDays: 10,
        )),
      ));
      await tester.pump();

      await tester.tap(find.byType(LeaderboardRow));
      await tester.pumpAndSettle();

      expect(find.textContaining('78'), findsWidgets);
    });

    testWidgets('shows baseline caption when expanded', (tester) async {
      const caption = 'Based on your personal consistency';
      await tester.pumpWidget(wrap(
        LeaderboardRow(
          score: _score(),
          baselineCaption: caption,
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(LeaderboardRow));
      await tester.pumpAndSettle();

      expect(find.textContaining('Based on your personal consistency'), findsOneWidget);
    });
  });

  group('LeaderboardRow — rank medal styling', () {
    testWidgets('renders rank #1 without error', (tester) async {
      await tester.pumpWidget(wrap(LeaderboardRow(score: _score(rank: 1))));
      await tester.pump();
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('renders rank #2 without error', (tester) async {
      await tester.pumpWidget(wrap(LeaderboardRow(score: _score(rank: 2))));
      await tester.pump();
      expect(find.text('#2'), findsOneWidget);
    });

    testWidgets('renders rank #3 without error', (tester) async {
      await tester.pumpWidget(wrap(LeaderboardRow(score: _score(rank: 3))));
      await tester.pump();
      expect(find.text('#3'), findsOneWidget);
    });

    testWidgets('renders lower ranks without error', (tester) async {
      await tester.pumpWidget(wrap(LeaderboardRow(score: _score(rank: 5, percent: 12))));
      await tester.pump();
      expect(find.text('#5'), findsOneWidget);
    });
  });

  group('LeaderboardRow — low consistency', () {
    testWidgets('renders 12% consistency without error', (tester) async {
      await tester.pumpWidget(wrap(
        LeaderboardRow(score: _score(percent: 12, rank: 5, name: 'Zara')),
      ));
      await tester.pump();
      expect(find.textContaining('12%'), findsOneWidget);
    });
  });

  group('LeaderboardRow — dark mode', () {
    testWidgets('renders in dark mode', (tester) async {
      final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: true);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [tokens]),
        home: Scaffold(
          body: LeaderboardRow(score: _score()),
        ),
      ));
      await tester.pump();
      expect(find.byType(LeaderboardRow), findsOneWidget);
    });
  });
}
