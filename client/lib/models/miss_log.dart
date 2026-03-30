// client/lib/models/miss_log.dart

/// The reason a user chose when logging a missed habit.
/// Maps to the quick-select chips in design spec 2.10.
enum MissReason {
  sick('Sick'),
  busy('Busy'),
  forgot('Forgot'),
  noEnergy('No Energy'),
  other('Other');

  final String displayLabel;
  const MissReason(this.displayLabel);
}

/// A recorded miss for a single habit on a single day.
class MissLog {
  final String id;
  final String habitId;
  final String habitName;
  final DateTime date;
  final MissReason reason;

  /// Optional free-text elaboration (design spec 2.10: "Tell us more").
  final String? reasonText;

  const MissLog({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.date,
    required this.reason,
    this.reasonText,
  });
}
