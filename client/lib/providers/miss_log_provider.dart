// client/lib/providers/miss_log_provider.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:valence/models/miss_log.dart';

/// Manages miss logging state and recovery card visibility.
///
/// In a live app, logs would be persisted + synced to the backend.
/// Here, logs are session-only (cleared on app restart).
class MissLogProvider extends ChangeNotifier {
  final List<MissLog> _recentLogs = [];
  bool _showRecoveryCard = false;
  int _consecutiveMissDays = 0;

  // Mock: simulate that yesterday had a miss on first load (demo purposes).
  // Set to false to start clean.
  static const bool _mockHasYesterdayMiss = false;

  MissLogProvider() {
    if (_mockHasYesterdayMiss) {
      _showRecoveryCard = true;
      _consecutiveMissDays = 1;
    }
  }

  // --- Getters ---

  List<MissLog> get recentLogs => List.unmodifiable(_recentLogs);
  bool get showRecoveryCard => _showRecoveryCard;
  int get consecutiveMissDays => _consecutiveMissDays;

  bool hasMissedHabit(String habitId) =>
      _recentLogs.any((log) => log.habitId == habitId);

  // --- Actions ---

  /// Record a miss for a habit.
  void logMiss({
    required String habitId,
    required String habitName,
    required MissReason reason,
    String? reasonText,
  }) {
    _recentLogs.add(MissLog(
      id: 'ml_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      habitId: habitId,
      habitName: habitName,
      date: DateTime.now(),
      reason: reason,
      reasonText: reasonText,
    ));
    notifyListeners();
  }

  /// Called by the app shell on launch to show the recovery card
  /// if the previous session had misses.
  void setRecoveryCard({required bool show, int consecutiveDays = 1}) {
    _showRecoveryCard = show;
    _consecutiveMissDays = consecutiveDays;
    notifyListeners();
  }

  void dismissRecoveryCard() {
    _showRecoveryCard = false;
    notifyListeners();
  }
}
