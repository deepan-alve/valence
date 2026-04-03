import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_card.dart';

Widget wrap(Widget child, {bool isDark = false}) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: isDark);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders child content', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceCard(
        child: Text('Card Content'),
      ),
    ));
    await tester.pump();
    expect(find.text('Card Content'), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    int tapCount = 0;
    await tester.pumpWidget(wrap(
      ValenceCard(
        onTap: () => tapCount++,
        child: const Text('Tappable Card'),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('Tappable Card'));
    await tester.pump();
    expect(tapCount, 1);
  });

  testWidgets('calls onLongPress when long-pressed', (tester) async {
    int longPressCount = 0;
    await tester.pumpWidget(wrap(
      ValenceCard(
        onLongPress: () => longPressCount++,
        child: const Text('Long Press Card'),
      ),
    ));
    await tester.pump();
    await tester.longPress(find.text('Long Press Card'));
    await tester.pump();
    expect(longPressCount, 1);
  });

  testWidgets('renders with accent color in light mode', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceCard(
        accentColor: Colors.purple,
        child: Text('Accent Card'),
      ),
      isDark: false,
    ));
    await tester.pump();
    expect(find.text('Accent Card'), findsOneWidget);
  });

  testWidgets('renders with accent color in dark mode', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceCard(
        accentColor: Colors.purple,
        child: Text('Dark Accent Card'),
      ),
      isDark: true,
    ));
    await tester.pump();
    expect(find.text('Dark Accent Card'), findsOneWidget);
  });

  testWidgets('renders without onTap (no GestureDetector)', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceCard(
        child: Text('No Tap'),
      ),
    ));
    await tester.pump();
    // With no onTap/onLongPress, there should be no GestureDetector
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('renders with custom padding', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceCard(
        padding: EdgeInsets.all(24),
        child: Text('Custom Padding'),
      ),
    ));
    await tester.pump();
    expect(find.text('Custom Padding'), findsOneWidget);
  });
}
