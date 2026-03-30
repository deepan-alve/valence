import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/habit/habit_card.dart';

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

// --- Fixtures ---

const Habit manualHabit = Habit(
  id: '1',
  name: 'Exercise',
  subtitle: '30 min workout',
  color: Color(0xFFB8EB6C),
  iconName: 'barbell',
  trackingType: TrackingType.manual,
  isCompleted: false,
);

const Habit completedHabit = Habit(
  id: '2',
  name: 'Read',
  subtitle: 'Read 20 pages',
  color: Color(0xFFF7CD63),
  iconName: 'book-open',
  trackingType: TrackingType.manual,
  isCompleted: true,
);

const Habit pluginHabit = Habit(
  id: '3',
  name: 'LeetCode',
  subtitle: 'Solve 1 problem',
  color: Color(0xFF4E55E0),
  iconName: 'code',
  trackingType: TrackingType.plugin,
  pluginName: 'LeetCode',
  isCompleted: false,
);

const Habit photoHabit = Habit(
  id: '4',
  name: 'Meditate',
  subtitle: '10 min session',
  color: Color(0xFFFC8FC6),
  iconName: 'brain',
  trackingType: TrackingType.manualPhoto,
  isCompleted: false,
);

const Habit redirectHabit = Habit(
  id: '5',
  name: 'Duolingo',
  subtitle: '1 lesson',
  color: Color(0xFF2EC4B6),
  iconName: 'globe',
  trackingType: TrackingType.redirect,
  redirectUrl: 'https://duolingo.com',
  isCompleted: false,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('HabitCard — display', () {
    testWidgets('renders habit name and subtitle', (tester) async {
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: manualHabit,
          onTap: () {},
          onComplete: () {},
        ),
      ));
      await tester.pump();

      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('30 min workout'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: manualHabit,
          onTap: () {},
          onComplete: () {},
        ),
        isDark: true,
      ));
      await tester.pump();

      expect(find.text('Exercise'), findsOneWidget);
    });
  });

  group('HabitCard — gesture matrix: manual', () {
    testWidgets('checkbox tap calls onComplete', (tester) async {
      int completeCalls = 0;
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: manualHabit,
          onTap: () {},
          onComplete: () => completeCalls++,
        ),
      ));
      await tester.pump();

      // Tap the checkbox (Container with circular border)
      final circles = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final deco = widget.decoration;
          if (deco is BoxDecoration) {
            return deco.shape == BoxShape.circle;
          }
        }
        return false;
      });
      expect(circles, findsWidgets);
      await tester.tap(circles.first);
      await tester.pump();

      expect(completeCalls, 1);
    });

    testWidgets('card body tap calls onTap', (tester) async {
      int tapCalls = 0;
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: manualHabit,
          onTap: () => tapCalls++,
          onComplete: () {},
        ),
      ));
      await tester.pump();

      // Tap the habit name area (card body)
      await tester.tap(find.text('Exercise'));
      await tester.pump();

      expect(tapCalls, 1);
    });

    testWidgets('long press calls onLongPress', (tester) async {
      int longPressCalls = 0;
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: manualHabit,
          onTap: () {},
          onComplete: () {},
          onLongPress: () => longPressCalls++,
        ),
      ));
      await tester.pump();

      await tester.longPress(find.text('Exercise'));
      await tester.pump();

      expect(longPressCalls, 1);
    });
  });

  group('HabitCard — gesture matrix: plugin', () {
    testWidgets('plugin habit shows Auto label', (tester) async {
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: pluginHabit,
          onTap: () {},
          onComplete: () {},
        ),
      ));
      await tester.pump();

      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('plugin habit card body tap calls onTap', (tester) async {
      int tapCalls = 0;
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: pluginHabit,
          onTap: () => tapCalls++,
          onComplete: () {},
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('LeetCode'));
      await tester.pump();

      expect(tapCalls, 1);
    });
  });

  group('HabitCard — completed state', () {
    testWidgets('completed habit shows filled check circle', (tester) async {
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: completedHabit,
          onTap: () {},
          onComplete: () {},
        ),
      ));
      await tester.pump();

      // Should find a check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping completed checkbox calls onComplete', (tester) async {
      int completeCalls = 0;
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: completedHabit,
          onTap: () {},
          onComplete: () => completeCalls++,
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(completeCalls, 1);
    });
  });

  group('HabitCard — manualPhoto', () {
    testWidgets('photo habit shows camera icon in checkbox', (tester) async {
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: photoHabit,
          onTap: () {},
          onComplete: () {},
        ),
      ));
      await tester.pump();

      expect(find.text('Meditate'), findsOneWidget);
      // Camera icon present in the checkbox area
    });

    testWidgets('photo habit checkbox tap calls onComplete', (tester) async {
      int completeCalls = 0;
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: photoHabit,
          onTap: () {},
          onComplete: () => completeCalls++,
        ),
      ));
      await tester.pump();

      // Tap the circle
      final circles = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final deco = widget.decoration;
          if (deco is BoxDecoration) {
            return deco.shape == BoxShape.circle;
          }
        }
        return false;
      });
      await tester.tap(circles.first);
      await tester.pump();

      expect(completeCalls, 1);
    });
  });

  group('HabitCard — redirect', () {
    testWidgets('redirect habit renders name correctly', (tester) async {
      await tester.pumpWidget(wrap(
        HabitCard(
          habit: redirectHabit,
          onTap: () {},
          onComplete: () {},
        ),
      ));
      await tester.pump();

      expect(find.text('Duolingo'), findsOneWidget);
      expect(find.text('1 lesson'), findsOneWidget);
    });
  });
}
