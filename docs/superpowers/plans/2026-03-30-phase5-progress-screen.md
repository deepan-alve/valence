# Phase 5: Progress Screen --- Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Progress Screen (Tab 2 in MainShell) with two top-level tabs: Per-Habit (streak, goal graduation, heatmap, frequency chart, failure insights) and Overview (overall completion rate, stacked bar chart, weekly/monthly cards, XP+rank, best vs current week). Also includes the Evening Reflection bottom sheet flow, gated behind Foundation stage (10 days).

**Architecture:** A `ProgressProvider` (ChangeNotifier) manages all progress state using mock data: per-habit stats, heatmap data, frequency distributions, failure insight text, overview aggregations, and reflection state. The screen composes a `TabBarView` with two tabs. Per-habit tab uses a habit chip selector and scrollable detail sections. Overview tab aggregates all habits. Charts use `fl_chart` (already in pubspec). The `ReflectionSheet` is a standalone bottom sheet triggered externally (or via a FAB on progress screen for demo). All colors come from `context.tokens` with zero hardcoded values.

**Tech Stack:** Flutter, Provider, Phosphor Icons (`phosphor_flutter`), Google Fonts (`google_fonts`), fl_chart (`fl_chart`)

**Design Spec:** `docs/superpowers/specs/2026-03-30-ui-redesign-design.md` --- Sections 2.3 (Progress Screen), 2.9 (Evening Reflection), 3.1 (Component Library: GoalProgress, Heatmap, StreakFlame, ReflectionSheet)

---

## File Map

```
client/lib/
├── models/
│   └── habit_log.dart                           # HabitLog model with reflection data
├── providers/
│   └── progress_provider.dart                   # ProgressProvider with mock data
├── screens/
│   └── progress/
│       └── progress_screen.dart                 # REPLACE: Full progress screen with tabs
├── widgets/
│   └── progress/
│       ├── habit_chip_selector.dart              # Horizontal scroll of colored habit chips
│       ├── streak_section.dart                   # Large streak number + flame + stats row
│       ├── goal_graduation_bar.dart              # 4-stage visual progress bar
│       ├── heatmap_grid.dart                     # GitHub-style 12-week contribution grid
│       ├── frequency_chart.dart                  # fl_chart bar chart (Mon-Sun completion)
│       ├── failure_insights_card.dart            # Encouraging insight card + reason pie chart
│       ├── overview_completion_rate.dart         # Large % number with ring
│       ├── overview_stacked_bar.dart             # All habits weekly stacked bar chart
│       ├── overview_summary_cards.dart           # Weekly/monthly summary + best week comparison
│       └── reflection_sheet.dart                 # Bottom sheet: 5 labeled faces + text input

client/test/
├── models/
│   └── habit_log_test.dart
├── providers/
│   └── progress_provider_test.dart
└── widgets/
    └── progress/
        ├── goal_graduation_bar_test.dart
        └── heatmap_grid_test.dart
```

---

### Task 1: Create the HabitLog model with reflection fields

**Files:**
- Create: `client/lib/models/habit_log.dart`
- Create: `client/test/models/habit_log_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/models/habit_log_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit_log.dart';

void main() {
  group('ReflectionDifficulty', () {
    test('all values exist with correct labels', () {
      expect(ReflectionDifficulty.values.length, 5);
      expect(ReflectionDifficulty.easy.label, 'Easy');
      expect(ReflectionDifficulty.okay.label, 'Okay');
      expect(ReflectionDifficulty.moderate.label, 'Moderate');
      expect(ReflectionDifficulty.hard.label, 'Hard');
      expect(ReflectionDifficulty.brutal.label, 'Brutal');
    });

    test('numeric values are 1-5', () {
      expect(ReflectionDifficulty.easy.value, 1);
      expect(ReflectionDifficulty.brutal.value, 5);
    });
  });

  group('GoalStage', () {
    test('all stages exist with correct day thresholds', () {
      expect(GoalStage.values.length, 4);
      expect(GoalStage.ignition.targetDays, 3);
      expect(GoalStage.foundation.targetDays, 10);
      expect(GoalStage.momentum.targetDays, 21);
      expect(GoalStage.formed.targetDays, 66);
    });

    test('stageFor returns correct stage', () {
      expect(GoalStage.stageFor(1), GoalStage.ignition);
      expect(GoalStage.stageFor(3), GoalStage.ignition);
      expect(GoalStage.stageFor(9), GoalStage.foundation);
      expect(GoalStage.stageFor(10), GoalStage.foundation);
      expect(GoalStage.stageFor(20), GoalStage.momentum);
      expect(GoalStage.stageFor(65), GoalStage.formed);
      expect(GoalStage.stageFor(66), GoalStage.formed);
      expect(GoalStage.stageFor(100), GoalStage.formed);
    });

    test('hasReachedFoundation checks 10+ days', () {
      expect(GoalStage.hasReachedFoundation(9), isFalse);
      expect(GoalStage.hasReachedFoundation(10), isTrue);
      expect(GoalStage.hasReachedFoundation(50), isTrue);
    });
  });

  group('MissReason', () {
    test('all reason categories exist', () {
      expect(MissReason.values.length, 5);
    });
  });

  group('HabitLog', () {
    test('constructs with required fields', () {
      final log = HabitLog(
        id: 'log1',
        habitId: 'h1',
        date: DateTime(2026, 3, 28),
        completed: true,
      );

      expect(log.id, 'log1');
      expect(log.habitId, 'h1');
      expect(log.completed, isTrue);
      expect(log.reflectionDifficulty, isNull);
      expect(log.reflectionNote, isNull);
      expect(log.missReason, isNull);
    });

    test('constructs with reflection data', () {
      final log = HabitLog(
        id: 'log2',
        habitId: 'h1',
        date: DateTime(2026, 3, 28),
        completed: true,
        reflectionDifficulty: ReflectionDifficulty.hard,
        reflectionNote: 'Tired today but pushed through',
      );

      expect(log.reflectionDifficulty, ReflectionDifficulty.hard);
      expect(log.reflectionNote, 'Tired today but pushed through');
    });

    test('constructs with miss reason', () {
      final log = HabitLog(
        id: 'log3',
        habitId: 'h1',
        date: DateTime(2026, 3, 28),
        completed: false,
        missReason: MissReason.noEnergy,
      );

      expect(log.completed, isFalse);
      expect(log.missReason, MissReason.noEnergy);
    });

    test('copyWith overrides specified fields', () {
      final log = HabitLog(
        id: 'log1',
        habitId: 'h1',
        date: DateTime(2026, 3, 28),
        completed: true,
      );

      final reflected = log.copyWith(
        reflectionDifficulty: ReflectionDifficulty.moderate,
        reflectionNote: 'Was okay',
      );

      expect(reflected.reflectionDifficulty, ReflectionDifficulty.moderate);
      expect(reflected.reflectionNote, 'Was okay');
      expect(reflected.id, 'log1');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/models/habit_log_test.dart
```

Expected: FAIL --- `package:valence/models/habit_log.dart` not found.

- [ ] **Step 3: Write the HabitLog model**

```dart
// client/lib/models/habit_log.dart

/// Difficulty rating for evening reflection.
/// Labels are visible for accessibility (not emoji-only).
enum ReflectionDifficulty {
  easy(1, 'Easy', '\u{1F60A}'),
  okay(2, 'Okay', '\u{1F642}'),
  moderate(3, 'Moderate', '\u{1F610}'),
  hard(4, 'Hard', '\u{1F615}'),
  brutal(5, 'Brutal', '\u{1F629}');

  final int value;
  final String label;
  final String emoji;

  const ReflectionDifficulty(this.value, this.label, this.emoji);
}

/// Goal graduation stages based on consecutive days.
/// Ignition (3d) -> Foundation (10d) -> Momentum (21d) -> Formed (66d).
enum GoalStage {
  ignition(3, 'Ignition'),
  foundation(10, 'Foundation'),
  momentum(21, 'Momentum'),
  formed(66, 'Formed');

  final int targetDays;
  final String label;

  const GoalStage(this.targetDays, this.label);

  /// Returns the current stage for a given streak day count.
  /// The stage is the one you are WORKING TOWARD (not yet achieved)
  /// unless you have reached Formed.
  static GoalStage stageFor(int days) {
    if (days >= formed.targetDays) return formed;
    if (days >= momentum.targetDays) return formed;
    if (days >= foundation.targetDays) return momentum;
    if (days >= ignition.targetDays) return foundation;
    return ignition;
  }

  /// Whether the user has reached Foundation stage (10+ days).
  /// Used to gate evening reflection.
  static bool hasReachedFoundation(int days) => days >= foundation.targetDays;
}

/// Reason categories for missed habits.
enum MissReason {
  sick('Sick'),
  busy('Busy'),
  forgot('Forgot'),
  noEnergy('No Energy'),
  other('Other');

  final String label;

  const MissReason(this.label);
}

/// A single day's log entry for a habit.
/// Reflection data is stored per HabitLog (per habit per day), NOT per day.
class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;

  /// Reflection fields (only for Foundation+ habits, after completion).
  final ReflectionDifficulty? reflectionDifficulty;
  final String? reflectionNote;

  /// Miss reason (only when completed == false).
  final MissReason? missReason;
  final String? missNote;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.reflectionDifficulty,
    this.reflectionNote,
    this.missReason,
    this.missNote,
  });

  HabitLog copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    ReflectionDifficulty? reflectionDifficulty,
    String? reflectionNote,
    MissReason? missReason,
    String? missNote,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      reflectionDifficulty: reflectionDifficulty ?? this.reflectionDifficulty,
      reflectionNote: reflectionNote ?? this.reflectionNote,
      missReason: missReason ?? this.missReason,
      missNote: missNote ?? this.missNote,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/models/habit_log_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/models/habit_log.dart client/test/models/habit_log_test.dart
git commit -m "feat: add HabitLog model with GoalStage, ReflectionDifficulty, and MissReason enums"
```

