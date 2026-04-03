import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/providers/group_provider.dart';

void main() {
  group('GroupProvider', () {
    late GroupProvider provider;

    setUp(() {
      provider = GroupProvider();
    });

    test('initializes with a group', () {
      expect(provider.hasGroup, isTrue);
      expect(provider.groupName, isNotEmpty);
    });

    test('has mock members', () {
      expect(provider.members.length, greaterThanOrEqualTo(4));
      expect(
        provider.members.any((m) => m.isCurrentUser),
        isTrue,
      );
    });

    test('members list is unmodifiable', () {
      expect(
        () => (provider.members as List<GroupMember>).add(
          const GroupMember(
            id: 'x',
            name: 'X',
            avatarUrl: null,
            habitsCompleted: 0,
            habitsTotal: 0,
            status: MemberStatus.inactive,
            isCurrentUser: false,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('has mock feed items', () {
      expect(provider.feedItems.length, greaterThanOrEqualTo(8));
      // Should contain variety of types
      final types = provider.feedItems.map((f) => f.type).toSet();
      expect(types.length, greaterThanOrEqualTo(4));
    });

    test('feed items are in reverse chronological order', () {
      for (var i = 0; i < provider.feedItems.length - 1; i++) {
        expect(
          provider.feedItems[i].timestamp.isAfter(
                provider.feedItems[i + 1].timestamp,
              ) ||
              provider.feedItems[i].timestamp.isAtSameMomentAs(
                provider.feedItems[i + 1].timestamp,
              ),
          isTrue,
          reason: 'Feed item at index $i is not after item at index ${i + 1}',
        );
      }
    });

    test('feed contains all 8 event types across mock data', () {
      final types = provider.feedItems.map((f) => f.type).toSet();
      expect(types, contains(FeedItemType.completion));
      expect(types, contains(FeedItemType.kudos));
      expect(types, contains(FeedItemType.nudge));
      expect(types, contains(FeedItemType.miss));
      expect(types, contains(FeedItemType.chainLink));
      expect(types, contains(FeedItemType.milestone));
      expect(types, contains(FeedItemType.statusNorm));
      expect(types, contains(FeedItemType.streakFreeze));
    });

    test('has mock leaderboard data', () {
      expect(provider.weeklyScores.length, greaterThanOrEqualTo(4));
      // Should be sorted by rank
      for (var i = 0; i < provider.weeklyScores.length - 1; i++) {
        expect(
          provider.weeklyScores[i].rank,
          lessThanOrEqualTo(provider.weeklyScores[i + 1].rank),
        );
      }
    });

    test('leaderboard has exactly 5 entries', () {
      expect(provider.weeklyScores.length, 5);
    });

    test('personality is ON by default', () {
      expect(provider.personalityOn, isTrue);
    });

    test('toggling personality flips the flag', () {
      provider.togglePersonality();
      expect(provider.personalityOn, isFalse);
      provider.togglePersonality();
      expect(provider.personalityOn, isTrue);
    });

    test('toggling personality notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.togglePersonality();
      expect(provider.personalityOn, isFalse);
      expect(notified, isTrue);
    });

    test('currentUserCompleted reflects mock data', () {
      // Diana has 4/6 — should be false
      expect(provider.currentUserCompleted, isFalse);
    });

    test('canNudge is false when user has not completed all habits', () {
      expect(provider.canNudge, isFalse);
    });

    test('sendNudge does nothing when user has not completed habits', () {
      final feedCountBefore = provider.feedItems.length;
      provider.sendNudge('u4'); // Ravi
      expect(provider.feedItems.length, feedCountBefore);
    });

    test('hasNudgedToday returns false before any nudge', () {
      expect(provider.hasNudgedToday('u4'), isFalse);
    });

    test('sendKudos adds a kudos feed item to the front', () {
      final feedCountBefore = provider.feedItems.length;
      provider.sendKudos('u2'); // Nitil
      expect(provider.feedItems.length, feedCountBefore + 1);
      expect(provider.feedItems.first.type, FeedItemType.kudos);
      expect(provider.feedItems.first.receiverName, 'Nitil');
    });

    test('sendKudos notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.sendKudos('u2');
      expect(notified, isTrue);
    });

    test('streak freeze reduces points', () {
      final pointsBefore = provider.consistencyPoints;
      provider.useStreakFreeze();
      expect(provider.consistencyPoints, lessThan(pointsBefore));
      expect(provider.freezeActiveToday, isTrue);
    });

    test('freeze cost is deducted correctly', () {
      final pointsBefore = provider.consistencyPoints;
      provider.useStreakFreeze();
      expect(provider.consistencyPoints, pointsBefore - provider.freezeCost);
    });

    test('streak freeze adds a feed item', () {
      final feedCountBefore = provider.feedItems.length;
      provider.useStreakFreeze();
      expect(provider.feedItems.length, feedCountBefore + 1);
      expect(provider.feedItems.first.type, FeedItemType.streakFreeze);
    });

    test('cannot use streak freeze twice in one day', () {
      provider.useStreakFreeze();
      final pointsAfterFirst = provider.consistencyPoints;
      provider.useStreakFreeze(); // no-op
      expect(provider.consistencyPoints, pointsAfterFirst);
    });

    test('groupTier returns correct tier name', () {
      expect(provider.groupTier, isNotEmpty);
      expect(provider.groupTier, 'ember');
    });

    test('groupStreak returns a positive number', () {
      expect(provider.groupStreak, isNonNegative);
      expect(provider.groupStreak, 14);
    });

    test('soloMode provider has no group', () {
      final solo = GroupProvider(soloMode: true);
      expect(solo.hasGroup, isFalse);
      expect(solo.members, isEmpty);
      expect(solo.feedItems, isEmpty);
    });

    test('leaderboardPeriod defaults to week', () {
      expect(provider.leaderboardPeriod, LeaderboardPeriod.week);
    });

    test('toggling leaderboard period notifies', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setLeaderboardPeriod(LeaderboardPeriod.month);
      expect(provider.leaderboardPeriod, LeaderboardPeriod.month);
      expect(notified, isTrue);
    });

    test('copy getter returns PersonalityCopy with correct state', () {
      expect(provider.copy.personalityOn, isTrue);
      provider.togglePersonality();
      expect(provider.copy.personalityOn, isFalse);
    });

    test('groupStreakData has the right group name', () {
      expect(provider.groupStreakData.groupName, 'Build Squad');
    });

    test('groupStreakData has 7 chain links', () {
      expect(provider.groupStreakData.last7Days.length, 7);
    });
  });
}
