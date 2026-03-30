import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

Widget wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceButton(label: 'Hello World', onPressed: null),
    ));
    await tester.pump();
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    int tapCount = 0;
    await tester.pumpWidget(wrap(
      ValenceButton(label: 'Tap Me', onPressed: () => tapCount++),
    ));
    await tester.pump();
    await tester.tap(find.text('Tap Me'));
    await tester.pump();
    expect(tapCount, 1);
  });

  testWidgets('disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(wrap(
      const ValenceButton(label: 'Disabled', onPressed: null),
    ));
    await tester.pump();
    // ElevatedButton is disabled when onPressed is null
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('ghost variant renders without error', (tester) async {
    await tester.pumpWidget(wrap(
      ValenceButton(
        label: 'Ghost',
        variant: ValenceButtonVariant.ghost,
        onPressed: () {},
      ),
    ));
    await tester.pump();
    expect(find.text('Ghost'), findsOneWidget);
  });

  testWidgets('renders icon when provided', (tester) async {
    await tester.pumpWidget(wrap(
      ValenceButton(
        label: 'With Icon',
        icon: Icons.star,
        onPressed: () {},
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('With Icon'), findsOneWidget);
  });

  testWidgets('danger variant renders', (tester) async {
    await tester.pumpWidget(wrap(
      ValenceButton(
        label: 'Delete',
        variant: ValenceButtonVariant.danger,
        onPressed: () {},
      ),
    ));
    await tester.pump();
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('secondary variant renders', (tester) async {
    await tester.pumpWidget(wrap(
      ValenceButton(
        label: 'Secondary',
        variant: ValenceButtonVariant.secondary,
        onPressed: () {},
      ),
    ));
    await tester.pump();
    expect(find.text('Secondary'), findsOneWidget);
  });
}
