import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/providers/home_provider.dart';

void main() {
  group('HomeProvider', () {
    late HomeProvider provider;

    setUp(() {
      provider = HomeProvider();
    });

    test('initializes with mock habits', () {
      expect(provider.habits.isNotEmpty, isTrue);
      expect(provider.habits.length, greaterThanOrEqualTo(6));
    });

    test('greeting reflects time of day', () {
      // The greeting is time-dependent, but always contains a name
      expect(provider.greeting, isNotEmpty);
    });

    test('subtitle returns a persona-driven message', () {
      expect(provider.subtitle, isNotEmpty);
    });

    test('completedCount tracks completed habits', () {
      expect(provider.completedCount, isA<int>());
      expect(provider.completedCount, lessThanOrEqualTo(provider.habits.length));
    });

    test('totalCount returns total habits', () {
      expect(provider.totalCount, provider.habits.length);
    });

    test('progress returns fraction between 0 and 1', () {
      expect(provider.progress, greaterThanOrEqualTo(0.0));
      expect(provider.progress, lessThanOrEqualTo(1.0));
    });

    test('toggleHabit marks a manual habit as completed', () {
      final firstManual = provider.habits.firstWhere(
        (h) => h.trackingType == TrackingType.manual,
      );
      final wasCompleted = firstManual.isCompleted;

      provider.toggleHabit(firstManual.id);

      final updated = provider.habits.firstWhere((h) => h.id == firstManual.id);
      expect(updated.isCompleted, !wasCompleted);
    });

    test('toggleHabitCompletion is an alias for toggleHabit', () {
      final firstManual = provider.habits.firstWhere(
        (h) => h.trackingType == TrackingType.manual,
      );
      final wasCompleted = firstManual.isCompleted;

      provider.toggleHabitCompletion(firstManual.id);

      final updated = provider.habits.firstWhere((h) => h.id == firstManual.id);
      expect(updated.isCompleted, !wasCompleted);
    });

    test('toggleHabit does NOT toggle plugin habits', () {
      final plugin = provider.habits.firstWhere(
        (h) => h.trackingType == TrackingType.plugin,
      );
      final wasDone = plugin.isCompleted;

      provider.toggleHabit(plugin.id);

      final updated = provider.habits.firstWhere((h) => h.id == plugin.id);
      expect(updated.isCompleted, wasDone); // unchanged
    });

    test('selectedDay defaults to today', () {
      final now = DateTime.now();
      expect(provider.selectedDay.day, now.day);
    });

    test('selectDay updates the selected day', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      provider.selectDay(yesterday);
      expect(provider.selectedDay.day, yesterday.day);
    });

    test('weekDays returns 7 days', () {
      expect(provider.weekDays.length, 7);
    });

    test('dayStatusFor returns a DayStatus', () {
      final status = provider.dayStatusFor(DateTime.now());
      expect(DayStatus.values, contains(status));
    });

    test('groupStreak returns mock data', () {
      expect(provider.groupStreak, isNotNull);
      expect(provider.groupStreak.last7Days.length, 7);
      expect(provider.groupStreak.currentStreak, isNonNegative);
    });

    test('chainLinks returns 7 chain links', () {
      expect(provider.chainLinks.length, 7);
    });

    test('currentStreak is non-negative', () {
      expect(provider.currentStreak, isNonNegative);
    });

    test('groupTier returns a non-empty string', () {
      expect(provider.groupTier, isNotEmpty);
    });

    test('habits list is unmodifiable', () {
      final dummyHabit = Habit(
        id: 'x',
        name: 'Test',
        subtitle: 'test',
        color: const Color(0xFF000000),
        iconName: 'code',
        trackingType: TrackingType.manual,
      );
      expect(
        () => (provider.habits as dynamic).add(dummyHabit),
        throwsUnsupportedError,
      );
    });

    test('greeting contains username', () {
      expect(provider.greeting, contains('Diana'));
    });

    test('greeting starts with Good morning/afternoon/evening', () {
      final validPrefixes = ['Good morning', 'Good afternoon', 'Good evening'];
      expect(
        validPrefixes.any((prefix) => provider.greeting.startsWith(prefix)),
        isTrue,
      );
    });
  });
}
