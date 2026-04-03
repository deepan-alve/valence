import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';
import 'package:valence/widgets/group/solo_empty_state.dart';

Widget _wrap(Widget child, GroupProvider provider) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: ChangeNotifierProvider<GroupProvider>.value(
      value: provider,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SoloEmptyState — basic rendering', () {
    testWidgets('renders without crashing', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      expect(find.byType(SoloEmptyState), findsOneWidget);
    });

    testWidgets('shows usersThree phosphor icon at 80px', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      // Two usersThree icons exist: the 80px hero icon and the 18px button icon.
      // Verify at least one at 80px size.
      final largeIcon = find.byWidgetPredicate(
        (w) => w is Icon && w.icon == PhosphorIconsRegular.usersThree && w.size == 80,
      );
      expect(largeIcon, findsOneWidget);
    });

    testWidgets('shows Create a Group button', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      expect(find.widgetWithText(ValenceButton, 'Create a Group'), findsOneWidget);
    });

    testWidgets('shows Join with Invite Link button', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      expect(find.widgetWithText(ValenceButton, 'Join with Invite Link'), findsOneWidget);
    });

    testWidgets('shows social proof retention text', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      expect(find.textContaining('3x'), findsOneWidget);
    });
  });

  group('SoloEmptyState — personality ON copy', () {
    testWidgets('title contains lonely or friends in personality-on mode', (tester) async {
      final provider = GroupProvider(soloMode: true);
      // personality is ON by default
      expect(provider.personalityOn, true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      // ON title: "Your habits are lonely. Give them friends."
      expect(find.textContaining('lonely'), findsOneWidget);
    });

    testWidgets('body mentions grinding or squad in personality-on mode', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      // ON body mentions grinding together
      expect(find.textContaining('grinding'), findsOneWidget);
    });
  });

  group('SoloEmptyState — personality OFF copy', () {
    testWidgets('title is "No group yet" when personality is OFF', (tester) async {
      final provider = GroupProvider(soloMode: true);
      provider.togglePersonality();
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      expect(find.text('No group yet'), findsOneWidget);
    });

    testWidgets('body is clean informational text when personality is OFF', (tester) async {
      final provider = GroupProvider(soloMode: true);
      provider.togglePersonality();
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      // OFF body: "Create or join a group of 2–6 friends to track habits together."
      expect(find.textContaining('friends'), findsOneWidget);
    });

    testWidgets('social proof is plain text when personality is OFF', (tester) async {
      final provider = GroupProvider(soloMode: true);
      provider.togglePersonality();
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      expect(
        find.text('Groups with 4+ members have 3x better retention.'),
        findsOneWidget,
      );
    });
  });

  group('SoloEmptyState — callbacks', () {
    testWidgets('Create a Group callback fires on tap', (tester) async {
      int createCount = 0;
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(
        _wrap(SoloEmptyState(onCreateGroup: () => createCount++), provider),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ValenceButton, 'Create a Group'));
      await tester.pump();
      expect(createCount, 1);
    });

    testWidgets('Join with Invite Link callback fires on tap', (tester) async {
      int joinCount = 0;
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(
        _wrap(SoloEmptyState(onJoinGroup: () => joinCount++), provider),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ValenceButton, 'Join with Invite Link'));
      await tester.pump();
      expect(joinCount, 1);
    });

    testWidgets('buttons render without callbacks (null onPressed)', (tester) async {
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(_wrap(const SoloEmptyState(), provider));
      await tester.pump();
      // Widgets still render — buttons just have null onPressed (disabled state)
      expect(find.widgetWithText(ValenceButton, 'Create a Group'), findsOneWidget);
      expect(find.widgetWithText(ValenceButton, 'Join with Invite Link'), findsOneWidget);
    });
  });

  group('SoloEmptyState — dark mode', () {
    testWidgets('renders without error in dark mode', (tester) async {
      final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: true);
      final provider = GroupProvider(soloMode: true);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [tokens]),
        home: ChangeNotifierProvider<GroupProvider>.value(
          value: provider,
          child: const Scaffold(body: SoloEmptyState()),
        ),
      ));
      await tester.pump();
      expect(find.byType(SoloEmptyState), findsOneWidget);
    });
  });
}
