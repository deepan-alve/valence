import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit.dart';

void main() {
  group('Habit', () {
    test('constructs with required fields', () {
      final habit = Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: const Color(0xFF4E55E0),
        iconName: 'code',
        trackingType: TrackingType.manual,
      );

      expect(habit.id, '1');
      expect(habit.name, 'LeetCode');
      expect(habit.trackingType, TrackingType.manual);
      expect(habit.isCompleted, isFalse);
    });

    test('defaults: intensity=moderate, streakDays=0, isCompleted=false', () {
      final habit = Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: const Color(0xFF4E55E0),
        iconName: 'code',
        trackingType: TrackingType.manual,
      );

      expect(habit.intensity, HabitIntensity.moderate);
      expect(habit.streakDays, 0);
      expect(habit.isCompleted, isFalse);
    });

    test('copyWith overrides specified fields', () {
      final habit = Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: const Color(0xFF4E55E0),
        iconName: 'code',
        trackingType: TrackingType.manual,
      );

      final completed = habit.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
      expect(completed.name, 'LeetCode');
    });

    test('plugin habits have correct tracking type', () {
      final habit = Habit(
        id: '2',
        name: 'GitHub Commits',
        subtitle: 'Push 1 commit',
        color: const Color(0xFFB8EB6C),
        iconName: 'git-branch',
        trackingType: TrackingType.plugin,
        pluginName: 'GitHub',
      );

      expect(habit.trackingType, TrackingType.plugin);
      expect(habit.pluginName, 'GitHub');
      expect(habit.isPlugin, isTrue);
    });

    test('redirect habits have redirectUrl', () {
      final habit = Habit(
        id: '3',
        name: 'Duolingo',
        subtitle: '1 lesson',
        color: const Color(0xFFF7CD63),
        iconName: 'globe',
        trackingType: TrackingType.redirect,
        redirectUrl: 'https://duolingo.com',
      );

      expect(habit.isRedirect, isTrue);
      expect(habit.redirectUrl, 'https://duolingo.com');
    });

    test('manualPhoto habit requiresPhoto is true', () {
      final habit = Habit(
        id: '4',
        name: 'Meditate',
        subtitle: '10 min',
        color: const Color(0xFFFC8FC6),
        iconName: 'brain',
        trackingType: TrackingType.manualPhoto,
      );

      expect(habit.requiresPhoto, isTrue);
      expect(habit.isPlugin, isFalse);
      expect(habit.isRedirect, isFalse);
    });
  });

  group('TrackingType', () {
    test('all values exist', () {
      expect(TrackingType.values.length, 4);
      expect(TrackingType.values, contains(TrackingType.manual));
      expect(TrackingType.values, contains(TrackingType.manualPhoto));
      expect(TrackingType.values, contains(TrackingType.plugin));
      expect(TrackingType.values, contains(TrackingType.redirect));
    });
  });

  group('HabitIntensity', () {
    test('all values exist', () {
      expect(HabitIntensity.values.length, 3);
      expect(HabitIntensity.values, contains(HabitIntensity.light));
      expect(HabitIntensity.values, contains(HabitIntensity.moderate));
      expect(HabitIntensity.values, contains(HabitIntensity.intense));
    });
  });

  group('DayStatus', () {
    test('all values exist', () {
      expect(DayStatus.values.length, 4);
    });
  });

  group('ChainLinkType', () {
    test('all values exist', () {
      expect(ChainLinkType.values.length, 4);
      expect(ChainLinkType.values, contains(ChainLinkType.gold));
      expect(ChainLinkType.values, contains(ChainLinkType.silver));
      expect(ChainLinkType.values, contains(ChainLinkType.broken));
      expect(ChainLinkType.values, contains(ChainLinkType.future));
    });
  });
}