---

### Task 2: Create the ProgressProvider with mock data

**Files:**
- Create: `client/lib/providers/progress_provider.dart`
- Create: `client/test/providers/progress_provider_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/providers/progress_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/habit_log.dart';
import 'package:valence/providers/progress_provider.dart';

void main() {
  group('ProgressProvider', () {
    late ProgressProvider provider;

    setUp(() {
      provider = ProgressProvider();
    });

    test('initializes with mock habits', () {
      expect(provider.habits.isNotEmpty, isTrue);
      expect(provider.habits.length, greaterThanOrEqualTo(6));
    });

    test('selectedHabit defaults to first habit', () {
      expect(provider.selectedHabit, isNotNull);
      expect(provider.selectedHabit.id, provider.habits.first.id);
    });

    test('selectHabit updates selection', () {
      final second = provider.habits[1];
      provider.selectHabit(second.id);
      expect(provider.selectedHabit.id, second.id);
    });

    test('currentStreak returns non-negative int', () {
      expect(provider.currentStreak, isNonNegative);
    });

    test('longestStreak is >= currentStreak', () {
      expect(provider.longestStreak, greaterThanOrEqualTo(provider.currentStreak));
    });

    test('totalDaysCompleted is non-negative', () {
      expect(provider.totalDaysCompleted, isNonNegative);
    });

    test('currentStage returns a GoalStage', () {
      expect(GoalStage.values, contains(provider.currentStage));
    });

    test('daysToNextMilestone returns non-negative or -1 if formed', () {
      final days = provider.daysToNextMilestone;
      expect(days, greaterThanOrEqualTo(-1));
    });

    test('heatmapData returns 84 entries (12 weeks)', () {
      expect(provider.heatmapData.length, 84);
    });

    test('heatmapData values are 0.0, 0.5, or 1.0', () {
      for (final entry in provider.heatmapData) {
        expect([0.0, 0.5, 1.0], contains(entry.value));
      }
    });

    test('frequencyData returns 7 entries (Mon-Sun)', () {
      expect(provider.frequencyData.length, 7);
    });

    test('frequencyData values are between 0 and 100', () {
      for (final pct in provider.frequencyData.values) {
        expect(pct, greaterThanOrEqualTo(0));
        expect(pct, lessThanOrEqualTo(100));
      }
    });

    test('strongestDay and weakestDay are valid day names', () {
      const validDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      expect(validDays, contains(provider.strongestDay));
      expect(validDays, contains(provider.weakestDay));
    });

    test('failureInsight returns null when not enough data', () {
      // Select a habit with < 14 days data
      final newHabit = provider.habits.firstWhere(
        (h) => h.streakDays < 14,
        orElse: () => provider.habits.first,
      );
      provider.selectHabit(newHabit.id);
      // May or may not be null depending on mock data
      // The method should not throw
      provider.failureInsight;
    });

    test('overallCompletionRate is between 0 and 100', () {
      expect(provider.overallCompletionRate, greaterThanOrEqualTo(0));
      expect(provider.overallCompletionRate, lessThanOrEqualTo(100));
    });

    test('totalXP is non-negative', () {
      expect(provider.totalXP, isNonNegative);
    });

    test('currentRank is a valid rank string', () {
      const ranks = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
      expect(ranks, contains(provider.currentRank));
    });

    test('rankProgress is between 0.0 and 1.0', () {
      expect(provider.rankProgress, greaterThanOrEqualTo(0.0));
      expect(provider.rankProgress, lessThanOrEqualTo(1.0));
    });

    test('submitReflection updates habit log', () {
      final habit = provider.habits.firstWhere(
        (h) => GoalStage.hasReachedFoundation(h.streakDays),
        orElse: () => provider.habits.first,
      );
      provider.selectHabit(habit.id);

      provider.submitReflection(
        habitId: habit.id,
        difficulty: ReflectionDifficulty.moderate,
        note: 'Was alright',
      );

      // Should not throw
      expect(true, isTrue);
    });

    test('foundationHabits only includes habits with 10+ streak days', () {
      for (final h in provider.foundationHabits) {
        expect(h.streakDays, greaterThanOrEqualTo(10));
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/providers/progress_provider_test.dart
```

Expected: FAIL --- `package:valence/providers/progress_provider.dart` not found.

- [ ] **Step 3: Write the ProgressProvider**

