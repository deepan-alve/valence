import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/habit/day_selector.dart';

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

/// Builds a 7-day list starting from the given Monday.
List<DateTime> buildWeek(DateTime monday) {
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final monday = DateTime(2026, 3, 23); // Monday
  final days = buildWeek(monday);
  final selectedDay = days[0]; // Monday selected

  final Map<DateTime, DayStatus> statusMap = {
    days[0]: DayStatus.allDone,
    days[1]: DayStatus.partial,
    days[2]: DayStatus.missed,
    days[3]: DayStatus.allDone,
    days[4]: DayStatus.future,
    days[5]: DayStatus.future,
    days[6]: DayStatus.future,
  };

  testWidgets('renders 7 day chips', (tester) async {
    await tester.pumpWidget(wrap(
      DaySelector(
        days: days,
        selectedDay: selectedDay,
        dayStatus: statusMap,
        onDaySelected: (_) {},
      ),
    ));
    await tester.pump();

    // Each day has a short name
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
  });

  testWidgets('shows day numbers', (tester) async {
    await tester.pumpWidget(wrap(
      DaySelector(
        days: days,
        selectedDay: selectedDay,
        dayStatus: statusMap,
        onDaySelected: (_) {},
      ),
    ));
    await tester.pump();

    expect(find.text('23'), findsOneWidget); // Monday the 23rd
    expect(find.text('24'), findsOneWidget); // Tuesday
  });

  testWidgets('calls onDaySelected with correct day when tapped', (tester) async {
    DateTime? tappedDay;

    await tester.pumpWidget(wrap(
      DaySelector(
        days: days,
        selectedDay: selectedDay,
        dayStatus: statusMap,
        onDaySelected: (d) => tappedDay = d,
      ),
    ));
    await tester.pump();

    // Tap Tuesday (index 1)
    await tester.tap(find.text('Tue'));
    await tester.pump();

    expect(tappedDay, isNotNull);
    expect(tappedDay!.weekday, DateTime.tuesday);
  });

  testWidgets('status indicators render for past days', (tester) async {
    await tester.pumpWidget(wrap(
      DaySelector(
        days: days,
        selectedDay: selectedDay,
        dayStatus: statusMap,
        onDaySelected: (_) {},
      ),
    ));
    await tester.pump();

    // allDone (Monday), partial (Tuesday), missed (Wednesday) should show dots
    // Future days (Fri-Sun) should not show dots
    // We check via the Container widgets with circular decoration
    final containers = tester.widgetList<Container>(find.byType(Container));
    final dotContainers = containers.where((c) {
      final deco = c.decoration;
      if (deco is BoxDecoration) {
        return deco.shape == BoxShape.circle &&
            (deco.color == const Color(0xFF22C55E) ||
                deco.color == const Color(0xFFF59E0B) ||
                deco.color == const Color(0xFFEF4444));
      }
      return false;
    }).toList();

    // Monday=allDone, Tuesday=partial, Wednesday=missed, Thursday=allDone → 4 dots
    // But Monday is selected so no dot for selected day
    // selected day has no indicator → 3 dots (Tue, Wed, Thu)
    expect(dotContainers.length, greaterThanOrEqualTo(3));
  });

  testWidgets('selected day chip is highlighted (accentPrimary)', (tester) async {
    await tester.pumpWidget(wrap(
      DaySelector(
        days: days,
        selectedDay: selectedDay,
        dayStatus: statusMap,
        onDaySelected: (_) {},
      ),
    ));
    await tester.pump();

    // The selected chip's AnimatedContainer should use accentPrimary bg
    final animatedContainers = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );

    final highlighted = animatedContainers.where((c) {
      final deco = c.decoration;
      if (deco is BoxDecoration) {
        return deco.color == daybreakColors.accentPrimary;
      }
      return false;
    }).toList();

    expect(highlighted.length, 1);
  });

  testWidgets('DaySelector renders in dark mode', (tester) async {
    await tester.pumpWidget(wrap(
      DaySelector(
        days: days,
        selectedDay: days[2],
        dayStatus: statusMap,
        onDaySelected: (_) {},
      ),
      isDark: true,
    ));
    await tester.pump();

    expect(find.text('Wed'), findsOneWidget);
  });
}
