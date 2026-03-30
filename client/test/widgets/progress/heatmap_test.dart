import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/progress/heatmap.dart';

Widget wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(
      body: SizedBox(
        width: 400,
        child: child,
      ),
    ),
  );
}

/// Builds a map of [count] completed days ending today.
Map<DateTime, int> _buildData({required int completedDays}) {
  final today = DateTime.now();
  final result = <DateTime, int>{};
  for (int i = 0; i < completedDays; i++) {
    final raw = today.subtract(Duration(days: i));
    result[DateTime(raw.year, raw.month, raw.day)] = 1;
  }
  return result;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ValenceHeatmap widget', () {
    testWidgets('renders without error with empty data', (tester) async {
      await tester.pumpWidget(wrap(
        const ValenceHeatmap(
          data: {},
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();
      expect(find.byType(ValenceHeatmap), findsOneWidget);
    });

    testWidgets('renders without error with partial data', (tester) async {
      final data = _buildData(completedDays: 20);
      await tester.pumpWidget(wrap(
        ValenceHeatmap(
          data: data,
          color: const Color(0xFF4CAF50),
        ),
      ));
      await tester.pump();
      expect(find.byType(ValenceHeatmap), findsOneWidget);
    });

    testWidgets('renders without error with 84 days of data', (tester) async {
      final data = _buildData(completedDays: 84);
      await tester.pumpWidget(wrap(
        ValenceHeatmap(
          data: data,
          color: const Color(0xFFF7CD63),
        ),
      ));
      await tester.pump();
      expect(find.byType(ValenceHeatmap), findsOneWidget);
    });

    testWidgets('shows day labels M, W, F', (tester) async {
      await tester.pumpWidget(wrap(
        const ValenceHeatmap(
          data: {},
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();

      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('is horizontally scrollable', (tester) async {
      await tester.pumpWidget(wrap(
        const ValenceHeatmap(
          data: {},
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final sv = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(sv.scrollDirection, Axis.horizontal);
    });

    testWidgets('defaults to 12 weeks', (tester) async {
      await tester.pumpWidget(wrap(
        const ValenceHeatmap(
          data: {},
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();

      final widget = tester.widget<ValenceHeatmap>(find.byType(ValenceHeatmap));
      expect(widget.weeks, 12);
    });

    testWidgets('accepts custom weeks count', (tester) async {
      await tester.pumpWidget(wrap(
        const ValenceHeatmap(
          data: {},
          color: Color(0xFF4E55E0),
          weeks: 8,
        ),
      ));
      await tester.pump();

      final widget = tester.widget<ValenceHeatmap>(find.byType(ValenceHeatmap));
      expect(widget.weeks, 8);
    });

    testWidgets('uses provided color for cells', (tester) async {
      const testColor = Color(0xFFFF5722);
      final data = _buildData(completedDays: 10);

      await tester.pumpWidget(wrap(
        ValenceHeatmap(
          data: data,
          color: testColor,
        ),
      ));
      await tester.pump();

      final widget = tester.widget<ValenceHeatmap>(find.byType(ValenceHeatmap));
      expect(widget.color, testColor);
    });
  });
}