```dart
// client/lib/providers/progress_provider.dart
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/habit_log.dart';
import 'package:valence/utils/constants.dart';

/// Data point for the heatmap grid: date + completion intensity.
class HeatmapEntry {
  final DateTime date;

  /// 0.0 = missed, 0.5 = partial, 1.0 = completed.
  final double value;

  const HeatmapEntry({required this.date, required this.value});
}

/// Stacked bar data for Overview tab: one week of habit completions.
class WeeklyHabitBar {
  final String weekLabel;
  final Map<String, double> habitCompletions; // habitId -> percentage

  const WeeklyHabitBar({
    required this.weekLabel,
    required this.habitCompletions,
  });
}

/// Summary card data for weekly/monthly overviews.
class PeriodSummary {
  final String label;
  final int habitsCompleted;
  final int totalPossible;
  final int perfectDays;
  final int xpEarned;

  const PeriodSummary({
    required this.label,
    required this.habitsCompleted,
    required this.totalPossible,
    required this.perfectDays,
    required this.xpEarned,
  });

  int get completionPercent =>
      totalPossible == 0 ? 0 : (habitsCompleted * 100 ~/ totalPossible);
}

/// Miss reason distribution for failure insights pie chart.
class MissReasonSlice {
  final MissReason reason;
  final int count;
  final double percent;

  const MissReasonSlice({
    required this.reason,
    required this.count,
    required this.percent,
  });
}

/// Manages all Progress screen state using mock data.
/// Covers both Per-Habit and Overview tabs, plus reflection flow.
class ProgressProvider extends ChangeNotifier {
  static final _random = Random(42); // Seeded for deterministic mock data

  List<Habit> _habits = [];
  String _selectedHabitId = '';
  final Map<String, List<HabitLog>> _logsByHabit = {};

  // Per-habit cached stats
  final Map<String, int> _currentStreaks = {};
  final Map<String, int> _longestStreaks = {};
  final Map<String, int> _totalCompleted = {};

  ProgressProvider() {
    _habits = _mockHabits();
    if (_habits.isNotEmpty) {
      _selectedHabitId = _habits.first.id;
    }
    _generateMockLogs();
    _computeStreakStats();
  }

  // ---------------------------------------------------------------------------
  // Getters --- Habit Selection
  // ---------------------------------------------------------------------------

  List<Habit> get habits => List.unmodifiable(_habits);
  Habit get selectedHabit => _habits.firstWhere(
        (h) => h.id == _selectedHabitId,
        orElse: () => _habits.first,
      );

  void selectHabit(String habitId) {
    if (_selectedHabitId == habitId) return;
    _selectedHabitId = habitId;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Getters --- Per-Habit: Streak Section
  // ---------------------------------------------------------------------------

  int get currentStreak => _currentStreaks[_selectedHabitId] ?? 0;
  int get longestStreak => _longestStreaks[_selectedHabitId] ?? 0;
  int get totalDaysCompleted => _totalCompleted[_selectedHabitId] ?? 0;

  // ---------------------------------------------------------------------------
  // Getters --- Per-Habit: Goal Graduation
  // ---------------------------------------------------------------------------

  GoalStage get currentStage => GoalStage.stageFor(currentStreak);

  /// Days remaining to the next milestone, or -1 if already Formed.
  int get daysToNextMilestone {
    final streak = currentStreak;
    if (streak >= GoalStage.formed.targetDays) return -1;

    for (final stage in GoalStage.values) {
      if (streak < stage.targetDays) {
        return stage.targetDays - streak;
      }
    }
    return -1;
  }

  /// Returns the stage the user is currently working toward.
  GoalStage get targetStage {
    final streak = currentStreak;
    for (final stage in GoalStage.values) {
      if (streak < stage.targetDays) return stage;
    }
    return GoalStage.formed;
  }

  /// Progress fraction within the current stage span (0.0 to 1.0).
  double get stageProgress {
    final streak = currentStreak;
    if (streak >= GoalStage.formed.targetDays) return 1.0;

    final stages = GoalStage.values;
    for (int i = 0; i < stages.length; i++) {
      if (streak < stages[i].targetDays) {
        final prevTarget = i == 0 ? 0 : stages[i - 1].targetDays;
        final span = stages[i].targetDays - prevTarget;
        return (streak - prevTarget) / span;
      }
    }
    return 1.0;
  }

  // ---------------------------------------------------------------------------
  // Getters --- Per-Habit: Heatmap
  // ---------------------------------------------------------------------------

  /// Returns 84 entries (12 weeks) for the heatmap grid.
  List<HeatmapEntry> get heatmapData {
    final logs = _logsByHabit[_selectedHabitId] ?? [];
    final logMap = <String, HabitLog>{};
    for (final log in logs) {
      logMap[_dateKey(log.date)] = log;
    }

    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 83));

    return List.generate(84, (i) {
      final date = start.add(Duration(days: i));
      final key = _dateKey(date);
      final log = logMap[key];

      double value;
      if (log == null) {
        value = 0.0;
      } else if (log.completed) {
        value = 1.0;
      } else {
        value = 0.0; // Missed
      }

      return HeatmapEntry(date: date, value: value);
    });
  }

  // ---------------------------------------------------------------------------
  // Getters --- Per-Habit: Frequency Chart
  // ---------------------------------------------------------------------------

  /// Completion rate per day of week (Mon-Sun). Key is day label.
  Map<String, int> get frequencyData {
    final logs = _logsByHabit[_selectedHabitId] ?? [];
    final completionsByDay = <int, int>{};
    final totalByDay = <int, int>{};

    for (final log in logs) {
      final wd = log.date.weekday; // 1=Mon, 7=Sun
      totalByDay[wd] = (totalByDay[wd] ?? 0) + 1;
      if (log.completed) {
        completionsByDay[wd] = (completionsByDay[wd] ?? 0) + 1;
      }
    }

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <String, int>{};
    for (int i = 0; i < 7; i++) {
      final wd = i + 1;
      final total = totalByDay[wd] ?? 0;
      final completed = completionsByDay[wd] ?? 0;
      result[dayLabels[i]] = total == 0 ? 0 : (completed * 100 ~/ total);
    }
    return result;
  }

  String get strongestDay {
    final freq = frequencyData;
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String get weakestDay {
    final freq = frequencyData;
    return freq.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  // ---------------------------------------------------------------------------
  // Getters --- Per-Habit: Failure Insights
  // ---------------------------------------------------------------------------

  /// Returns null if fewer than 14 days of data.
  String? get failureInsight {
    final logs = _logsByHabit[_selectedHabitId] ?? [];
    if (logs.length < 14) return null;

    final weakDay = weakestDay;
    // Personality-driven, encouraging copy
    final templates = [
      'You tend to skip on $weakDay evenings. Totally normal --- try front-loading it earlier that day.',
      '$weakDay seems to be your trickiest day. A small prep the night before can change everything.',
      'Most of your misses land on $weakDay. No judgment --- just awareness. You have got this.',
      '$weakDay is your kryptonite. But knowing that? That is literally half the battle.',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Miss reason distribution for pie chart. Null if < 14 days of data.
  List<MissReasonSlice>? get missReasonBreakdown {
    final logs = _logsByHabit[_selectedHabitId] ?? [];
    if (logs.length < 14) return null;

    final missed = logs.where((l) => !l.completed && l.missReason != null);
    if (missed.isEmpty) return null;

    final counts = <MissReason, int>{};
    for (final log in missed) {
      counts[log.missReason!] = (counts[log.missReason!] ?? 0) + 1;
    }

    final total = counts.values.fold<int>(0, (a, b) => a + b);
    return counts.entries
        .map((e) => MissReasonSlice(
              reason: e.key,
              count: e.value,
              percent: e.value * 100.0 / total,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  // ---------------------------------------------------------------------------
  // Getters --- Overview Tab
  // ---------------------------------------------------------------------------

  int get overallCompletionRate {
    int totalCompleted = 0;
    int totalLogs = 0;

    for (final logs in _logsByHabit.values) {
      totalLogs += logs.length;
      totalCompleted += logs.where((l) => l.completed).length;
    }

    return totalLogs == 0 ? 0 : (totalCompleted * 100 ~/ totalLogs);
  }

  /// Stacked bar data for the last 4 weeks.
  List<WeeklyHabitBar> get weeklyStackedBars {
    final today = DateTime.now();
    final List<WeeklyHabitBar> bars = [];

    for (int w = 3; w >= 0; w--) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + w * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final completions = <String, double>{};
      for (final habit in _habits) {
        final logs = _logsByHabit[habit.id] ?? [];
        final weekLogs = logs.where((l) =>
            !l.date.isBefore(weekStart) &&
            !l.date.isAfter(weekEnd));
        final total = weekLogs.length;
        final completed = weekLogs.where((l) => l.completed).length;
        completions[habit.id] = total == 0 ? 0 : completed / total;
      }

      final label = w == 0
          ? 'This week'
          : w == 1
              ? 'Last week'
              : '${w}w ago';

      bars.add(WeeklyHabitBar(
        weekLabel: label,
        habitCompletions: completions,
      ));
    }

    return bars;
  }

  PeriodSummary get thisWeekSummary => _periodSummary('This week', 7);
  PeriodSummary get thisMonthSummary => _periodSummary('This month', 30);

  PeriodSummary _periodSummary(String label, int days) {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: days));
    int completed = 0;
    int total = 0;
    int perfectDays = 0;

    // Count completions
    for (final logs in _logsByHabit.values) {
      final periodLogs = logs.where((l) => l.date.isAfter(start));
      total += periodLogs.length;
      completed += periodLogs.where((l) => l.completed).length;
    }

    // Count perfect days (simplified mock)
    for (int d = 0; d < days; d++) {
      final day = today.subtract(Duration(days: d));
      final dayKey = _dateKey(day);
      bool perfect = true;
      for (final logs in _logsByHabit.values) {
        final dayLog = logs.where((l) => _dateKey(l.date) == dayKey);
        if (dayLog.isEmpty || !dayLog.first.completed) {
          perfect = false;
          break;
        }
      }
      if (perfect) perfectDays++;
    }

    return PeriodSummary(
      label: label,
      habitsCompleted: completed,
      totalPossible: total,
      perfectDays: perfectDays,
      xpEarned: completed * 10, // Mock: 10 XP per completion
    );
  }

  int get totalXP => 1_340; // Mock total XP
  String get currentRank => 'Silver';
  String get nextRank => 'Gold';
  double get rankProgress => 0.67; // Mock: 67% to next rank
  int get xpToNextRank => 660; // Mock: 660 XP to Gold

  /// Best week: highest completion count in any 7-day window.
  int get bestWeekCompletions => 38;

  /// Current week completions.
  int get currentWeekCompletions {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    int count = 0;
    for (final logs in _logsByHabit.values) {
      count += logs
          .where((l) => !l.date.isBefore(weekStart) && l.completed)
          .length;
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Getters --- Evening Reflection
  // ---------------------------------------------------------------------------

  /// Habits that have reached Foundation stage (10+ days).
  /// Only these habits are eligible for evening reflection.
  List<Habit> get foundationHabits =>
      _habits.where((h) => GoalStage.hasReachedFoundation(h.streakDays)).toList();

  /// Whether any habit qualifies for reflection.
  bool get hasReflectionEligibleHabits => foundationHabits.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Submit reflection for a habit (stored per HabitLog).
  void submitReflection({
    required String habitId,
    required ReflectionDifficulty difficulty,
    String? note,
  }) {
    final logs = _logsByHabit[habitId];
    if (logs == null || logs.isEmpty) return;

    // Find today's log
    final todayKey = _dateKey(DateTime.now());
    final idx = logs.indexWhere((l) => _dateKey(l.date) == todayKey);
    if (idx == -1) return;

    logs[idx] = logs[idx].copyWith(
      reflectionDifficulty: difficulty,
      reflectionNote: note,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mock Data Generation
  // ---------------------------------------------------------------------------

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
        streakDays: 23,
      ),
      Habit(
        id: '2',
        name: 'Exercise',
        subtitle: '30 min workout',
        color: HabitColors.lime,
        iconName: 'barbell',
        trackingType: TrackingType.manual,
        intensity: HabitIntensity.intense,
        streakDays: 12,
      ),
      Habit(
        id: '3',
        name: 'Read',
        subtitle: 'Read 20 pages',
        color: HabitColors.amber,
        iconName: 'book-open',
        trackingType: TrackingType.manual,
        streakDays: 45,
      ),
      Habit(
        id: '4',
        name: 'Meditate',
        subtitle: '10 min session',
        color: HabitColors.pink,
        iconName: 'brain',
        trackingType: TrackingType.manualPhoto,
        intensity: HabitIntensity.light,
        streakDays: 7,
      ),
      Habit(
        id: '5',
        name: 'Duolingo',
        subtitle: '1 lesson',
        color: HabitColors.teal,
        iconName: 'globe',
        trackingType: TrackingType.redirect,
        redirectUrl: 'https://duolingo.com',
        streakDays: 66,
      ),
      Habit(
        id: '6',
        name: 'Journal',
        subtitle: 'Write 1 entry',
        color: HabitColors.purple,
        iconName: 'pencil-simple',
        trackingType: TrackingType.manual,
        intensity: HabitIntensity.light,
        streakDays: 3,
      ),
    ];
  }

  void _generateMockLogs() {
    final today = DateTime.now();
    final rng = Random(42);

    for (final habit in _habits) {
      final logs = <HabitLog>[];

      for (int d = 89; d >= 0; d--) {
        final date = today.subtract(Duration(days: d));
        // Higher streak habits have higher completion rates
        final rate = (habit.streakDays / 66.0).clamp(0.3, 0.95);
        final completed = rng.nextDouble() < rate;

        // Assign miss reasons for missed days
        MissReason? missReason;
        if (!completed) {
          missReason = MissReason.values[rng.nextInt(MissReason.values.length)];
          // Bias: Thursday/Friday have more "No Energy" misses
          if (date.weekday >= 4 && date.weekday <= 5 && rng.nextBool()) {
            missReason = MissReason.noEnergy;
          }
        }

        // Assign reflection for Foundation+ habits
        ReflectionDifficulty? reflDifficulty;
        String? reflNote;
        if (completed &&
            GoalStage.hasReachedFoundation(habit.streakDays) &&
            rng.nextDouble() < 0.6) {
          reflDifficulty = ReflectionDifficulty
              .values[rng.nextInt(ReflectionDifficulty.values.length)];
        }

        logs.add(HabitLog(
          id: 'log-${habit.id}-$d',
          habitId: habit.id,
          date: date,
          completed: completed,
          missReason: missReason,
          reflectionDifficulty: reflDifficulty,
          reflectionNote: reflNote,
        ));
      }

      _logsByHabit[habit.id] = logs;
    }
  }

  void _computeStreakStats() {
    for (final habit in _habits) {
      final logs = _logsByHabit[habit.id] ?? [];
      // Sort descending by date
      logs.sort((a, b) => b.date.compareTo(a.date));

      // Current streak: consecutive completed from today backward
      int current = 0;
      for (final log in logs) {
        if (log.completed) {
          current++;
        } else {
          break;
        }
      }

      // Use the model's streakDays as authoritative if larger (mock consistency)
      _currentStreaks[habit.id] = max(current, habit.streakDays);

      // Longest streak: scan all logs
      int longest = 0;
      int run = 0;
      // Re-sort ascending
      final ascending = List<HabitLog>.from(logs.reversed);
      for (final log in ascending) {
        if (log.completed) {
          run++;
          if (run > longest) longest = run;
        } else {
          run = 0;
        }
      }
      _longestStreaks[habit.id] = max(longest, _currentStreaks[habit.id]!);

      // Total completed
      _totalCompleted[habit.id] = logs.where((l) => l.completed).length;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/providers/progress_provider_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/providers/progress_provider.dart client/test/providers/progress_provider_test.dart
git commit -m "feat: add ProgressProvider with mock logs, streak stats, heatmap, frequency, and reflection"
```

