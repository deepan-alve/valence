// Basic smoke test for the ValenceApp root widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ValenceApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ValenceApp());
    // Just verify it builds — SplashScreen will show while auth initializes.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
