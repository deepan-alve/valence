import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/utils/constants.dart';

/// Manages home screen state: habits, daily progress, selected day, group streak.
/// Uses mock data until the API service layer is built (Phase 7+).
class HomeProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  DateTime _selectedDay = DateTime.now();
  late GroupStreak _groupStreak;
  final String _userName = 'Diana';

  HomeProvider() {
    _habits = _mockHabits();
    _groupStreak = _mockGroupStreak();
  }

  // --- Getters ---

  List<Habit> get habits => List.unmodifiable(_habits);
  DateTime get selectedDay => _selectedDay;
  GroupStreak get groupStreak => _groupStreak;
  String get userName => _userName;

  int get completedCount => _habits.where((h) => h.isCompleted).length;
  int get totalCount => _habits.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
  bool get isPerfectDay => completedCount == totalCount && totalCount > 0;

  /// Current streak across all habits (max streak in the set).
  int get currentStreak => _groupStreak.currentStreak;

  /// Group tier label.
  String get groupTier => _groupStreak.tier.name;

  /// Chain links for the last 7 days.
  List<ChainLink> get chainLinks => _groupStreak.last7Days;

  /// Time-of-day greeting.
  String get greeting {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    return '$timeGreeting, $_userName';
  }

  /// Persona-driven motivational subtitle (mock: General persona).
  String get subtitle {
    if (isPerfectDay) {
      return 'Perfect day! All $totalCount habits crushed.';
    }
    if (completedCount == 0) {
      return 'Fresh start. $totalCount habits waiting for you.';
    }
    final remaining = totalCount - completedCount;
    return '$completedCount/$totalCount habits done. $remaining more for a perfect day.';
  }

  /// Returns the 7 days of the current week (Mon-Sun).
  List<DateTime> get weekDays {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return DateTime(day.year, day.month, day.day);
    });
  }

  // --- Actions ---

  /// Toggle completion for a habit. Plugin habits cannot be toggled manually.
  void toggleHabit(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    // Plugin habits are auto-tracked --- cannot be toggled manually
    if (habit.isPlugin) return;

    _habits[index] = habit.copyWith(isCompleted: !habit.isCompleted);
    notifyListeners();
  }

  /// Toggle completion for a habit (alias for toggleHabit).
  void toggleHabitCompletion(String habitId) => toggleHabit(habitId);

  /// Select a day in the week selector.
  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    notifyListeners();
  }

  /// Returns the day status for a given date (mock implementation).
  DayStatus dayStatusFor(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);

    if (target.isAfter(today)) return DayStatus.future;
    if (target.isAtSameMomentAs(today)) {
      if (isPerfectDay) return DayStatus.allDone;
      if (completedCount > 0) return DayStatus.partial;
      return DayStatus.missed;
    }

    // Mock: past days have varied statuses
    final dayOfWeek = target.weekday;
    if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
      return DayStatus.allDone;
    }
    if (dayOfWeek == DateTime.wednesday) {
      return DayStatus.partial;
    }
    if (dayOfWeek == DateTime.friday && target.isBefore(today)) {
      return DayStatus.missed;
    }
    return DayStatus.allDone;
  }

  // --- Mock Data ---

  static List<Habit> _mockHabits() {
    return [
      Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: HabitColors.blue,
        iconName: 'code',
        trackingType: TrackingType.plugin,
        pluginName: 'LeetCode',
        isCompleted: true,
        streakDays: 12,
      ),
      Habit(
        id: '2',
        name: 'Exercise',
        subtitle: '30 min workout',
        color: HabitColors.lime,
        iconName: 'barbell',
        trackingType: TrackingType.manual,
        isCompleted: false,
        intensity: HabitIntensity.intense,
        streakDays: 5,
      ),
      Habit(
        id: '3',
        name: 'Read',
        subtitle: 'Read 20 pages',
        color: HabitColors.amber,
        iconName: 'book-open',
        trackingType: TrackingType.manual,
        isCompleted: true,
        streakDays: 8,
      ),
      Habit(
        id: '4',
        name: 'Meditate',
        subtitle: '10 min session',
        color: HabitColors.pink,
        iconName: 'brain',
        trackingType: TrackingType.manualPhoto,
        isCompleted: false,
        intensity: HabitIntensity.light,
        streakDays: 3,
      ),
      Habit(
        id: '5',
        name: 'Duolingo',
        subtitle: '1 lesson',
        color: HabitColors.teal,
        iconName: 'globe',
        trackingType: TrackingType.redirect,
        redirectUrl: 'https://duolingo.com',
        isCompleted: false,
        streakDays: 21,
      ),
      Habit(
        id: '6',
        name: 'Journal',
        subtitle: 'Write 1 entry',
        color: HabitColors.purple,
        iconName: 'pencil-simple',
        trackingType: TrackingType.manual,
        isCompleted: false,
        intensity: HabitIntensity.light,
        streakDays: 1,
      ),
    ];
  }

  static GroupStreak _mockGroupStreak() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);

    return GroupStreak(
      groupName: 'Build Squad',
      currentStreak: 12,
      tier: GroupTier.ember,
      last7Days: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final target = DateTime(day.year, day.month, day.day);

        ChainLinkType type;
        if (target.isAfter(today)) {
          type = ChainLinkType.future;
        } else if (i == 4) {
          // Friday is broken for demo
          type = ChainLinkType.broken;
        } else if (i % 3 == 0) {
          type = ChainLinkType.silver;
        } else {
          type = ChainLinkType.gold;
        }

        return ChainLink(date: target, type: type);
      }),
    );
  }
}
