import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/models/user_profile.dart';
import 'package:valence/services/habit_service.dart';
import 'package:valence/services/api_client.dart';
import 'package:valence/utils/constants.dart';

/// Reward awarded when a habit is completed.
class HabitReward {
  final int xp;
  final int sparks;
  final bool isPerfectDayBonus;
  const HabitReward({
    required this.xp,
    required this.sparks,
    this.isPerfectDayBonus = false,
  });
}

/// Manages home screen state: habits, daily progress, selected day, group streak.
/// Loads real data from the API; falls back to mock data when offline.
class HomeProvider extends ChangeNotifier {
  final HabitService _habitService;

  List<Habit> _habits = [];
  DateTime _selectedDay = DateTime.now();
  late GroupStreak _groupStreak;
  String _userName = 'You';

  bool _loading = false;
  String? _error;

  // XP / Sparks session state
  int _sessionXp = 0;
  int _sessionSparks = 0;
  HabitReward? _lastReward;
  bool _perfectDayBonusAwarded = false;

  // Persona-driven subtitle
  PersonaType _personaType = PersonaType.general;

  HomeProvider({HabitService? habitService})
      : _habitService = habitService ?? HabitService() {
    _groupStreak = _mockGroupStreak();
    loadHabits();
  }

  bool get isLoading => _loading;
  String? get error => _error;

  // --- Getters ---

  List<Habit> get habits => List.unmodifiable(_habits);
  DateTime get selectedDay => _selectedDay;
  GroupStreak get groupStreak => _groupStreak;
  String get userName => _userName;

  int get completedCount => _habits.where((h) => h.isCompleted).length;
  int get totalCount => _habits.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
  bool get isPerfectDay => completedCount == totalCount && totalCount > 0;

  /// Session XP earned today.
  int get sessionXp => _sessionXp;

  /// Session Sparks earned today.
  int get sessionSparks => _sessionSparks;

  /// The most recently awarded reward (null after clearLastReward).
  HabitReward? get lastReward => _lastReward;

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

  /// Persona-driven motivational subtitle.
  String get subtitle {
    if (isPerfectDay) return 'Perfect day! All $totalCount habits crushed. 🔥';

    return switch (_personaType) {
      PersonaType.socialiser => _socialiserSubtitle(),
      PersonaType.achiever => _achieverSubtitle(),
      PersonaType.general => _generalSubtitle(),
    };
  }

  String _socialiserSubtitle() {
    final remaining = totalCount - completedCount;
    if (completedCount == 0) {
      return 'Your group is watching. $totalCount habits to show up for today.';
    }
    if (remaining == 1) {
      return '$completedCount done. 1 more habit to secure today\'s chain link.';
    }
    return '$completedCount/$totalCount done. $remaining more to keep the group streak alive.';
  }

  String _achieverSubtitle() {
    final remaining = totalCount - completedCount;
    if (completedCount == 0) {
      return 'Day ${currentStreak + 1} starts now. $totalCount habits on deck.';
    }
    if (remaining == 0) {
      return 'Stats: $_sessionXp XP earned today. Perfect pace.';
    }
    return '$completedCount/$totalCount habits · $_sessionXp XP today · $remaining remaining';
  }

