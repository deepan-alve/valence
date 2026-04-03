// client/test/widgets/social/recovery_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/social/recovery_card.dart';

Widget buildTestWidget(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('RecoveryCard', () {
    testWidgets('shows standard recovery copy for 1 missed day', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecoveryCard(consecutiveMissDays: 1, onDismiss: () {}, onLetSGo: () {}),
      ));
      expect(find.text("Yesterday didn't go as planned. That's okay."),
          findsOneWidget);
    });

    testWidgets('shows escalated copy for 3+ missed days', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecoveryCard(consecutiveMissDays: 3, onDismiss: () {}, onLetSGo: () {}),
      ));
      expect(
          find.textContaining('3 days'), findsOneWidget);
    });

    testWidgets('has dismiss button', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecoveryCard(consecutiveMissDays: 1, onDismiss: () {}, onLetSGo: () {}),
      ));
      expect(find.byTooltip('Dismiss'), findsOneWidget);
    });

    testWidgets("has Let's go button", (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RecoveryCard(consecutiveMissDays: 1, onDismiss: () {}, onLetSGo: () {}),
      ));
      expect(find.text("Let's go"), findsOneWidget);
    });
  });
}