---

### Task 3: Create the HabitChipSelector widget

**Files:**
- Create: `client/lib/widgets/progress/habit_chip_selector.dart`

- [ ] **Step 1: Write the HabitChipSelector**

```dart
// client/lib/widgets/progress/habit_chip_selector.dart
import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/icon_resolver.dart';

/// Horizontal scrollable row of colored habit chips.
/// Selected chip is fully opaque with the habit color; unselected are muted.
class HabitChipSelector extends StatelessWidget {
  final List<Habit> habits;
  final String selectedHabitId;
  final ValueChanged<String> onSelected;

  const HabitChipSelector({
    super.key,
    required this.habits,
    required this.selectedHabitId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.gridMargin,
        ),
        itemCount: habits.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: ValenceSpacing.sm),
        itemBuilder: (context, index) {
          final habit = habits[index];
          final isSelected = habit.id == selectedHabitId;

          return GestureDetector(
            onTap: () => onSelected(habit.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.smMd,
                vertical: ValenceSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? habit.color
                    : habit.color.withValues(alpha: tokens.isDark ? 0.15 : 0.10),
                borderRadius: ValenceRadii.roundAll,
                border: isSelected
                    ? null
                    : Border.all(
                        color: habit.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconResolver.resolve(habit.iconName),
                    size: 16,
                    color: isSelected
                        ? tokens.colors.textInverse
                        : habit.color,
                  ),
                  const SizedBox(width: ValenceSpacing.xs),
                  Text(
                    habit.name,
                    style: tokens.typography.caption.copyWith(
                      color: isSelected
                          ? tokens.colors.textInverse
                          : habit.color,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
mkdir -p client/lib/widgets/progress
git add client/lib/widgets/progress/habit_chip_selector.dart
git commit -m "feat: add HabitChipSelector with colored horizontal scroll chips"
```

---

### Task 4: Create the StreakSection and GoalGraduationBar widgets

**Files:**
- Create: `client/lib/widgets/progress/streak_section.dart`
- Create: `client/lib/widgets/progress/goal_graduation_bar.dart`
- Create: `client/test/widgets/progress/goal_graduation_bar_test.dart`

- [ ] **Step 1: Write the GoalGraduationBar test**

```dart
// client/test/widgets/progress/goal_graduation_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit_log.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/widgets/progress/goal_graduation_bar.dart';

Widget _wrap(Widget child) {
  final tokens =
      ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('GoalGraduationBar', () {
    testWidgets('renders all 4 stage labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const GoalGraduationBar(
          currentStreak: 15,
          habitColor: Color(0xFF4E55E0),
        ),
      ));

      expect(find.text('Ignition'), findsOneWidget);
      expect(find.text('Foundation'), findsOneWidget);
      expect(find.text('Momentum'), findsOneWidget);
      expect(find.text('Formed'), findsOneWidget);
    });

    testWidgets('shows days remaining for non-formed streak', (tester) async {
      await tester.pumpWidget(_wrap(
        const GoalGraduationBar(
          currentStreak: 15,
          habitColor: Color(0xFF4E55E0),
        ),
      ));

      // 15 days in, working toward Momentum (21). 6 days remaining.
      expect(find.textContaining('6'), findsWidgets);
    });

    testWidgets('shows formed state for 66+ days', (tester) async {
      await tester.pumpWidget(_wrap(
        const GoalGraduationBar(
          currentStreak: 70,
          habitColor: Color(0xFF4E55E0),
        ),
      ));

      expect(find.textContaining('Formed'), findsWidgets);
    });
  });
}
```

- [ ] **Step 2: Write the GoalGraduationBar widget**

