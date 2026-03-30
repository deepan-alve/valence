import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/progress/goal_progress.dart';

Widget wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('GoalProgress widget', () {
    testWidgets('renders without error for Ignition stage', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.ignition,
          daysToNextStage: 7,
          totalDaysCompleted: 3,
        ),
      ));
      await tester.pump();
      // Should render without throwing
      expect(find.byType(GoalProgress), findsOneWidget);
    });

    testWidgets('shows all 4 stage names', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.foundation,
          daysToNextStage: 5,
          totalDaysCompleted: 10,
        ),
      ));
      await tester.pump();

      expect(find.text('Ignition'), findsOneWidget);
      expect(find.text('Foundation'), findsOneWidget);
      expect(find.text('Momentum'), findsOneWidget);
      expect(find.text('Formed'), findsOneWidget);
    });

    testWidgets('shows days-to-next label for non-Formed stages', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.ignition,
          daysToNextStage: 7,
          totalDaysCompleted: 3,
        ),
      ));
      await tester.pump();

      // The sub-label is a RichText — search its plain text representation.
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('7'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('days to'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows "Habit fully formed!" at Formed stage', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.formed,
          daysToNextStage: 0,
          totalDaysCompleted: 66,
        ),
      ));
      await tester.pump();

      expect(find.text('Habit fully formed!'), findsOneWidget);
    });

    testWidgets('renders for Foundation stage', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.foundation,
          daysToNextStage: 11,
          totalDaysCompleted: 10,
        ),
      ));
      await tester.pump();
      expect(find.byType(GoalProgress), findsOneWidget);
    });

    testWidgets('renders for Momentum stage', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.momentum,
          daysToNextStage: 45,
          totalDaysCompleted: 21,
        ),
      ));
      await tester.pump();
      expect(find.byType(GoalProgress), findsOneWidget);
    });

    testWidgets('stage target-day badges are visible', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.ignition,
          daysToNextStage: 7,
          totalDaysCompleted: 3,
        ),
      ));
      await tester.pump();

      // Node badges show 3, 10, 21; 66 — upcoming stages show the day count
      // as text inside the unfilled nodes. Ignition (3d) is current so it shows
      // the badge; Foundation (10), Momentum (21), Formed (66) are upcoming.
      expect(find.text('10'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('66'), findsOneWidget);
    });

    testWidgets('check icon appears for completed stages', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.foundation,
          daysToNextStage: 11,
          totalDaysCompleted: 10,
        ),
      ));
      await tester.pump();

      // Foundation stage means Ignition is completed → one check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('three check icons at Formed stage', (tester) async {
      await tester.pumpWidget(wrap(
        const GoalProgress(
          goalStage: GoalStage.formed,
          daysToNextStage: 0,
          totalDaysCompleted: 70,
        ),
      ));
      await tester.pump();

      // Ignition, Foundation, Momentum are all completed → 3 check icons
      expect(find.byIcon(Icons.check), findsNWidgets(3));
    });
  });
}