  String _generalSubtitle() {
    final remaining = totalCount - completedCount;
    if (completedCount == 0) return 'Fresh start. $totalCount habits waiting for you.';
    if (remaining == 1) return '$completedCount done. Just 1 more for a perfect day.';
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

  // --- API ---

  /// Load habits from the API. Falls back to mock data on error.
  Future<void> loadHabits() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _habitService.fetchHabits();
      _habits = raw.map((h) => _habitFromApi(h as Map<String, dynamic>)).toList();
      _loading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _loading = false;
      _error = e.message;
      _habits = _mockHabits();
      notifyListeners();
    } catch (_) {
      _loading = false;
      _habits = _mockHabits();
      notifyListeners();
    }
  }

  Habit _habitFromApi(Map<String, dynamic> h) {
    final tracking = h['tracking_method'] as String? ?? 'manual';
    final vis = h['visibility'] as String? ?? 'full';
    return Habit(
      id: h['id'] as String,
      name: h['name'] as String,
      subtitle: h['subtitle'] as String? ?? '',
      color: HabitColors.fromName(h['color'] as String? ?? 'blue'),
      iconName: h['icon_name'] as String? ?? 'star',
      trackingType: _parseTrackingType(tracking),
      pluginName: h['plugin_id'] as String?,
      redirectUrl: h['redirect_url'] as String?,
      isCompleted: h['completed_today'] as bool? ?? false,
      intensity: _parseIntensity(h['intensity'] as String? ?? 'moderate'),
      streakDays: h['streak_days'] as int? ?? 0,
      visibility: vis == 'minimal' ? HabitVisibility.minimal : HabitVisibility.full,
    );
  }

  TrackingType _parseTrackingType(String s) => switch (s) {
        'plugin' => TrackingType.plugin,
        'manual_photo' => TrackingType.manualPhoto,
        'redirect' => TrackingType.redirect,
        _ => TrackingType.manual,
      };

  HabitIntensity _parseIntensity(String s) => switch (s) {
        'light' => HabitIntensity.light,
        'intense' => HabitIntensity.intense,
        _ => HabitIntensity.moderate,
      };

  // --- Actions ---

  /// Update the persona type (called by ChangeNotifierProxyProvider from ProfileProvider).
  void setPersonaType(PersonaType type) {
    if (_personaType == type) return;
    _personaType = type;
    notifyListeners();
  }

  /// Clear the last reward after showing the toast so it doesn't re-show.
  void clearLastReward() {
    _lastReward = null;
    notifyListeners();
  }

  /// Toggle completion for a habit. Plugin habits cannot be toggled manually.
  /// Awards XP and Sparks when completing; no deduction on un-completing.
  void toggleHabit(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.isPlugin) return;

    final wasCompleted = habit.isCompleted;
    // Optimistic update
    _habits[index] = habit.copyWith(isCompleted: !wasCompleted);

    if (!wasCompleted) {
      // Optimistic XP (will be reconciled with server response)
      final baseXp = _xpForIntensity(habit.intensity);
      var totalXp = baseXp;
      var totalSparks = baseXp;
      var isPerfectDayBonus = false;
      if (isPerfectDay && !_perfectDayBonusAwarded) {
        totalXp += 25;
        totalSparks += 25;
        _perfectDayBonusAwarded = true;
        isPerfectDayBonus = true;
      }
      _sessionXp += totalXp;
      _sessionSparks += totalSparks;
      _lastReward = HabitReward(
        xp: totalXp,
        sparks: totalSparks,
        isPerfectDayBonus: isPerfectDayBonus,
      );
      notifyListeners();
      // Fire-and-forget to backend; reconcile on response
      _completeHabitApi(habitId, index, habit, totalXp, totalSparks);
    } else {
      _lastReward = null;
      notifyListeners();
    }
  }

  Future<void> _completeHabitApi(
    String habitId,
    int index,
    Habit original,
    int optimisticXp,
    int optimisticSparks,
  ) async {
    try {
      final res = await _habitService.completeHabit(habitId);
      final points = res['points'] as Map<String, dynamic>?;
      if (points != null) {
        final serverXp = (points['xpAwarded'] as num?)?.toInt() ?? optimisticXp;
        final serverSparks = (points['sparksAwarded'] as num?)?.toInt() ?? optimisticSparks;
        final diff = serverXp - optimisticXp;
        _sessionXp += diff;
        _sessionSparks += serverSparks - optimisticSparks;
        final isPerfect = res['perfectDay'] as bool? ?? false;
        _lastReward = HabitReward(
          xp: serverXp,
          sparks: serverSparks,
          isPerfectDayBonus: isPerfect,
        );
        notifyListeners();
      }
    } on ApiException catch (_) {
      // Revert optimistic update on error
      if (index < _habits.length) {
        _habits[index] = original;
        _sessionXp -= optimisticXp;
        _sessionSparks -= optimisticSparks;
        _lastReward = null;
        notifyListeners();
      }
    }
  }

  /// Toggle completion for a habit (alias for toggleHabit).
  void toggleHabitCompletion(String habitId) => toggleHabit(habitId);

  /// Toggle the visibility of a habit between full and minimal (PRD 5.3.5).
  void toggleHabitVisibility(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final habit = _habits[index];
    _habits[index] = habit.copyWith(
      visibility: habit.visibility == HabitVisibility.full
          ? HabitVisibility.minimal
          : HabitVisibility.full,
    );
    notifyListeners();
  }

  /// Add a new habit. Called from HabitFormScreen.
  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  /// Update an existing habit (edit flow).
  void updateHabit(Habit updated) {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index == -1) return;
    _habits[index] = updated;
    notifyListeners();
  }

  /// Delete a habit by ID.
  void deleteHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
  }

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

  // --- Private helpers ---

  int _xpForIntensity(HabitIntensity intensity) {
    return switch (intensity) {
      HabitIntensity.light => 5,
      HabitIntensity.moderate => 10,
      HabitIntensity.intense => 20,
    };
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