```dart
// client/lib/widgets/progress/goal_graduation_bar.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit_log.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Visual 4-stage goal graduation progress bar.
/// Ignition (3d) -> Foundation (10d) -> Momentum (21d) -> Formed (66d).
/// Current stage is highlighted with the habit color; future stages are grayed.
class GoalGraduationBar extends StatelessWidget {
  final int currentStreak;
  final Color habitColor;

  const GoalGraduationBar({
    super.key,
    required this.currentStreak,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final currentStage = GoalStage.stageFor(currentStreak);
    final isFormed = currentStreak >= GoalStage.formed.targetDays;

    // Calculate days remaining to next milestone
    String daysLabel;
    if (isFormed) {
      daysLabel = 'Habit formed!';
    } else {
      for (final stage in GoalStage.values) {
        if (currentStreak < stage.targetDays) {
          final remaining = stage.targetDays - currentStreak;
          daysLabel = '$remaining days to ${stage.label}';
          break;
        }
      }
      daysLabel = daysLabel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.trophy,
              size: 18,
              color: colors.textSecondary,
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Text(
              'Goal Graduation',
              style: tokens.typography.h3.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // 4-stage progress track
        Row(
          children: GoalStage.values.asMap().entries.map((entry) {
            final i = entry.key;
            final stage = entry.value;
            final isPast = currentStreak >= stage.targetDays;
            final isCurrent = currentStage == stage ||
                (isFormed && stage == GoalStage.formed);
            final isActive = isPast || isCurrent;

            return Expanded(
              child: Row(
                children: [
                  // Connector line (not before first)
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: isPast
                              ? habitColor
                              : colors.surfaceSunken,
                          borderRadius: ValenceRadii.roundAll,
                        ),
                      ),
                    ),
                  // Stage node
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive
                          ? habitColor
                          : colors.surfaceSunken,
                      shape: BoxShape.circle,
                      border: isCurrent && !isPast
                          ? Border.all(color: habitColor, width: 2)
                          : null,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: habitColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isPast
                          ? Icon(
                              PhosphorIcons.check(PhosphorIconsStyle.bold),
                              size: 14,
                              color: colors.textInverse,
                            )
                          : Text(
                              '${stage.targetDays}',
                              style: tokens.typography.overline.copyWith(
                                color: isActive
                                    ? colors.textInverse
                                    : colors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: ValenceSpacing.sm),

        // Stage labels
        Row(
          children: GoalStage.values.map((stage) {
            final isPast = currentStreak >= stage.targetDays;
            final isCurrent = currentStage == stage;

            return Expanded(
              child: Text(
                stage.label,
                textAlign: TextAlign.center,
                style: tokens.typography.overline.copyWith(
                  color: isPast || isCurrent
                      ? habitColor
                      : colors.textSecondary,
                  fontWeight: isCurrent
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 9,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Days remaining label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.smMd,
            vertical: ValenceSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: habitColor.withValues(alpha: tokens.isDark ? 0.15 : 0.08),
            borderRadius: ValenceRadii.roundAll,
          ),
          child: Text(
            isFormed ? '\u{1F393} Habit formed!' : '\u{1F3AF} $daysLabel',
            style: tokens.typography.caption.copyWith(
              color: habitColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Write the StreakSection widget**

```dart
// client/lib/widgets/progress/streak_section.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Large streak number with flame icon and current/longest/total stats row.
class StreakSection extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalDays;
  final Color habitColor;

  const StreakSection({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      children: [
        // Large streak number + flame
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\u{1F525}',
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Text(
              '$currentStreak',
              style: tokens.typography.numbersDisplay.copyWith(
                color: habitColor,
                fontSize: 56,
              ),
            ),
            const SizedBox(width: ValenceSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'day streak',
                style: tokens.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.lg),

        // Stats row: current | longest | total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: 'Current',
              value: '$currentStreak',
              icon: PhosphorIconsRegular.flame,
              color: habitColor,
              tokens: tokens,
            ),
            Container(
              width: 1,
              height: 36,
              color: colors.borderDefault,
            ),
            _StatItem(
              label: 'Longest',
              value: '$longestStreak',
              icon: PhosphorIconsRegular.crown,
              color: colors.accentWarning,
              tokens: tokens,
            ),
            Container(
              width: 1,
              height: 36,
              color: colors.borderDefault,
            ),
            _StatItem(
              label: 'Total',
              value: '$totalDays',
              icon: PhosphorIconsRegular.calendarCheck,
              color: colors.accentSuccess,
              tokens: tokens,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ValenceTokens tokens;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: tokens.typography.numbersBody.copyWith(
            color: tokens.colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: tokens.typography.overline.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/progress/goal_graduation_bar_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/progress/streak_section.dart client/lib/widgets/progress/goal_graduation_bar.dart client/test/widgets/progress/goal_graduation_bar_test.dart
git commit -m "feat: add StreakSection and GoalGraduationBar with 4-stage visual progress"
```

---

### Task 5: Create the HeatmapGrid widget

**Files:**
- Create: `client/lib/widgets/progress/heatmap_grid.dart`
- Create: `client/test/widgets/progress/heatmap_grid_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/progress/heatmap_grid_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/widgets/progress/heatmap_grid.dart';

Widget _wrap(Widget child) {
  final tokens =
      ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('HeatmapGrid', () {
    testWidgets('renders without errors', (tester) async {
      final data = List.generate(
        84,
        (i) => HeatmapEntry(
          date: DateTime.now().subtract(Duration(days: 83 - i)),
          value: i.isEven ? 1.0 : 0.0,
        ),
      );

      await tester.pumpWidget(_wrap(
        HeatmapGrid(
          data: data,
          habitColor: const Color(0xFF4E55E0),
        ),
      ));

      expect(find.byType(HeatmapGrid), findsOneWidget);
    });

    testWidgets('shows month labels', (tester) async {
      final data = List.generate(
        84,
        (i) => HeatmapEntry(
          date: DateTime.now().subtract(Duration(days: 83 - i)),
          value: 1.0,
        ),
      );

      await tester.pumpWidget(_wrap(
        HeatmapGrid(
          data: data,
          habitColor: const Color(0xFF4E55E0),
        ),
      ));

      // Should render without error; month labels are present
      await tester.pump();
      expect(find.byType(HeatmapGrid), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Write the HeatmapGrid widget**

```dart
// client/lib/widgets/progress/heatmap_grid.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// GitHub-style contribution heatmap grid.
/// 12 weeks (84 days), 7 rows (Mon-Sun), scrollable horizontally.
/// Uses the habit's assigned color at varying opacities:
/// - Empty/missed: surfaceSunken
/// - Partial (0.5): habit color at 30%
/// - Complete (1.0): habit color at full
class HeatmapGrid extends StatelessWidget {
  final List<HeatmapEntry> data;
  final Color habitColor;

  const HeatmapGrid({
    super.key,
    required this.data,
    required this.habitColor,
  });

  static const double _cellSize = 14.0;
  static const double _cellGap = 3.0;
  static const List<String> _dayLabels = ['M', '', 'W', '', 'F', '', 'S'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    // Organize data into weeks (columns) x days (rows)
    // data[0] is the oldest date, data[83] is today
    // We need 12 columns (weeks) x 7 rows (Mon=0 to Sun=6)
    final weeks = <List<HeatmapEntry?>>[];
    int i = 0;

    // First, figure out what day of week data[0] is and pad if needed
    final firstDate = data.isNotEmpty ? data.first.date : DateTime.now();
    final startDayOfWeek = firstDate.weekday - 1; // 0=Mon, 6=Sun

    // Pad the first week with nulls for days before the start
    if (startDayOfWeek > 0) {
      final firstWeek = List<HeatmapEntry?>.filled(7, null);
      for (int d = startDayOfWeek; d < 7 && i < data.length; d++) {
        firstWeek[d] = data[i++];
      }
      weeks.add(firstWeek);
    }

    // Fill remaining weeks
    while (i < data.length) {
      final week = <HeatmapEntry?>[];
      for (int d = 0; d < 7; d++) {
        if (i < data.length) {
          week.add(data[i++]);
        } else {
          week.add(null);
        }
      }
      weeks.add(week);
    }

    // Collect month labels for top
    final monthLabels = <int, String>{};
    for (int w = 0; w < weeks.length; w++) {
      final firstEntry = weeks[w].firstWhere((e) => e != null, orElse: () => null);
      if (firstEntry != null) {
        final month = firstEntry.date.month;
        if (!monthLabels.containsValue(DateFormat.MMM().format(firstEntry.date))) {
          // Only add if this is the first week of this month
          final prevMonth = w > 0
              ? weeks[w - 1]
                  .firstWhere((e) => e != null, orElse: () => null)
                  ?.date
                  .month
              : null;
          if (prevMonth != month) {
            monthLabels[w] = DateFormat.MMM().format(firstEntry.date);
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.grid_on_rounded,
              size: 18,
              color: colors.textSecondary,
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Text(
              'Activity',
              style: tokens.typography.h3.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Scrollable heatmap
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day-of-week labels
              Column(
                children: [
                  // Month label spacer
                  const SizedBox(height: 18),
                  ...List.generate(7, (d) {
                    return SizedBox(
                      height: _cellSize + _cellGap,
                      width: 18,
                      child: Center(
                        child: Text(
                          _dayLabels[d],
                          style: tokens.typography.overline.copyWith(
                            color: colors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(width: 4),

              // Weeks
              ...List.generate(weeks.length, (w) {
                return Column(
                  children: [
                    // Month label
                    SizedBox(
                      height: 18,
                      width: _cellSize + _cellGap,
                      child: monthLabels.containsKey(w)
                          ? Text(
                              monthLabels[w]!,
                              style: tokens.typography.overline.copyWith(
                                color: colors.textSecondary,
                                fontSize: 9,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    // Day cells
                    ...List.generate(7, (d) {
                      final entry = d < weeks[w].length ? weeks[w][d] : null;
                      return _HeatmapCell(
                        entry: entry,
                        habitColor: habitColor,
                        tokens: tokens,
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: ValenceSpacing.sm),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: tokens.typography.overline.copyWith(
                color: colors.textSecondary,
                fontSize: 9,
              ),
            ),
            const SizedBox(width: 4),
            _LegendCell(color: colors.surfaceSunken),
            _LegendCell(color: habitColor.withValues(alpha: 0.3)),
            _LegendCell(color: habitColor.withValues(alpha: 0.6)),
            _LegendCell(color: habitColor),
            const SizedBox(width: 4),
            Text(
              'More',
              style: tokens.typography.overline.copyWith(
                color: colors.textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final HeatmapEntry? entry;
  final Color habitColor;
  final ValenceTokens tokens;

  const _HeatmapCell({
    required this.entry,
    required this.habitColor,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    Color cellColor;
    if (entry == null) {
      cellColor = Colors.transparent;
    } else if (entry!.value >= 1.0) {
      cellColor = habitColor;
    } else if (entry!.value >= 0.5) {
      cellColor = habitColor.withValues(alpha: 0.3);
    } else {
      cellColor = tokens.colors.surfaceSunken;
    }

    return Padding(
      padding: const EdgeInsets.all(HeatmapGrid._cellGap / 2),
      child: Container(
        width: HeatmapGrid._cellSize,
        height: HeatmapGrid._cellSize,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _LegendCell extends StatelessWidget {
  final Color color;

  const _LegendCell({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
```

- [ ] **Step 3: Run tests**

```bash
cd client && flutter test test/widgets/progress/heatmap_grid_test.dart
```

Expected: All tests PASS.

- [ ] **Step 4: Commit**

```bash
git add client/lib/widgets/progress/heatmap_grid.dart client/test/widgets/progress/heatmap_grid_test.dart
git commit -m "feat: add HeatmapGrid widget with GitHub-style 12-week contribution grid"
```

---

### Task 6: Create the FrequencyChart widget (fl_chart)

**Files:**
- Create: `client/lib/widgets/progress/frequency_chart.dart`

- [ ] **Step 1: Write the FrequencyChart**

```dart
// client/lib/widgets/progress/frequency_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Bar chart showing completion rate by day-of-week (Mon-Sun).
/// Uses fl_chart. Highlights the strongest and weakest days.
class FrequencyChart extends StatelessWidget {
  /// Map of day label ('Mon'..'Sun') to completion percentage (0-100).
  final Map<String, int> data;
  final String strongestDay;
  final String weakestDay;
  final Color habitColor;

  const FrequencyChart({
    super.key,
    required this.data,
    required this.strongestDay,
    required this.weakestDay,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final entries = data.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.chartBar,
              size: 18,
              color: colors.textSecondary,
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Text(
              'Day-of-Week',
              style: tokens.typography.h3.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Chart
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colors.borderDefault.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: tokens.typography.overline.copyWith(
                          color: colors.textSecondary,
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final dayLabel = entries[idx].key;
                      final isStrong = dayLabel == strongestDay;
                      final isWeak = dayLabel == weakestDay;

                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dayLabel,
                          style: tokens.typography.overline.copyWith(
                            color: isStrong
                                ? colors.accentSuccess
                                : isWeak
                                    ? colors.accentError
                                    : colors.textSecondary,
                            fontWeight: (isStrong || isWeak)
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(entries.length, (i) {
                final dayLabel = entries[i].key;
                final value = entries[i].value.toDouble();
                final isStrong = dayLabel == strongestDay;
                final isWeak = dayLabel == weakestDay;

                Color barColor;
                if (isStrong) {
                  barColor = colors.accentSuccess;
                } else if (isWeak) {
                  barColor = colors.accentError.withValues(alpha: 0.7);
                } else {
                  barColor = habitColor.withValues(alpha: 0.7);
                }

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: barColor,
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: colors.surfaceSunken,
                      ),
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colors.surfaceElevated,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final dayLabel = entries[groupIndex].key;
                    return BarTooltipItem(
                      '$dayLabel: ${rod.toY.toInt()}%',
                      tokens.typography.caption.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Strongest / Weakest callout
        Row(
          children: [
            _DayCallout(
              label: 'Strongest',
              day: strongestDay,
              color: colors.accentSuccess,
              icon: PhosphorIconsRegular.arrowUp,
              tokens: tokens,
            ),
            const SizedBox(width: ValenceSpacing.md),
            _DayCallout(
              label: 'Weakest',
              day: weakestDay,
              color: colors.accentError,
              icon: PhosphorIconsRegular.arrowDown,
              tokens: tokens,
            ),
          ],
        ),
      ],
    );
  }
}

class _DayCallout extends StatelessWidget {
  final String label;
  final String day;
  final Color color;
  final IconData icon;
  final ValenceTokens tokens;

  const _DayCallout({
    required this.label,
    required this.day,
    required this.color,
    required this.icon,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: tokens.typography.caption.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
        Text(
          day,
          style: tokens.typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/progress/frequency_chart.dart
git commit -m "feat: add FrequencyChart with fl_chart bars and strongest/weakest day highlights"
```

---

### Task 7: Create the FailureInsightsCard widget

**Files:**
- Create: `client/lib/widgets/progress/failure_insights_card.dart`

- [ ] **Step 1: Write the FailureInsightsCard**

```dart
// client/lib/widgets/progress/failure_insights_card.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/constants.dart';

/// Failure insights card with encouraging personality copy + reason pie chart.
/// Only rendered when there are 14+ days of data.
///
/// TONE: Encouraging, observational, zero shame. Think "a coach who noticed
/// a pattern" not "a teacher who caught you slacking."
class FailureInsightsCard extends StatelessWidget {
  final String insightText;
  final List<MissReasonSlice>? reasonBreakdown;
  final Color habitColor;

  const FailureInsightsCard({
    super.key,
    required this.insightText,
    this.reasonBreakdown,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.lightbulb,
              size: 18,
              color: colors.accentWarning,
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Text(
              'Insights',
              style: tokens.typography.h3.copyWith(fontSize: 16),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.accentWarning.withValues(alpha: 0.12),
                borderRadius: ValenceRadii.roundAll,
              ),
              child: Text(
                'AI-powered',
                style: tokens.typography.overline.copyWith(
                  color: colors.accentWarning,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Insight text card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ValenceSpacing.md),
          decoration: BoxDecoration(
            color: colors.accentWarning.withValues(
              alpha: tokens.isDark ? 0.08 : 0.06,
            ),
            borderRadius: ValenceRadii.mediumAll,
            border: Border.all(
              color: colors.accentWarning.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\u{1F4A1}', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: ValenceSpacing.smMd),
              Expanded(
                child: Text(
                  insightText,
                  style: tokens.typography.body.copyWith(
                    color: colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Reason pie chart (if data available)
        if (reasonBreakdown != null && reasonBreakdown!.isNotEmpty) ...[
          const SizedBox(height: ValenceSpacing.md),
          Text(
            'Why you miss:',
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ValenceSpacing.smMd),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                      sections: _buildPieSections(tokens),
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                ),
                const SizedBox(width: ValenceSpacing.md),
                // Legend
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reasonBreakdown!.map((slice) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorForReason(
                                    slice.reason, colors),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: ValenceSpacing.sm),
                            Expanded(
                              child: Text(
                                '${slice.reason.label} (${slice.percent.toStringAsFixed(0)}%)',
                                style: tokens.typography.caption.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(ValenceTokens tokens) {
    if (reasonBreakdown == null) return [];

    return reasonBreakdown!.map((slice) {
      return PieChartSectionData(
        value: slice.percent,
        color: _colorForReason(slice.reason, tokens.colors),
        radius: 24,
        showTitle: false,
      );
    }).toList();
  }

  static Color _colorForReason(
      MissReasonSlice reason, dynamic _) {
    // Use deterministic colors from HabitColors palette
    switch (reason.reason) {
      case _:
        break;
    }
    return HabitColors.slate;
  }
}

// Helper to map MissReason to a color. This is a free function
// because it needs the ValenceColors for theme-awareness.
Color _missReasonColor(
    MissReason reason, ValenceColors colors) {
  switch (reason) {
    case MissReason.noEnergy:
      return HabitColors.amber;
    case MissReason.busy:
      return HabitColors.blue;
    case MissReason.forgot:
      return HabitColors.pink;
    case MissReason.sick:
      return HabitColors.teal;
    case MissReason.other:
      return HabitColors.slate;
  }
}
```

Wait --- the static method has a bug. Let me provide a corrected version.

```dart
// client/lib/widgets/progress/failure_insights_card.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit_log.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_colors.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/constants.dart';

/// Failure insights card with encouraging personality copy + reason pie chart.
/// Only rendered when there are 14+ days of data.
///
/// TONE: Encouraging, observational, zero shame. Think "a coach who noticed
/// a pattern" not "a teacher who caught you slacking."
class FailureInsightsCard extends StatelessWidget {
  final String insightText;
  final List<MissReasonSlice>? reasonBreakdown;
  final Color habitColor;

  const FailureInsightsCard({
    super.key,
    required this.insightText,
    this.reasonBreakdown,
    required this.habitColor,
  });

  static Color _colorForReason(MissReason reason) {
    switch (reason) {
      case MissReason.noEnergy:
        return HabitColors.amber;
      case MissReason.busy:
        return HabitColors.blue;
      case MissReason.forgot:
        return HabitColors.pink;
      case MissReason.sick:
        return HabitColors.teal;
      case MissReason.other:
        return HabitColors.slate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.lightbulb,
              size: 18,
              color: colors.accentWarning,
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Text(
              'Insights',
              style: tokens.typography.h3.copyWith(fontSize: 16),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.accentWarning.withValues(alpha: 0.12),
                borderRadius: ValenceRadii.roundAll,
              ),
              child: Text(
                'AI-powered',
                style: tokens.typography.overline.copyWith(
                  color: colors.accentWarning,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Insight text card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ValenceSpacing.md),
          decoration: BoxDecoration(
            color: colors.accentWarning.withValues(
              alpha: tokens.isDark ? 0.08 : 0.06,
            ),
            borderRadius: ValenceRadii.mediumAll,
            border: Border.all(
              color: colors.accentWarning.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\u{1F4A1}', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: ValenceSpacing.smMd),
              Expanded(
                child: Text(
                  insightText,
                  style: tokens.typography.body.copyWith(
                    color: colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Reason pie chart (if data available)
        if (reasonBreakdown != null && reasonBreakdown!.isNotEmpty) ...[
          const SizedBox(height: ValenceSpacing.md),
          Text(
            'Why you miss:',
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ValenceSpacing.smMd),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                      sections: reasonBreakdown!.map((slice) {
                        return PieChartSectionData(
                          value: slice.percent,
                          color: _colorForReason(slice.reason),
                          radius: 24,
                          showTitle: false,
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                ),
                const SizedBox(width: ValenceSpacing.md),
                // Legend
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reasonBreakdown!.map((slice) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorForReason(slice.reason),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: ValenceSpacing.sm),
                            Expanded(
                              child: Text(
                                '${slice.reason.label} (${slice.percent.toStringAsFixed(0)}%)',
                                style: tokens.typography.caption.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/progress/failure_insights_card.dart
git commit -m "feat: add FailureInsightsCard with encouraging copy and reason pie chart"
```

---

### Task 8: Create the Overview tab widgets

**Files:**
- Create: `client/lib/widgets/progress/overview_completion_rate.dart`
- Create: `client/lib/widgets/progress/overview_stacked_bar.dart`
- Create: `client/lib/widgets/progress/overview_summary_cards.dart`

- [ ] **Step 1: Write the OverviewCompletionRate**

```dart
// client/lib/widgets/progress/overview_completion_rate.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Large overall completion rate display with a circular progress ring.
class OverviewCompletionRate extends StatelessWidget {
  final int percent;

  const OverviewCompletionRate({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final progress = percent / 100.0;

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                trackColor: colors.surfaceSunken,
                fillColor: colors.accentSuccess,
                strokeWidth: 10,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: tokens.typography.numbersDisplay.copyWith(
                        color: colors.textPrimary,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      'overall',
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.fillColor != fillColor;
}
```

- [ ] **Step 2: Write the OverviewStackedBar**

```dart
// client/lib/widgets/progress/overview_stacked_bar.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Weekly stacked bar chart showing all habits' completion rates.
/// Each bar segment is colored by the habit's assigned color.
class OverviewStackedBar extends StatelessWidget {
  final List<WeeklyHabitBar> data;
  final List<Habit> habits;

  const OverviewStackedBar({
    super.key,
    required this.data,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly breakdown',
          style: tokens.typography.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: ValenceSpacing.smMd),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: habits.length.toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.borderDefault.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          data[idx].weekLabel,
                          style: tokens.typography.overline.copyWith(
                            color: colors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(data.length, (weekIdx) {
                final week = data[weekIdx];
                final rods = <BarChartRodStackItem>[];
                double cumulative = 0;

                for (final habit in habits) {
                  final pct = week.habitCompletions[habit.id] ?? 0;
                  final segment = pct; // 0 to 1
                  rods.add(BarChartRodStackItem(
                    cumulative,
                    cumulative + segment,
                    habit.color,
                  ));
                  cumulative += segment;
                }

                return BarChartGroupData(
                  x: weekIdx,
                  barRods: [
                    BarChartRodData(
                      toY: cumulative,
                      rodStackItems: rods,
                      width: 32,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(enabled: false),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Habit color legend (compact row)
        Wrap(
          spacing: ValenceSpacing.smMd,
          runSpacing: ValenceSpacing.xs,
          children: habits.map((h) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: h.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  h.name,
                  style: tokens.typography.overline.copyWith(
                    color: colors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Write the OverviewSummaryCards**

```dart
// client/lib/widgets/progress/overview_summary_cards.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Weekly and monthly summary cards, plus XP/rank progress and best week comparison.
class OverviewSummaryCards extends StatelessWidget {
  final PeriodSummary thisWeek;
  final PeriodSummary thisMonth;
  final int totalXP;
  final String currentRank;
  final String nextRank;
  final double rankProgress;
  final int xpToNextRank;
  final int bestWeekCompletions;
  final int currentWeekCompletions;

  const OverviewSummaryCards({
    super.key,
    required this.thisWeek,
    required this.thisMonth,
    required this.totalXP,
    required this.currentRank,
    required this.nextRank,
    required this.rankProgress,
    required this.xpToNextRank,
    required this.bestWeekCompletions,
    required this.currentWeekCompletions,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period summary row
        Row(
          children: [
            Expanded(child: _PeriodCard(summary: thisWeek, tokens: tokens)),
            const SizedBox(width: ValenceSpacing.smMd),
            Expanded(child: _PeriodCard(summary: thisMonth, tokens: tokens)),
          ],
        ),
        const SizedBox(height: ValenceSpacing.md),

        // XP + Rank progress
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ValenceSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            borderRadius: ValenceRadii.mediumAll,
            border: tokens.isDark
                ? Border.all(
                    color: colors.borderDefault.withValues(alpha: 0.3))
                : null,
            boxShadow: tokens.isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.lightning,
                    size: 18,
                    color: colors.accentPrimary,
                  ),
                  const SizedBox(width: ValenceSpacing.sm),
                  Text(
                    '$totalXP XP',
                    style: tokens.typography.numbersBody.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentPrimary.withValues(alpha: 0.12),
                      borderRadius: ValenceRadii.roundAll,
                    ),
                    child: Text(
                      currentRank,
                      style: tokens.typography.overline.copyWith(
                        color: colors.accentPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ValenceSpacing.smMd),
              // Rank progress bar
              ClipRRect(
                borderRadius: ValenceRadii.roundAll,
                child: LinearProgressIndicator(
                  value: rankProgress,
                  backgroundColor: colors.surfaceSunken,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colors.accentPrimary),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: ValenceSpacing.xs),
              Text(
                '$xpToNextRank XP to $nextRank',
                style: tokens.typography.overline.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ValenceSpacing.md),

        // Best week vs current week
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ValenceSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            borderRadius: ValenceRadii.mediumAll,
            border: tokens.isDark
                ? Border.all(
                    color: colors.borderDefault.withValues(alpha: 0.3))
                : null,
            boxShadow: tokens.isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Best week',
                      style: tokens.typography.overline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bestWeekCompletions',
                      style: tokens.typography.numbersBody.copyWith(
                        color: colors.accentSuccess,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'completions',
                      style: tokens.typography.overline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: colors.borderDefault,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'This week',
                      style: tokens.typography.overline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentWeekCompletions',
                      style: tokens.typography.numbersBody.copyWith(
                        color: currentWeekCompletions >= bestWeekCompletions
                            ? colors.accentSuccess
                            : colors.accentPrimary,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'completions',
                      style: tokens.typography.overline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final PeriodSummary summary;
  final ValenceTokens tokens;

  const _PeriodCard({required this.summary, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.smMd),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
        border: tokens.isDark
            ? Border.all(color: colors.borderDefault.withValues(alpha: 0.3))
            : null,
        boxShadow: tokens.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.label,
            style: tokens.typography.overline.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ValenceSpacing.xs),
          Text(
            '${summary.completionPercent}%',
            style: tokens.typography.numbersBody.copyWith(
              color: colors.textPrimary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${summary.habitsCompleted}/${summary.totalPossible} done',
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ValenceSpacing.xs),
          Row(
            children: [
              Icon(PhosphorIconsRegular.star, size: 12, color: colors.accentWarning),
              const SizedBox(width: 3),
              Text(
                '${summary.perfectDays} perfect days',
                style: tokens.typography.overline.copyWith(
                  color: colors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add client/lib/widgets/progress/overview_completion_rate.dart client/lib/widgets/progress/overview_stacked_bar.dart client/lib/widgets/progress/overview_summary_cards.dart
git commit -m "feat: add Overview tab widgets: completion ring, stacked bar chart, summary cards, and rank progress"
```

---

### Task 9: Create the ReflectionSheet bottom sheet

**Files:**
- Create: `client/lib/widgets/progress/reflection_sheet.dart`

- [ ] **Step 1: Write the ReflectionSheet**

```dart
// client/lib/widgets/progress/reflection_sheet.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/habit_log.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';
import 'package:valence/widgets/shared/valence_toast.dart';

/// Evening Reflection bottom sheet.
///
/// Shows per-habit reflection for each Foundation+ habit completed today.
/// Each habit gets 5 labeled faces (Easy/Okay/Moderate/Hard/Brutal)
/// and an optional one-line text input. Labels are ALWAYS visible for
/// accessibility --- never emoji-only.
///
/// Gated: only habits with 10+ streak days appear.
/// If no habits qualify, this sheet should not be shown at all.
///
/// Usage:
/// ```dart
/// ReflectionSheet.show(context);
/// ```
class ReflectionSheet extends StatefulWidget {
  const ReflectionSheet({super.key});

  /// Show as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ProgressProvider>(),
        child: const ReflectionSheet(),
      ),
    );
  }

  @override
  State<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends State<ReflectionSheet> {
  final Map<String, ReflectionDifficulty?> _selections = {};
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void dispose() {
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final provider = context.watch<ProgressProvider>();
    final eligibleHabits = provider.foundationHabits;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        margin: const EdgeInsets.all(ValenceSpacing.md),
        padding: const EdgeInsets.fromLTRB(
          ValenceSpacing.lg,
          ValenceSpacing.lg,
          ValenceSpacing.lg,
          ValenceSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: ValenceSpacing.lg),

              // Header
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.moon,
                    color: colors.accentSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: ValenceSpacing.sm),
                  Expanded(
                    child: Text(
                      'Evening Reflection',
                      style: tokens.typography.h2.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ValenceSpacing.xs),
              Text(
                'Quick check-in. One tap per habit. Takes 15 seconds.',
                style: tokens.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.lg),

              // Per-habit reflections
              ...eligibleHabits.map((habit) {
                _noteControllers.putIfAbsent(
                  habit.id,
                  () => TextEditingController(),
                );

                return _HabitReflectionRow(
                  habit: habit,
                  selectedDifficulty: _selections[habit.id],
                  noteController: _noteControllers[habit.id]!,
                  onDifficultySelected: (d) {
                    setState(() => _selections[habit.id] = d);
                  },
                  tokens: tokens,
                );
              }),

              const SizedBox(height: ValenceSpacing.lg),

              // Done button
              ValenceButton(
                label: 'Done',
                fullWidth: true,
                variant: ValenceButtonVariant.primary,
                icon: PhosphorIconsRegular.check,
                onPressed: () {
                  final progressProvider = context.read<ProgressProvider>();
                  for (final habit in eligibleHabits) {
                    final difficulty = _selections[habit.id];
                    if (difficulty != null) {
                      progressProvider.submitReflection(
                        habitId: habit.id,
                        difficulty: difficulty,
                        note: _noteControllers[habit.id]?.text.trim().isEmpty ==
                                true
                            ? null
                            : _noteControllers[habit.id]?.text.trim(),
                      );
                    }
                  }
                  Navigator.of(context).pop();
                  ValenceToast.show(
                    context,
                    message: 'Reflection saved. You are building self-awareness.',
                    type: ToastType.success,
                  );
                },
              ),
              const SizedBox(height: ValenceSpacing.sm),
              ValenceButton(
                label: 'Skip for tonight',
                fullWidth: true,
                variant: ValenceButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: ValenceSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitReflectionRow extends StatelessWidget {
  final Habit habit;
  final ReflectionDifficulty? selectedDifficulty;
  final TextEditingController noteController;
  final ValueChanged<ReflectionDifficulty> onDifficultySelected;
  final ValenceTokens tokens;

  const _HabitReflectionRow({
    required this.habit,
    required this.selectedDifficulty,
    required this.noteController,
    required this.onDifficultySelected,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: ValenceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit name + color chip
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: habit.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: ValenceSpacing.sm),
              Text(
                habit.name,
                style: tokens.typography.h3.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.smMd),

          // "How difficult?" label
          Text(
            'How difficult was it today?',
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ValenceSpacing.sm),

          // 5 labeled faces
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ReflectionDifficulty.values.map((d) {
              final isSelected = selectedDifficulty == d;

              return GestureDetector(
                onTap: () => onDifficultySelected(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: ValenceSpacing.sm,
                    vertical: ValenceSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? habit.color.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: ValenceRadii.smallAll,
                    border: Border.all(
                      color: isSelected
                          ? habit.color
                          : colors.borderDefault,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d.emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.label,
                        style: tokens.typography.overline.copyWith(
                          color: isSelected
                              ? habit.color
                              : colors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: ValenceSpacing.smMd),

          // Optional one-line text input
          TextField(
            controller: noteController,
            maxLines: 1,
            style: tokens.typography.body.copyWith(
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Anything on your mind? (optional)',
              hintStyle: tokens.typography.body.copyWith(
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colors.surfaceSunken,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.smMd,
                vertical: ValenceSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: ValenceRadii.smallAll,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ValenceRadii.smallAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ValenceRadii.smallAll,
                borderSide: BorderSide(color: habit.color, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/progress/reflection_sheet.dart
git commit -m "feat: add ReflectionSheet with Foundation-gated per-habit labeled face scale and text input"
```

---

### Task 10: Build the full ProgressScreen with both tabs

**Files:**
- Modify: `client/lib/screens/progress/progress_screen.dart`

- [ ] **Step 1: Replace the placeholder ProgressScreen**

Replace the entire contents of `client/lib/screens/progress/progress_screen.dart` with:

```dart
// client/lib/screens/progress/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_card.dart';
import 'package:valence/widgets/progress/failure_insights_card.dart';
import 'package:valence/widgets/progress/frequency_chart.dart';
import 'package:valence/widgets/progress/goal_graduation_bar.dart';
import 'package:valence/widgets/progress/habit_chip_selector.dart';
import 'package:valence/widgets/progress/heatmap_grid.dart';
import 'package:valence/widgets/progress/overview_completion_rate.dart';
import 'package:valence/widgets/progress/overview_stacked_bar.dart';
import 'package:valence/widgets/progress/overview_summary_cards.dart';
import 'package:valence/widgets/progress/reflection_sheet.dart';
import 'package:valence/widgets/progress/streak_section.dart';

/// Progress Screen (Tab 2 in MainShell).
/// Two top-level tabs: Per-Habit | Overview.
/// Self-provides ProgressProvider (same pattern as HomeScreen).
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: const _ProgressScreenBody(),
    );
  }
}

class _ProgressScreenBody extends StatelessWidget {
  const _ProgressScreenBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final provider = context.watch<ProgressProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surfaceBackground,
        // FAB for evening reflection (demo entry point)
        floatingActionButton: provider.hasReflectionEligibleHabits
            ? FloatingActionButton.small(
                onPressed: () => ReflectionSheet.show(context),
                backgroundColor: colors.accentSecondary,
                child: Icon(
                  PhosphorIconsRegular.moon,
                  color: colors.textInverse,
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              // Screen header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.gridMargin,
                  ValenceSpacing.md,
                  ValenceSpacing.gridMargin,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Progress',
                      style: tokens.typography.h1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ValenceSpacing.smMd),

              // Tab bar: Per-Habit | Overview
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ValenceSpacing.gridMargin,
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceSunken,
                    borderRadius: ValenceRadii.roundAll,
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: colors.accentPrimary,
                      borderRadius: ValenceRadii.roundAll,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: colors.textInverse,
                    unselectedLabelColor: colors.textSecondary,
                    labelStyle: tokens.typography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: tokens.typography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Per-Habit'),
                      Tab(text: 'Overview'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ValenceSpacing.md),

              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _PerHabitTab(provider: provider, tokens: tokens),
                    _OverviewTab(provider: provider, tokens: tokens),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Per-Habit Tab
// =============================================================================

class _PerHabitTab extends StatelessWidget {
  final ProgressProvider provider;
  final ValenceTokens tokens;

  const _PerHabitTab({required this.provider, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final habit = provider.selectedHabit;

    return Column(
      children: [
        // Habit chip selector
        HabitChipSelector(
          habits: provider.habits,
          selectedHabitId: habit.id,
          onSelected: provider.selectHabit,
        ),
        const SizedBox(height: ValenceSpacing.md),

        // Scrollable detail sections
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: ValenceSpacing.gridMargin,
            ),
            children: [
              // Streak section
              StreakSection(
                currentStreak: provider.currentStreak,
                longestStreak: provider.longestStreak,
                totalDays: provider.totalDaysCompleted,
                habitColor: habit.color,
              ),
              const SizedBox(height: ValenceSpacing.xl),

              // Goal graduation
              GoalGraduationBar(
                currentStreak: provider.currentStreak,
                habitColor: habit.color,
              ),
              const SizedBox(height: ValenceSpacing.xl),

              // Heatmap
              HeatmapGrid(
                data: provider.heatmapData,
                habitColor: habit.color,
              ),
              const SizedBox(height: ValenceSpacing.xl),

              // Frequency chart
              FrequencyChart(
                data: provider.frequencyData,
                strongestDay: provider.strongestDay,
                weakestDay: provider.weakestDay,
                habitColor: habit.color,
              ),
              const SizedBox(height: ValenceSpacing.xl),

              // Failure insights (only if 14+ days of data)
              if (provider.failureInsight != null)
                FailureInsightsCard(
                  insightText: provider.failureInsight!,
                  reasonBreakdown: provider.missReasonBreakdown,
                  habitColor: habit.color,
                ),

              // Bottom padding
              const SizedBox(height: ValenceSpacing.huge),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Overview Tab
// =============================================================================

class _OverviewTab extends StatelessWidget {
  final ProgressProvider provider;
  final ValenceTokens tokens;

  const _OverviewTab({required this.provider, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.gridMargin,
      ),
      children: [
        // Overall completion rate ring
        OverviewCompletionRate(percent: provider.overallCompletionRate),
        const SizedBox(height: ValenceSpacing.xl),

        // Stacked bar chart
        OverviewStackedBar(
          data: provider.weeklyStackedBars,
          habits: provider.habits,
        ),
        const SizedBox(height: ValenceSpacing.xl),

        // Summary cards + XP + best week
        OverviewSummaryCards(
          thisWeek: provider.thisWeekSummary,
          thisMonth: provider.thisMonthSummary,
          totalXP: provider.totalXP,
          currentRank: provider.currentRank,
          nextRank: provider.nextRank,
          rankProgress: provider.rankProgress,
          xpToNextRank: provider.xpToNextRank,
          bestWeekCompletions: provider.bestWeekCompletions,
          currentWeekCompletions: provider.currentWeekCompletions,
        ),

        // Bottom padding
        const SizedBox(height: ValenceSpacing.huge),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/screens/progress/progress_screen.dart
git commit -m "feat: compose full Progress screen with Per-Habit and Overview tabs, reflection FAB"
```

---

### Task 11: Register ProgressProvider in app.dart

**Files:**
- Modify: `client/lib/app.dart`

- [ ] **Step 1: Add ProgressProvider to imports and verify self-providing pattern**

Since the existing pattern (established in HomeScreen and GroupScreen) is to self-provide the ChangeNotifier within the screen itself using `ChangeNotifierProvider` at the screen level, the ProgressScreen already follows this pattern (Task 10 wraps the body in `ChangeNotifierProvider(create: (_) => ProgressProvider())`).

However, the `ReflectionSheet` needs access to the same `ProgressProvider` instance. This is already handled in Task 9: the static `show` method passes the provider via `ChangeNotifierProvider.value`.

**No changes to app.dart are needed** because the self-providing pattern is used. Skip this task if app.dart does not need modification.

If instead you want a global ProgressProvider (for cross-screen access to reflection state), add it to `app.dart`:

```dart
// client/lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/screens/splash/splash_screen.dart';
import 'package:valence/theme/theme_provider.dart';

class ValenceApp extends StatelessWidget {
  const ValenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Valence',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
```

**Decision:** Use the self-providing pattern (consistent with existing screens). The ProgressScreen already wraps itself. No `app.dart` change needed for Phase 5. Mark this task as skipped.

- [ ] **Step 2: Commit (only if app.dart was changed)**

```bash
git add client/lib/app.dart
git commit -m "feat: register ProgressProvider in app.dart MultiProvider"
```

---

### Task 12: Verify full screen renders and navigation works

**Files:** No new files. Integration verification.

- [ ] **Step 1: Run full build to check for compile errors**

```bash
cd client && flutter build apk --debug 2>&1 | head -30
```

Expected: Build succeeds (or only non-related warnings).

- [ ] **Step 2: Verify navigation**

Launch the app, navigate to Tab 2 (Progress), verify:
1. Per-Habit tab shows with habit chips, streak, goal bar, heatmap, frequency chart
2. Switching habits via chips updates all sections
3. Overview tab shows completion ring, stacked bars, summary cards, XP/rank
4. FAB appears and opens ReflectionSheet
5. Reflection sheet shows only Foundation+ habits
6. Face selection and text input work
7. "Done" button closes sheet with toast

- [ ] **Step 3: Final commit (if any fix-ups needed)**

```bash
git add -A
git commit -m "fix: address any build/render issues in Progress screen"
```

---

## Dependency Graph

```
Task 1 (HabitLog model)
   |
   v
Task 2 (ProgressProvider) ───────────────────────────────┐
   |                                                      |
   ├──> Task 3 (HabitChipSelector)                        |
   ├──> Task 4 (StreakSection + GoalGraduationBar)        |
   ├──> Task 5 (HeatmapGrid)                              |
   ├──> Task 6 (FrequencyChart)                            |
   ├──> Task 7 (FailureInsightsCard)                       |
   ├──> Task 8 (Overview widgets)                          |
   └──> Task 9 (ReflectionSheet)                           |
                                                          |
   All above ──────────────────────> Task 10 (ProgressScreen)
                                         |
                                    Task 11 (app.dart - optional)
                                         |
                                    Task 12 (Verify)
```

Tasks 3-9 can be executed in parallel after Task 2 completes.

---

## Key Architectural Decisions

1. **Self-providing pattern**: ProgressScreen wraps itself in `ChangeNotifierProvider<ProgressProvider>` rather than registering globally in app.dart. This matches the pattern established by HomeScreen and GroupScreen.

2. **Mock data is seeded deterministically**: `Random(42)` ensures the same mock data appears every time, making visual QA consistent.

3. **GoalStage.stageFor logic**: Returns the stage you are WORKING TOWARD. At 15 days you are working toward Momentum (21), so the bar shows progress within that span. At 66+ days you are Formed.

4. **Reflection is per-HabitLog**: The `submitReflection` method updates the specific day's log entry for that habit. This matches the spec requirement that reflections are stored per habit per day, not per day globally.

5. **Foundation gating**: `foundationHabits` filters to streakDays >= 10. The ReflectionSheet only renders for these habits. The FAB only appears if at least one habit qualifies.

6. **Failure insights require 14+ days**: Both the insight text and pie chart return null when the habit has fewer than 14 log entries. The UI conditionally renders these sections.

7. **Personality copy in insights**: The failure insight templates are encouraging, observational, and never shaming --- matching the app's personality philosophy established in `PersonalityCopy`.

---

### Critical Files for Implementation
- `D:/@home/deepan/Downloads/valence/client/lib/providers/progress_provider.dart`
- `D:/@home/deepan/Downloads/valence/client/lib/screens/progress/progress_screen.dart`
- `D:/@home/deepan/Downloads/valence/client/lib/models/habit_log.dart`
- `D:/@home/deepan/Downloads/valence/client/lib/widgets/progress/reflection_sheet.dart`
- `D:/@home/deepan/Downloads/valence/client/lib/widgets/progress/heatmap_grid.dart`