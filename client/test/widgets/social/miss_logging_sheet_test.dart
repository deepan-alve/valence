// client/test/widgets/social/miss_logging_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/miss_log_provider.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/social/miss_logging_sheet.dart';

Widget wrap(Widget child) {
  final tokens =
      ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return ChangeNotifierProvider(
    create: (_) => MissLogProvider(),
    child: MaterialApp(
      theme: ThemeData.light().copyWith(extensions: [tokens]),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows all 5 reason chips', (tester) async {
    await tester.pumpWidget(wrap(
      MissLoggingSheet(
        habitId: 'h1',
        habitName: 'LeetCode',
        onDone: () {},
      ),
    ));
    await tester.pump();

    expect(find.text('Sick'), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
    expect(find.text('Forgot'), findsOneWidget);
    expect(find.text('No Energy'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('shows supportive copy text', (tester) async {
    await tester.pumpWidget(wrap(
      MissLoggingSheet(
        habitId: 'h1',
        habitName: 'Gym',
        onDone: () {},
      ),
    ));
    await tester.pump();

    expect(
      find.text('No judgment. This helps us help you.'),
      findsOneWidget,
    );
  });

  testWidgets('shows Log button', (tester) async {
    await tester.pumpWidget(wrap(
      MissLoggingSheet(
        habitId: 'h1',
        habitName: 'Reading',
        onDone: () {},
      ),
    ));
    await tester.pump();

    expect(find.text('Log'), findsOneWidget);
  });

  testWidgets('shows Skip text button', (tester) async {
    await tester.pumpWidget(wrap(
      MissLoggingSheet(
        habitId: 'h1',
        habitName: 'Meditation',
        onDone: () {},
      ),
    ));
    await tester.pump();

    expect(find.text('Skip'), findsOneWidget);
  });
}
