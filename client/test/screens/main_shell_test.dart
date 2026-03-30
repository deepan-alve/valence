import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/valence_typography.dart';
import 'package:valence/screens/main_shell.dart';

// Minimal typography that avoids GoogleFonts network calls in tests.
ValenceTypography _makeTypography(Color color) {
  final base = TextStyle(color: color, fontSize: 16);
  return ValenceTypography(
    display: base,
    h1: base,
    h2: base,
    h3: base,
    bodyLarge: base,
    body: base,
    caption: base,
    overline: base,
    numbersDisplay: base,
    numbersBody: base,
  );
}

Widget wrapShell() {
  final tokens = ValenceTokens(
    colors: daybreakColors,
    typography: _makeTypography(daybreakColors.textPrimary),
    isDark: false,
  );
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: const MainShell(),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders 5 bottom navigation tabs', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    // The BottomNavigationBar always renders all 5 items.
    // "Home" appears twice (nav label + screen body), others at least once.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Group'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Shop'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    // Confirm there are exactly 5 navigation bar items.
    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.items.length, 5);
  });

  testWidgets('shows Home tab content by default', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    // HomeScreen renders "Home" as body text — find the one inside the body
    // (not the nav label). IndexedStack keeps all children, so we look for
    // the BottomNavigationBar to confirm initial index.
    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.currentIndex, 0);
  });

  testWidgets('tapping Group tab switches to index 1', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    // Tap the Group tab item in the bottom nav bar.
    await tester.tap(find.text('Group'));
    await tester.pump();

    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.currentIndex, 1);
  });

  testWidgets('tapping Progress tab switches to index 2', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    await tester.tap(find.text('Progress'));
    await tester.pump();

    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.currentIndex, 2);
  });

  testWidgets('tapping Shop tab switches to index 3', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    await tester.tap(find.text('Shop'));
    await tester.pump();

    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.currentIndex, 3);
  });

  testWidgets('tapping Profile tab switches to index 4', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    await tester.tap(find.text('Profile'));
    await tester.pump();

    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.currentIndex, 4);
  });

  testWidgets('IndexedStack preserves all 5 children', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack.children.length, 5);
  });

  testWidgets('unselected labels are hidden', (tester) async {
    await tester.pumpWidget(wrapShell());
    await tester.pump();

    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.showUnselectedLabels, isFalse);
  });
}
