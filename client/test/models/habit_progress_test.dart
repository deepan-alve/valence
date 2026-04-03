import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit_progress.dart';

void main() {
  group('GoalStage', () {
    test('has exactly 4 values', () {
      expect(GoalStage.values.length, 4);
    });

    test('day thresholds match spec (3, 10, 21, 66)', () {
      expect(GoalStage.ignition.targetDays, 3);
      expect(GoalStage.foundation.targetDays, 10);
      expect(GoalStage.momentum.targetDays, 21);
      expect(GoalStage.formed.targetDays, 66);
    });

    test('display names are non-empty', () {
      for (final stage in GoalStage.values) {
        expect(stage.displayName, isNotEmpty);
        expect(stage.tagline, isNotEmpty);
      }
    });

    test('stageFor: 0–2 days → ignition', () {
      expect(GoalStage.stageFor(0), GoalStage.ignition);
      expect(GoalStage.stageFor(2), GoalStage.ignition);
    });

    test('stageFor: 3–9 days → ignition', () {
      expect(GoalStage.stageFor(3), GoalStage.ignition);
      expect(GoalStage.stageFor(9), GoalStage.ignition);
    });

    test('stageFor: 10–20 days → foundation', () {
      expect(GoalStage.stageFor(10), GoalStage.foundation);
      expect(GoalStage.stageFor(20), GoalStage.foundation);
    });

    test('stageFor: 21–65 days → momentum', () {
      expect(GoalStage.stageFor(21), GoalStage.momentum);
      expect(GoalStage.stageFor(65), GoalStage.momentum);
    });

    test('stageFor: 66+ days → formed', () {
      expect(GoalStage.stageFor(66), GoalStage.formed);
      expect(GoalStage.stageFor(100), GoalStage.formed);
    });

    test('daysToNext: returns 0 when already formed', () {
      expect(GoalStage.daysToNext(66), 0);
      expect(GoalStage.daysToNext(100), 0);
    });

    test('daysToNext: correct count before ignition threshold', () {
      // 1 day in → 2 days to reach ignition (3)
      expect(GoalStage.daysToNext(1), 2);
    });

    test('daysToNext: correct count between ignition and foundation', () {
      // 5 days in → 5 days to reach foundation (10)
      expect(GoalStage.daysToNext(5), 5);
    });

    test('daysToNext: correct count between foundation and momentum', () {
      // 15 days in → 6 days to reach momentum (21)
      expect(GoalStage.daysToNext(15), 6);
    });

    test('hasReachedFoundation: false below 10', () {
      expect(GoalStage.hasReachedFoundation(9), isFalse);
      expect(GoalStage.hasReachedFoundation(0), isFalse);
    });

    test('hasReachedFoundation: true at 10+', () {
      expect(GoalStage.hasReachedFoundation(10), isTrue);
      expect(GoalStage.hasReachedFoundation(50), isTrue);
      expect(GoalStage.hasReachedFoundation(66), isTrue);
    });
  });

  group('HabitProgress', () {
    HabitProgress _makeProgress({
      int currentStreak = 5,
      GoalStage goalStage = GoalStage.ignition,
      bool reflectionUnlocked = false,
    }) {
      return HabitProgress(
        habitId: 'h1',
        habitName: 'Exercise',
        habitColor: const Color(0xFF4E55E0),
        currentStreak: currentStreak,
        longestStreak: currentStreak + 3,
        totalDaysCompleted: 30,
        goalStage: goalStage,
        daysToNextStage: 5,
        completionRate: 0.72,
        heatmapData: const {},
        frequencyByDay: const {},
        failureInsights: const ['You tend to miss on Fridays.'],
        reflectionUnlocked: reflectionUnlocked,
      );
    }

    test('constructs with all required fields', () {
      final p = _makeProgress();
      expect(p.habitId, 'h1');
      expect(p.habitName, 'Exercise');
      expect(p.currentStreak, 5);
      expect(p.longestStreak, 8);
      expect(p.totalDaysCompleted, 30);
      expect(p.completionRate, 0.72);
      expect(p.reflectionUnlocked, isFalse);
    });

    test('reflectionUnlocked is true at foundation+', () {
      final p = _makeProgress(
        goalStage: GoalStage.foundation,
        reflectionUnlocked: true,
      );
      expect(p.reflectionUnlocked, isTrue);
    });

    test('completionRate is in 0.0–1.0 range', () {
      final p = _makeProgress();
      expect(p.completionRate, greaterThanOrEqualTo(0.0));
      expect(p.completionRate, lessThanOrEqualTo(1.0));
    });

    test('copyWith overrides only specified fields', () {
      final p = _makeProgress();
      final updated = p.copyWith(currentStreak: 20, goalStage: GoalStage.foundation);

      expect(updated.currentStreak, 20);
      expect(updated.goalStage, GoalStage.foundation);
      // unchanged
      expect(updated.habitId, 'h1');
      expect(updated.habitName, 'Exercise');
      expect(updated.completionRate, 0.72);
    });

    test('heatmapData accepts DateTime keys', () {
      final day = DateTime(2026, 3, 30);
      final p = _makeProgress().copyWith(heatmapData: {day: 1});
      expect(p.heatmapData[day], 1);
    });

    test('frequencyByDay accepts weekday int keys', () {
      final freq = {for (int i = 1; i <= 7; i++) i: 0.6};
      final p = _makeProgress().copyWith(frequencyByDay: freq);
      expect(p.frequencyByDay[1], 0.6);
      expect(p.frequencyByDay[7], 0.6);
    });

    test('failureInsights is a list of strings', () {
      final p = _makeProgress();
      expect(p.failureInsights, isA<List<String>>());
      expect(p.failureInsights.first, isNotEmpty);
    });
  });
}
