import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/progress/reflection_sheet.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget wrapWithProvider(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return ChangeNotifierProvider(
    create: (_) => ProgressProvider(),
    child: MaterialApp(
      theme: ThemeData.light().copyWith(extensions: [tokens]),
      home: Scaffold(body: child),
    ),
  );
}

/// Builds a [HabitProgress] with full control over [reflectionUnlocked].
HabitProgress makeProgress({
  bool reflectionUnlocked = true,
  String habitId = 'test-habit',
  String habitName = 'Exercise',
  Color color = const Color(0xFF4E55E0),
}) {
  return HabitProgress(
    habitId: habitId,
    habitName: habitName,
    habitColor: color,
    currentStreak: reflectionUnlocked ? 12 : 5,
    longestStreak: reflectionUnlocked ? 12 : 5,
    totalDaysCompleted: reflectionUnlocked ? 12 : 5,
    goalStage: reflectionUnlocked ? GoalStage.foundation : GoalStage.ignition,
    daysToNextStage: reflectionUnlocked ? 9 : 5,
    completionRate: 0.75,
    heatmapData: const {},
    frequencyByDay: const {},
    failureInsights: const [],
    reflectionUnlocked: reflectionUnlocked,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ReflectionSheet widget', () {
    testWidgets('renders without error when reflection is unlocked',
        (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.byType(ReflectionSheet), findsOneWidget);
    });

    testWidgets('shows habit name chip at top', (tester) async {
      final progress = makeProgress(habitName: 'Morning Run');
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('shows "Evening Reflection" title', (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.text('Evening Reflection'), findsOneWidget);
    });

    testWidgets('shows difficulty question text', (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.text('How difficult was it today?'), findsOneWidget);
    });

    testWidgets('shows all 5 visible text labels for difficulty',
        (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      // All 5 labels must be visible text (accessibility requirement)
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Okay'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Brutal'), findsOneWidget);
    });

    testWidgets('shows all 5 emoji faces', (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.text('😊'), findsOneWidget);
      expect(find.text('🙂'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
      expect(find.text('😓'), findsOneWidget);
      expect(find.text('😵'), findsOneWidget);
    });

    testWidgets('shows optional note text field', (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.text('Anything on your mind?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Done button is disabled when no difficulty selected',
        (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      // The Done button should be present
      expect(find.text('Done'), findsOneWidget);

      // Find the ElevatedButton wrapping "Done" — it should be disabled
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Done'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting a difficulty enables the Done button',
        (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      // Tap "Easy" label
      await tester.tap(find.text('Easy'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Done'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping a difficulty face marks it selected', (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      await tester.tap(find.text('Hard'));
      await tester.pump();

      // Just verify no crash and the widget still renders
      expect(find.byType(ReflectionSheet), findsOneWidget);
    });

    testWidgets('tapping different difficulties changes selection',
        (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      await tester.tap(find.text('Easy'));
      await tester.pump();

      await tester.tap(find.text('Brutal'));
      await tester.pump();

      // Should not crash and widget still present
      expect(find.byType(ReflectionSheet), findsOneWidget);
    });

    testWidgets('shows note hint text', (tester) async {
      final progress = makeProgress();
      await tester.pumpWidget(
        wrapWithProvider(ReflectionSheet(habitProgress: progress)),
      );
      await tester.pump();

      expect(find.text('Optional note…'), findsOneWidget);
    });

    testWidgets('ReflectionSheet.show does nothing when reflection locked',
        (tester) async {
      final lockedProgress = makeProgress(reflectionUnlocked: false);

      // Build a simple widget with a button that calls show()
      final tokens =
          ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(),
          child: MaterialApp(
            theme: ThemeData.light().copyWith(extensions: [tokens]),
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () =>
                      ReflectionSheet.show(ctx, lockedProgress),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pump();

      // No ReflectionSheet should appear
      expect(find.byType(ReflectionSheet), findsNothing);
    });

    testWidgets(
        'ReflectionSheet.show opens sheet when reflection is unlocked',
        (tester) async {
      final unlockedProgress = makeProgress(reflectionUnlocked: true);

      final tokens =
          ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(),
          child: MaterialApp(
            theme: ThemeData.light().copyWith(extensions: [tokens]),
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () =>
                      ReflectionSheet.show(ctx, unlockedProgress),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(ReflectionSheet), findsOneWidget);
    });

    testWidgets('submitting reflection calls provider and closes sheet',
        (tester) async {
      final progress = makeProgress(habitId: 'ex-1');
      final tokens =
          ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
      late ProgressProvider provider;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) {
            provider = ProgressProvider();
            return provider;
          },
          child: MaterialApp(
            theme: ThemeData.light().copyWith(extensions: [tokens]),
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => ReflectionSheet.show(ctx, progress),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Select "Okay" (difficulty 2)
      await tester.tap(find.text('Okay'));
      await tester.pump();

      // Tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Sheet should be gone and reflection recorded
      expect(find.byType(ReflectionSheet), findsNothing);
      expect(provider.reflections['ex-1'], 2);
    });
  });
}
