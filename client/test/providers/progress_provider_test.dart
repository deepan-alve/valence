import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/models/overview_stats.dart';
import 'package:valence/providers/progress_provider.dart';

void main() {
  group('ProgressProvider', () {
    late ProgressProvider provider;

    setUp(() {
      provider = ProgressProvider();
    });

    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------

    test('initializes with 6 habits matching HomeProvider mock set', () {
      expect(provider.habits.length, 6);
      final names = provider.habits.map((h) => h.name).toList();
      expect(names, containsAll(['LeetCode', 'Exercise', 'Read', 'Meditate', 'Duolingo', 'Journal']));
    });

    test('habitProgresses has one entry per habit', () {
      expect(provider.habitProgresses.length, provider.habits.length);
    });

    test('habitProgress ids match habit ids', () {
      for (int i = 0; i < provider.habits.length; i++) {
        expect(provider.habitProgresses[i].habitId, provider.habits[i].id);
      }
    });

    // -------------------------------------------------------------------------
    // selectedHabitIndex / selectHabit
    // -------------------------------------------------------------------------

    test('selectedHabitIndex defaults to 0', () {
      expect(provider.selectedHabitIndex, 0);
    });

    test('selectedHabitProgress matches first habit initially', () {
      expect(
        provider.selectedHabitProgress.habitId,
        provider.habits.first.id,
      );
    });

    test('selectHabit updates selectedHabitIndex', () {
      provider.selectHabit(2);
      expect(provider.selectedHabitIndex, 2);
      expect(
        provider.selectedHabitProgress.habitId,
        provider.habits[2].id,
      );
    });

    test('selectHabit does nothing when same index', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.selectHabit(0);
      expect(notified, isFalse);
    });

    test('selectHabit notifies listeners on change', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.selectHabit(1);
      expect(notified, isTrue);
    });

    // -------------------------------------------------------------------------
    // HabitProgress data quality
    // -------------------------------------------------------------------------

    test('all habitProgresses have 84-day heatmapData', () {
      for (final hp in provider.habitProgresses) {
        expect(hp.heatmapData.length, 84);
      }
    });

    test('heatmapData values are 0 or 1 only', () {
      for (final hp in provider.habitProgresses) {
        for (final v in hp.heatmapData.values) {
          expect([0, 1], contains(v));
        }
      }
    });

    test('frequencyByDay has 7 entries (weekdays 1–7)', () {
      for (final hp in provider.habitProgresses) {
        expect(hp.frequencyByDay.length, 7);
        for (int wd = 1; wd <= 7; wd++) {
          expect(hp.frequencyByDay.containsKey(wd), isTrue);
        }
      }
    });

    test('frequencyByDay values are 0.0–1.0', () {
      for (final hp in provider.habitProgresses) {
        for (final rate in hp.frequencyByDay.values) {
          expect(rate, greaterThanOrEqualTo(0.0));
          expect(rate, lessThanOrEqualTo(1.0));
        }
      }
    });

    test('completionRate is 0.0–1.0 for all habits', () {
      for (final hp in provider.habitProgresses) {
        expect(hp.completionRate, greaterThanOrEqualTo(0.0));
        expect(hp.completionRate, lessThanOrEqualTo(1.0));
      }
    });

    test('currentStreak is non-negative for all habits', () {
      for (final hp in provider.habitProgresses) {
        expect(hp.currentStreak, isNonNegative);
      }
    });

    test('longestStreak >= currentStreak for all habits', () {
      for (final hp in provider.habitProgresses) {
        expect(hp.longestStreak, greaterThanOrEqualTo(hp.currentStreak));
      }
    });

    test('goalStage is a valid GoalStage for all habits', () {
      for (final hp in provider.habitProgresses) {
        expect(GoalStage.values, contains(hp.goalStage));
      }
    });

    test('daysToNextStage is 0 when formed, positive otherwise', () {
      for (final hp in provider.habitProgresses) {
        if (hp.goalStage == GoalStage.formed) {
          expect(hp.daysToNextStage, 0);
        } else {
          expect(hp.daysToNextStage, greaterThan(0));
        }
      }
    });

    test('reflectionUnlocked is false at ignition, true at foundation+', () {
      for (final hp in provider.habitProgresses) {
        if (hp.goalStage == GoalStage.ignition) {
          expect(hp.reflectionUnlocked, isFalse);
        } else {
          expect(hp.reflectionUnlocked, isTrue);
        }
      }
    });

    test('at least one habit at foundation (10+ days)', () {
      final foundationOrHigher = provider.habitProgresses.where(
        (hp) => hp.goalStage != GoalStage.ignition,
      );
      expect(foundationOrHigher, isNotEmpty);
    });

    test('at least one habit at momentum (21+ days)', () {
      final momentumOrHigher = provider.habitProgresses.where(
        (hp) => hp.goalStage == GoalStage.momentum || hp.goalStage == GoalStage.formed,
      );
      expect(momentumOrHigher, isNotEmpty);
    });

    test('failureInsights is non-empty for habits with enough data', () {
      // All habits have 84 days of heatmap data → should have insights.
      for (final hp in provider.habitProgresses) {
        if (hp.heatmapData.length >= 14) {
          expect(hp.failureInsights, isNotEmpty);
        }
      }
    });

    // -------------------------------------------------------------------------
    // OverviewStats
    // -------------------------------------------------------------------------

    test('overviewStats is initialized', () {
      expect(provider.overviewStats, isA<OverviewStats>());
    });

    test('overallCompletionRate is 0.0–1.0', () {
      expect(provider.overviewStats.overallCompletionRate,
          greaterThanOrEqualTo(0.0));
      expect(provider.overviewStats.overallCompletionRate,
          lessThanOrEqualTo(1.0));
    });

    test('totalXP is non-negative', () {
      expect(provider.overviewStats.totalXP, isNonNegative);
    });

    test('currentRank is a known rank string', () {
      const ranks = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
      expect(ranks, contains(provider.overviewStats.currentRank));
    });

    test('rankProgress is 0.0–1.0', () {
      expect(provider.overviewStats.rankProgress,
          greaterThanOrEqualTo(0.0));
      expect(provider.overviewStats.rankProgress, lessThanOrEqualTo(1.0));
    });

    test('totalHabitsTracked equals habits count', () {
      expect(provider.overviewStats.totalHabitsTracked,
          provider.habits.length);
    });

    test('perfectDays is non-negative', () {
      expect(provider.overviewStats.perfectDays, isNonNegative);
    });

    test('bestWeekRate >= currentWeekRate', () {
      expect(provider.overviewStats.bestWeekRate,
          greaterThanOrEqualTo(provider.overviewStats.currentWeekRate));
    });

    test('weeklyCompletionData has entry per habit name', () {
      final habitNames = provider.habits.map((h) => h.name).toSet();
      for (final name in habitNames) {
        expect(
          provider.overviewStats.weeklyCompletionData.containsKey(name),
          isTrue,
          reason: 'Missing key: $name',
        );
      }
    });

    test('weeklyCompletionData lists have 7 values each', () {
      for (final entry in provider.overviewStats.weeklyCompletionData.entries) {
        expect(entry.value.length, 7,
            reason: '${entry.key} should have 7 daily rates');
      }
    });

    // -------------------------------------------------------------------------
    // Reflections
    // -------------------------------------------------------------------------

    test('reflections map is empty initially', () {
      expect(provider.reflections, isEmpty);
    });

    test('submitReflection stores difficulty for habit', () {
      final habitId = provider.habits.first.id;
      provider.submitReflection(habitId, 3, 'Was okay');
      expect(provider.reflections[habitId], 3);
    });

    test('submitReflection notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.submitReflection(provider.habits.first.id, 2, null);
      expect(notified, isTrue);
    });

    test('submitReflection can be called for multiple habits', () {
      provider.submitReflection('1', 1, null);
      provider.submitReflection('2', 5, 'Hard day');
      expect(provider.reflections['1'], 1);
      expect(provider.reflections['2'], 5);
    });

    test('submitReflection overwrites previous reflection', () {
      provider.submitReflection('1', 2, null);
      provider.submitReflection('1', 4, 'Changed my mind');
      expect(provider.reflections['1'], 4);
    });

    // -------------------------------------------------------------------------
    // Habits list immutability
    // -------------------------------------------------------------------------

    test('habits list is unmodifiable', () {
      expect(
        () => (provider.habits as dynamic).clear(),
        throwsUnsupportedError,
      );
    });
  });
}
