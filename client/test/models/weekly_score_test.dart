import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/weekly_score.dart';

void main() {
  group('ContributionBreakdown', () {
    test('totalPoints sums all categories', () {
      const breakdown = ContributionBreakdown(
        habitsCompleted: 45,
        groupStreakContributions: 15,
        kudosReceived: 8,
        perfectDays: 10,
      );

      expect(breakdown.totalPoints, 78);
    });

    test('totalPoints is zero when all categories are zero', () {
      const breakdown = ContributionBreakdown(
        habitsCompleted: 0,
        groupStreakContributions: 0,
        kudosReceived: 0,
        perfectDays: 0,
      );

      expect(breakdown.totalPoints, 0);
    });

    test('totalPoints handles partial categories', () {
      const breakdown = ContributionBreakdown(
        habitsCompleted: 20,
        groupStreakContributions: 0,
        kudosReceived: 3,
        perfectDays: 0,
      );

      expect(breakdown.totalPoints, 23);
    });
  });

  group('WeeklyScore', () {
    test('constructs with required fields', () {
      const score = WeeklyScore(
        rank: 1,
        memberId: 'u1',
        memberName: 'Nitil',
        consistencyPercent: 95,
        breakdown: ContributionBreakdown(
          habitsCompleted: 45,
          groupStreakContributions: 15,
          kudosReceived: 8,
          perfectDays: 10,
        ),
      );

      expect(score.rank, 1);
      expect(score.memberName, 'Nitil');
      expect(score.consistencyPercent, 95);
      expect(score.breakdown.totalPoints, 78);
    });

    test('consistencyLabel returns percentage string', () {
      const score = WeeklyScore(
        rank: 2,
        memberId: 'u2',
        memberName: 'Diana',
        consistencyPercent: 87,
        breakdown: ContributionBreakdown(
          habitsCompleted: 30,
          groupStreakContributions: 10,
          kudosReceived: 5,
          perfectDays: 5,
        ),
      );

      expect(score.consistencyLabel, '87%');
    });

    test('isTied defaults to false', () {
      const score = WeeklyScore(
        rank: 3,
        memberId: 'u3',
        memberName: 'Ravi',
        consistencyPercent: 60,
        breakdown: ContributionBreakdown(
          habitsCompleted: 20,
          groupStreakContributions: 5,
          kudosReceived: 1,
          perfectDays: 0,
        ),
      );

      expect(score.isTied, isFalse);
    });

    test('isTied flag works', () {
      const score = WeeklyScore(
        rank: 1,
        memberId: 'u3',
        memberName: 'Ava',
        consistencyPercent: 95,
        isTied: true,
        breakdown: ContributionBreakdown(
          habitsCompleted: 42,
          groupStreakContributions: 15,
          kudosReceived: 10,
          perfectDays: 10,
        ),
      );

      expect(score.isTied, isTrue);
    });

    test('consistencyLabel handles 100%', () {
      const score = WeeklyScore(
        rank: 1,
        memberId: 'u1',
        memberName: 'Perfect',
        consistencyPercent: 100,
        breakdown: ContributionBreakdown(
          habitsCompleted: 50,
          groupStreakContributions: 20,
          kudosReceived: 10,
          perfectDays: 15,
        ),
      );

      expect(score.consistencyLabel, '100%');
    });
  });
}
