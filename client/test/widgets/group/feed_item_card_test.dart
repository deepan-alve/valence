import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';
import 'package:valence/widgets/group/feed_item_card.dart';

Widget wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

final _copyOff = PersonalityCopy(personalityOn: false);
final _copyOn = PersonalityCopy(personalityOn: true);
final _now = DateTime(2026, 3, 30, 12, 0, 0);

FeedItem _item({
  required FeedItemType type,
  String sender = 'Alice',
  String senderId = 'u1',
  String? receiver,
  String? receiverId,
  String? habitName,
  String? verificationSource,
  String? message,
  DateTime? timestamp,
}) {
  return FeedItem(
    id: 'test_${type.name}',
    type: type,
    senderName: sender,
    senderId: senderId,
    receiverName: receiver,
    receiverId: receiverId,
    timestamp: timestamp ?? _now.subtract(const Duration(minutes: 5)),
    habitName: habitName,
    verificationSource: verificationSource,
    message: message,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('FeedItemCard — completion type', () {
    testWidgets('renders sender name in message', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.completion,
            sender: 'Nitil',
            habitName: 'LeetCode',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      // personality off: clean message format
      expect(find.textContaining('Nitil'), findsWidgets);
    });

    testWidgets('shows verification badge when plugin is present', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.completion,
            sender: 'Nitil',
            habitName: 'LeetCode',
            verificationSource: 'LeetCode',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Verified via'), findsOneWidget);
    });

    testWidgets('no verification badge when no plugin', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.completion,
            sender: 'Alice',
            habitName: 'Read',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Verified via'), findsNothing);
    });

    testWidgets('calls onKudos when kudos button tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.completion,
            sender: 'Nitil',
            habitName: 'Exercise',
          ),
          copy: _copyOff,
          onKudos: () => count++,
        ),
      ));
      await tester.pump();
      await tester.tap(find.textContaining('Kudos'));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets('no kudos button when onKudos is null', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.completion,
            sender: 'Alice',
            habitName: 'Read',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Kudos'), findsNothing);
    });
  });

  group('FeedItemCard — miss type', () {
    testWidgets('renders supportive framing (personality off)', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.miss,
            sender: 'Ravi',
            habitName: 'Meditate',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Ravi'), findsWidgets);
      expect(find.textContaining('Meditate'), findsWidgets);
    });

    testWidgets('miss message includes supportive tone (personality on)', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.miss,
            sender: 'Ravi',
            habitName: 'Meditate',
          ),
          copy: _copyOn,
        ),
      ));
      await tester.pump();
      // Personality-on messages always mention the sender name
      expect(find.textContaining('Ravi'), findsWidgets);
    });
  });

  group('FeedItemCard — nudge type', () {
    testWidgets('renders nudge feed message', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.nudge,
            sender: 'Diana',
            receiver: 'Ravi',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Diana'), findsWidgets);
      expect(find.textContaining('Ravi'), findsWidgets);
    });

    testWidgets('does NOT show a private message field', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.nudge,
            sender: 'Diana',
            receiver: 'Ravi',
            message: 'private LLM message',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      // The private message must not appear in the feed
      expect(find.textContaining('private LLM message'), findsNothing);
    });
  });

  group('FeedItemCard — kudos type', () {
    testWidgets('renders kudos message with sender and receiver', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.kudos,
            sender: 'Ava',
            receiver: 'Nitil',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Ava'), findsWidgets);
      expect(find.textContaining('Nitil'), findsWidgets);
    });
  });

  group('FeedItemCard — chainLink type', () {
    testWidgets('renders gold chain message', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.chainLink,
            sender: 'System',
            message: 'gold',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Gold'), findsWidgets);
    });

    testWidgets('renders broken chain message', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.chainLink,
            sender: 'System',
            message: 'broken',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('broken'), findsWidgets);
    });

    testWidgets('renders silver chain message', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.chainLink,
            sender: 'System',
            message: 'silver',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Silver'), findsWidgets);
    });
  });

  group('FeedItemCard — milestone type', () {
    testWidgets('renders milestone message with habit and stage', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.milestone,
            sender: 'Ava',
            habitName: 'Read',
            message: 'Foundation',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Ava'), findsWidgets);
      expect(find.textContaining('Read'), findsWidgets);
    });
  });

  group('FeedItemCard — streakFreeze type', () {
    testWidgets('renders streak freeze message', (tester) async {
      await tester.pumpWidget(wrap(
        FeedItemCard(
          item: _item(
            type: FeedItemType.streakFreeze,
            sender: 'Diana',
          ),
          copy: _copyOff,
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Diana'), findsWidgets);
    });
  });

  group('FeedItemCard — timestamp', () {
    testWidgets('shows relative time from timeAgo', (tester) async {
      // 5 minutes ago → "5min"
      final item = _item(
        type: FeedItemType.completion,
        habitName: 'Read',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      await tester.pumpWidget(wrap(
        FeedItemCard(item: item, copy: _copyOff),
      ));
      await tester.pump();
      expect(find.textContaining('min'), findsOneWidget);
    });
  });

  group('FeedItemCard — all 8 types render without error', () {
    for (final type in FeedItemType.values) {
      testWidgets('${type.name} renders without throwing', (tester) async {
        await tester.pumpWidget(wrap(
          FeedItemCard(
            item: _item(
              type: type,
              receiver: 'Bob',
              habitName: 'Exercise',
              message: type == FeedItemType.chainLink ? 'gold' : 'Foundation',
            ),
            copy: _copyOff,
          ),
        ));
        await tester.pump();
        expect(find.byType(FeedItemCard), findsOneWidget);
      });
    }
  });
}
