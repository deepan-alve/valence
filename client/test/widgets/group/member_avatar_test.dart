import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/group/member_avatar.dart';

Widget wrap(Widget child, {bool isDark = false}) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: isDark);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

GroupMember _member({
  String id = 'u1',
  String name = 'Alice',
  int done = 3,
  int total = 5,
  MemberStatus status = MemberStatus.partial,
  bool isCurrentUser = false,
}) {
  return GroupMember(
    id: id,
    name: name,
    avatarUrl: null,
    habitsCompleted: done,
    habitsTotal: total,
    status: status,
    isCurrentUser: isCurrentUser,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MemberAvatar — rendering', () {
    testWidgets('shows member name below avatar', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(member: _member(name: 'Diana')),
      ));
      await tester.pump();
      expect(find.textContaining('Diana'), findsOneWidget);
    });

    testWidgets('shows initials in avatar circle', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(member: _member(name: 'Nitil')),
      ));
      await tester.pump();
      expect(find.text('NI'), findsOneWidget);
    });

    testWidgets('labels current user with (you)', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(member: _member(name: 'Diana', isCurrentUser: true)),
      ));
      await tester.pump();
      expect(find.textContaining('you'), findsOneWidget);
    });
  });

  group('MemberAvatar — status badges', () {
    testWidgets('allDone shows check icon badge', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 5, total: 5, status: MemberStatus.allDone),
        ),
      ));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('partial shows fraction badge text', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 3, total: 5, status: MemberStatus.partial),
        ),
      ));
      await tester.pump();
      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('notStarted shows dash badge', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 0, total: 5, status: MemberStatus.notStarted),
        ),
      ));
      await tester.pump();
      expect(find.text('–'), findsOneWidget);
    });

    testWidgets('inactive shows sleep emoji badge', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 0, total: 4, status: MemberStatus.inactive),
        ),
      ));
      await tester.pump();
      expect(find.textContaining('💤'), findsOneWidget);
    });
  });

  group('MemberAvatar — action overlays', () {
    testWidgets('nudge callback fires when tapped (incomplete member)', (tester) async {
      int nudgeCount = 0;
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 2, total: 5, status: MemberStatus.partial),
          onNudge: () => nudgeCount++,
          showActions: true,
        ),
      ));
      await tester.pump();
      // Find and tap the action button
      final actionButtons = find.byType(GestureDetector);
      // At least one GestureDetector for the action icon
      expect(actionButtons, findsWidgets);
      // Tap the first GestureDetector (the action button at top-right)
      await tester.tap(actionButtons.first);
      await tester.pump();
      expect(nudgeCount, 1);
    });

    testWidgets('kudos callback fires when tapped (complete member)', (tester) async {
      int kudosCount = 0;
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 5, total: 5, status: MemberStatus.allDone),
          onKudos: () => kudosCount++,
          showActions: true,
        ),
      ));
      await tester.pump();
      final actionButtons = find.byType(GestureDetector);
      expect(actionButtons, findsWidgets);
      await tester.tap(actionButtons.first);
      await tester.pump();
      expect(kudosCount, 1);
    });

    testWidgets('no action overlay shown for current user', (tester) async {
      // Current user has no nudge/kudos action — only one Semantics container
      // for the whole widget. We verify no _ActionButton is rendered by
      // checking action GestureDetectors.
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(isCurrentUser: true, done: 3, total: 5, status: MemberStatus.partial),
          onNudge: () {},
          onKudos: () {},
          showActions: true,
        ),
      ));
      await tester.pump();
      // No action GestureDetector for current user
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('actions hidden when showActions is false', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(
          member: _member(done: 2, total: 5, status: MemberStatus.partial),
          onNudge: () {},
          showActions: false,
        ),
      ));
      await tester.pump();
      expect(find.byType(GestureDetector), findsNothing);
    });
  });

  group('MemberAvatar — dark mode', () {
    testWidgets('renders without error in dark mode', (tester) async {
      await tester.pumpWidget(wrap(
        MemberAvatar(member: _member()),
        isDark: true,
      ));
      await tester.pump();
      expect(find.byType(MemberAvatar), findsOneWidget);
    });
  });
}
