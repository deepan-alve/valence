import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/progress/frequency_chart.dart';

Widget wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(
      body: SizedBox(
        width: 400,
        height: 300,
        child: child,
      ),
    ),
  );
}

/// Full week data with varying rates.
const Map<int, double> _sampleData = {
  1: 0.85, // Mon — strongest
  2: 0.70, // Tue
  3: 0.65, // Wed
  4: 0.50, // Thu
  5: 0.75, // Fri
  6: 0.30, // Sat
  7: 0.20, // Sun — weakest
};

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('FrequencyChart widget', () {
    testWidgets('renders without error with sample data', (tester) async {
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: _sampleData,
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();
      expect(find.byType(FrequencyChart), findsOneWidget);
    });

    testWidgets('renders BarChart from fl_chart', (tester) async {
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: _sampleData,
          color: Color(0xFF4CAF50),
        ),
      ));
      await tester.pump();
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders without error with empty data', (tester) async {
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: {},
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();
      expect(find.byType(FrequencyChart), findsOneWidget);
    });

    testWidgets('renders without error with all zero rates', (tester) async {
      const zeroData = {
        1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0,
      };
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: zeroData,
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();
      expect(find.byType(FrequencyChart), findsOneWidget);
    });

    testWidgets('renders without error with all 100% rates', (tester) async {
      const fullData = {
        1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0, 5: 1.0, 6: 1.0, 7: 1.0,
      };
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: fullData,
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();
      expect(find.byType(FrequencyChart), findsOneWidget);
    });

    testWidgets('has fixed 180px height container', (tester) async {
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: _sampleData,
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(FrequencyChart),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, 180);
    });

    testWidgets('uses provided color', (tester) async {
      const testColor = Color(0xFFFF5722);
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: _sampleData,
          color: testColor,
        ),
      ));
      await tester.pump();

      final widget = tester.widget<FrequencyChart>(find.byType(FrequencyChart));
      expect(widget.color, testColor);
    });

    testWidgets('renders with partial weekday data (missing days)', (tester) async {
      const partialData = {
        1: 0.9, // Only Mon and Wed provided
        3: 0.6,
      };
      await tester.pumpWidget(wrap(
        const FrequencyChart(
          frequencyByDay: partialData,
          color: Color(0xFF4E55E0),
        ),
      ));
      await tester.pump();
      expect(find.byType(BarChart), findsOneWidget);
    });
  });
}
