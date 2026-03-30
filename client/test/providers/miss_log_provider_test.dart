// client/test/providers/miss_log_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/miss_log.dart';
import 'package:valence/providers/miss_log_provider.dart';

void main() {
  group('MissLogProvider', () {
    late MissLogProvider provider;

    setUp(() {
      provider = MissLogProvider();
    });

    test('initializes with empty logs and no recovery card', () {
      expect(provider.recentLogs, isEmpty);
      expect(provider.showRecoveryCard, isFalse);
      expect(provider.consecutiveMissDays, 0);
    });

    test('logMiss adds to recentLogs', () {
      provider.logMiss(
        habitId: 'h1',
        habitName: 'LeetCode',
        reason: MissReason.busy,
      );
      expect(provider.recentLogs.length, 1);
      expect(provider.recentLogs.first.reason, MissReason.busy);
    });

    test('logMiss with text stores reasonText', () {
      provider.logMiss(
        habitId: 'h1',
        habitName: 'LeetCode',
        reason: MissReason.other,
        reasonText: 'Power outage',
      );
      expect(provider.recentLogs.first.reasonText, 'Power outage');
    });

    test('dismissRecoveryCard hides the card', () {
      provider.setRecoveryCard(show: true, consecutiveDays: 1);
      expect(provider.showRecoveryCard, isTrue);
      provider.dismissRecoveryCard();
      expect(provider.showRecoveryCard, isFalse);
    });

    test('setRecoveryCard with 3+ days sets consecutiveMissDays', () {
      provider.setRecoveryCard(show: true, consecutiveDays: 3);
      expect(provider.consecutiveMissDays, 3);
    });

    test('hasMissedHabit returns true after logMiss for that habit', () {
      provider.logMiss(
          habitId: 'h1', habitName: 'Gym', reason: MissReason.sick);
      expect(provider.hasMissedHabit('h1'), isTrue);
      expect(provider.hasMissedHabit('h2'), isFalse);
    });
  });
}
