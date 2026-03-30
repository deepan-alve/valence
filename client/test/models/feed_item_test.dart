import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/feed_item.dart';

void main() {
  group('FeedItemType', () {
    test('all 8 values exist', () {
      expect(FeedItemType.values.length, 8);
      expect(FeedItemType.values, contains(FeedItemType.completion));
      expect(FeedItemType.values, contains(FeedItemType.miss));
      expect(FeedItemType.values, contains(FeedItemType.nudge));
      expect(FeedItemType.values, contains(FeedItemType.kudos));
      expect(FeedItemType.values, contains(FeedItemType.statusNorm));
      expect(FeedItemType.values, contains(FeedItemType.chainLink));
      expect(FeedItemType.values, contains(FeedItemType.milestone));
      expect(FeedItemType.values, contains(FeedItemType.streakFreeze));
    });
  });

  group('FeedItem', () {
    test('constructs a completion feed item', () {
      final item = FeedItem(
        id: 'f1',
        type: FeedItemType.completion,
        senderName: 'Nitil',
        senderId: 'u1',
        timestamp: DateTime(2026, 3, 30, 14, 30),
        habitName: 'LeetCode',
        verificationSource: 'LeetCode',
      );

      expect(item.type, FeedItemType.completion);
      expect(item.senderName, 'Nitil');
      expect(item.habitName, 'LeetCode');
      expect(item.verificationSource, 'LeetCode');
    });

    test('constructs a nudge feed item with receiver', () {
      final item = FeedItem(
        id: 'f2',
        type: FeedItemType.nudge,
        senderName: 'Diana',
        senderId: 'u2',
        receiverName: 'Ava',
        receiverId: 'u3',
        timestamp: DateTime(2026, 3, 30, 15, 0),
      );

      expect(item.type, FeedItemType.nudge);
      expect(item.senderName, 'Diana');
      expect(item.receiverName, 'Ava');
    });

    test('constructs a chain link feed item with message', () {
      final item = FeedItem(
        id: 'f3',
        type: FeedItemType.chainLink,
        senderName: 'System',
        senderId: 'system',
        timestamp: DateTime(2026, 3, 30, 23, 0),
        message: 'Gold! Everyone showed up.',
      );

      expect(item.type, FeedItemType.chainLink);
      expect(item.message, contains('Gold'));
    });

    test('constructs a miss item (supportive, never punitive)', () {
      final item = FeedItem(
        id: 'f4',
        type: FeedItemType.miss,
        senderName: 'Ava',
        senderId: 'u3',
        timestamp: DateTime(2026, 3, 29, 22, 0),
        habitName: 'Exercise',
      );

      expect(item.type, FeedItemType.miss);
      expect(item.habitName, 'Exercise');
    });

    test('optional fields default to null', () {
      final item = FeedItem(
        id: 'f0',
        type: FeedItemType.streakFreeze,
        senderName: 'Ravi',
        senderId: 'u4',
        timestamp: DateTime.now(),
      );

      expect(item.receiverName, isNull);
      expect(item.receiverId, isNull);
      expect(item.habitName, isNull);
      expect(item.verificationSource, isNull);
      expect(item.message, isNull);
    });

    test('timeAgo returns "now" for very recent items', () {
      final item = FeedItem(
        id: 'f_now',
        type: FeedItemType.kudos,
        senderName: 'Nitil',
        senderId: 'u1',
        timestamp: DateTime.now(),
      );

      expect(item.timeAgo, 'now');
    });

    test('timeAgo returns a relative time string with min', () {
      final now = DateTime.now();
      final item = FeedItem(
        id: 'f5',
        type: FeedItemType.kudos,
        senderName: 'Nitil',
        senderId: 'u1',
        receiverName: 'Diana',
        receiverId: 'u2',
        timestamp: now.subtract(const Duration(minutes: 5)),
      );

      expect(item.timeAgo, contains('min'));
    });

    test('timeAgo handles hours', () {
      final now = DateTime.now();
      final item = FeedItem(
        id: 'f6',
        type: FeedItemType.completion,
        senderName: 'Ravi',
        senderId: 'u4',
        timestamp: now.subtract(const Duration(hours: 3)),
        habitName: 'Read',
      );

      expect(item.timeAgo, contains('h'));
    });

    test('timeAgo handles days', () {
      final now = DateTime.now();
      final item = FeedItem(
        id: 'f7',
        type: FeedItemType.completion,
        senderName: 'Zara',
        senderId: 'u5',
        timestamp: now.subtract(const Duration(days: 2)),
        habitName: 'Journal',
      );

      expect(item.timeAgo, contains('d'));
    });
  });
}
