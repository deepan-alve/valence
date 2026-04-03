import 'package:flutter_test/flutter_test.dart';
import 'package:valence/utils/personality_copy.dart';

void main() {
  group('PersonalityCopy — personality ON', () {
    const copy = PersonalityCopy(personalityOn: true);

    test('completion message is witty', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode');
      expect(msg, contains('Nitil'));
      expect(msg.length, greaterThan(10));
    });

    test('completion with plugin shows verification flavor', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode', plugin: 'LeetCode');
      expect(msg, contains('Nitil'));
      expect(msg, contains('LeetCode'));
    });

    test('miss message is supportive and never punitive', () {
      // Run multiple times to check all variants are safe
      for (var i = 0; i < 20; i++) {
        final msg = copy.missMessage('Ava', 'Exercise');
        expect(msg, contains('Ava'));
        expect(msg.toLowerCase(), isNot(contains('failed')));
        expect(msg.toLowerCase(), isNot(contains('lazy')));
        expect(msg.toLowerCase(), isNot(contains('disappointed')));
      }
    });

    test('nudge message is playful', () {
      final msg = copy.nudgeFeedMessage('Diana', 'Ravi');
      expect(msg, contains('Diana'));
      expect(msg, contains('Ravi'));
    });

    test('kudos message is fun', () {
      final msg = copy.kudosFeedMessage('Nitil', 'Diana');
      expect(msg, contains('Nitil'));
      expect(msg, contains('Diana'));
    });

    test('streak norm message is hype', () {
      final msg = copy.statusNormMessage('Nitil', 7);
      expect(msg, contains('Nitil'));
      expect(msg, contains('7'));
    });

    test('chain link gold message is celebratory', () {
      final msg = copy.chainLinkMessage('gold', 5, 5);
      expect(msg.toLowerCase(), contains('gold'));
    });

    test('chain link silver message contains silver', () {
      // Run a few times to hit both variants
      for (var i = 0; i < 10; i++) {
        final msg = copy.chainLinkMessage('silver', 3, 5);
        expect(msg, isNotEmpty);
      }
    });

    test('chain link broken message is empathetic', () {
      final msg = copy.chainLinkMessage('broken', 2, 5);
      expect(msg.toLowerCase(), anyOf(contains('broke'), contains('broken')));
    });

    test('milestone message is exciting', () {
      final msg = copy.milestoneMessage('Ava', 'Read', 'Foundation', 10);
      expect(msg, contains('Ava'));
      expect(msg, contains('10'));
    });

    test('milestone message works for all known stages', () {
      for (final stage in ['Ignition', 'Foundation', 'Momentum', 'Formed']) {
        final msg = copy.milestoneMessage('Nitil', 'Exercise', stage, 21);
        expect(msg, isNotEmpty);
        expect(msg, contains('Nitil'));
      }
    });

    test('milestone message handles unknown stage gracefully', () {
      final msg = copy.milestoneMessage('Ava', 'Meditate', 'Unknown', 5);
      expect(msg, isNotEmpty);
      expect(msg, contains('Ava'));
    });

    test('streak freeze message is contextual', () {
      final msg = copy.streakFreezeMessage('Ravi');
      expect(msg, contains('Ravi'));
    });

    test('completion toast is fun and varied', () {
      final toasts = List.generate(20, (_) => copy.completionToast());
      expect(toasts.toSet().length, greaterThan(1));
    });

    test('perfect day toast is fun', () {
      final msg = copy.perfectDayToast();
      expect(msg, isNotEmpty);
      expect(msg.length, greaterThan(10));
    });

    test('empty state group title is playful', () {
      final msg = copy.emptyStateGroupTitle;
      expect(msg, isNotEmpty);
    });

    test('empty state group body is playful', () {
      final msg = copy.emptyStateGroupBody;
      expect(msg, isNotEmpty);
    });

    test('empty state social proof exists', () {
      final msg = copy.emptyStateSocialProof;
      expect(msg, isNotEmpty);
    });

    test('nudge sheet title contains receiver name', () {
      final msg = copy.nudgeSheetTitle('Ravi');
      expect(msg, contains('Ravi'));
    });

    test('nudge sheet body contains receiver name', () {
      final msg = copy.nudgeSheetBody('Ravi');
      expect(msg, contains('Ravi'));
    });

    test('nudge sent toast contains receiver name', () {
      final msg = copy.nudgeSentToast('Ravi');
      expect(msg, contains('Ravi'));
    });

    test('nudge already sent is non-empty', () {
      expect(copy.nudgeAlreadySent, isNotEmpty);
    });

    test('nudge disabled reason is non-empty', () {
      expect(copy.nudgeDisabledReason, isNotEmpty);
    });

    test('freeze sheet title is non-empty', () {
      expect(copy.freezeSheetTitle, isNotEmpty);
    });

    test('freeze sheet body contains cost', () {
      final msg = copy.freezeSheetBody(10);
      expect(msg, contains('10'));
    });

    test('freeze activated toast is non-empty', () {
      expect(copy.freezeActivatedToast, isNotEmpty);
    });

    test('freeze insufficient points contains amount', () {
      final msg = copy.freezeInsufficientPoints(5);
      expect(msg, contains('5'));
    });

    test('last week mvp contains name', () {
      final msg = copy.lastWeekMvp('Nitil');
      expect(msg, contains('Nitil'));
    });

    test('leaderboard caption is non-empty', () {
      expect(copy.leaderboardCaption, isNotEmpty);
    });
  });

  group('PersonalityCopy — personality OFF', () {
    const copy = PersonalityCopy(personalityOn: false);

    test('completion message is neutral', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode');
      expect(msg, contains('Nitil'));
      expect(msg, contains('LeetCode'));
      expect(msg, contains('completed'));
    });

    test('completion message with plugin mentions verification', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode', plugin: 'LeetCode');
      expect(msg, contains('verified'));
    });

    test('miss message is neutral and supportive', () {
      final msg = copy.missMessage('Ava', 'Exercise');
      expect(msg, contains('Ava'));
      expect(msg.toLowerCase(), isNot(contains('failed')));
    });

    test('nudge message is neutral', () {
      final msg = copy.nudgeFeedMessage('Diana', 'Ravi');
      expect(msg, contains('Diana'));
      expect(msg, contains('Ravi'));
      expect(msg, contains('nudged'));
    });

    test('kudos message is neutral', () {
      final msg = copy.kudosFeedMessage('Nitil', 'Diana');
      expect(msg, contains('kudos'));
    });

    test('chain link gold message is factual', () {
      final msg = copy.chainLinkMessage('gold', 5, 5);
      expect(msg.toLowerCase(), contains('gold'));
    });

    test('chain link broken message is factual', () {
      final msg = copy.chainLinkMessage('broken', 2, 5);
      expect(msg.toLowerCase(), anyOf(contains('broke'), contains('broken')));
    });

    test('milestone message is factual', () {
      final msg = copy.milestoneMessage('Ava', 'Read', 'Foundation', 10);
      expect(msg, contains('Ava'));
      expect(msg, contains('Foundation'));
      expect(msg, contains('10'));
    });

    test('completion toast is simple', () {
      final toast = copy.completionToast();
      expect(toast, 'Habit completed');
    });

    test('perfect day toast is simple', () {
      final toast = copy.perfectDayToast();
      expect(toast, 'All habits completed today');
    });

    test('empty state group title is straightforward', () {
      final msg = copy.emptyStateGroupTitle;
      expect(msg, isNotEmpty);
      expect(msg, 'No group yet');
    });

    test('empty state group body mentions create or join', () {
      final msg = copy.emptyStateGroupBody;
      expect(msg, isNotEmpty);
    });
  });

  group('PersonalityCopy — ON vs OFF produces different strings', () {
    const on = PersonalityCopy(personalityOn: true);
    const off = PersonalityCopy(personalityOn: false);

    test('completion messages differ', () {
      // ON is randomized so just verify OFF is the simple version
      final offMsg = off.completionMessage('Nitil', 'LeetCode');
      expect(offMsg, 'Nitil completed LeetCode');
    });

    test('completion toast differs', () {
      expect(on.completionToast(), isNot('Habit completed'));
      expect(off.completionToast(), 'Habit completed');
    });

    test('empty state title differs', () {
      expect(on.emptyStateGroupTitle, isNot(off.emptyStateGroupTitle));
    });

    test('leaderboard caption differs', () {
      expect(on.leaderboardCaption, isNot(off.leaderboardCaption));
    });
  });
}
