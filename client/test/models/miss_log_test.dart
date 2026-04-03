// client/test/models/miss_log_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/miss_log.dart';

void main() {
  group('MissReason', () {
    test('has 5 quick-select options matching design spec 2.10', () {
      expect(MissReason.values.length, 5);
      expect(MissReason.values, contains(MissReason.sick));
      expect(MissReason.values, contains(MissReason.busy));
      expect(MissReason.values, contains(MissReason.forgot));
      expect(MissReason.values, contains(MissReason.noEnergy));
      expect(MissReason.values, contains(MissReason.other));
    });

    test('displayLabel returns human-readable chip text', () {
      expect(MissReason.sick.displayLabel, 'Sick');
      expect(MissReason.noEnergy.displayLabel, 'No Energy');
    });
  });

  group('MissLog', () {
    test('constructs with required fields', () {
      final log = MissLog(
        id: 'ml_1',
        habitId: 'h1',
        habitName: 'LeetCode',
        date: DateTime(2026, 3, 30),
        reason: MissReason.busy,
      );
      expect(log.id, 'ml_1');
      expect(log.reason, MissReason.busy);
      expect(log.reasonText, isNull);
    });

    test('accepts optional free-text reason', () {
      final log = MissLog(
        id: 'ml_2',
        habitId: 'h2',
        habitName: 'Gym',
        date: DateTime(2026, 3, 30),
        reason: MissReason.other,
        reasonText: 'Had a family emergency',
      );
      expect(log.reasonText, 'Had a family emergency');
    });
  });
}
