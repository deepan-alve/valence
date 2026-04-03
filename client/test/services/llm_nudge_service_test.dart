// client/test/services/llm_nudge_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/services/llm_nudge_service.dart';

void main() {
  group('LlmNudgeService', () {
    late LlmNudgeService service;

    setUp(() {
      service = LlmNudgeService();
    });

    test('generateNudgeMessage returns a non-empty string', () async {
      final msg = await service.generateNudgeMessage(
        receiverName: 'Ravi',
        habitName: 'LeetCode',
        streakDays: 8,
        recentMissReasons: [],
      );
      expect(msg, isNotEmpty);
      expect(msg.length, greaterThan(10));
    });

    test('personalizes message with receiver name', () async {
      final msg = await service.generateNudgeMessage(
        receiverName: 'Priya',
        habitName: 'Gym',
        streakDays: 5,
        recentMissReasons: ['busy'],
      );
      expect(msg.toLowerCase(), contains('priya'));
    });

    test('returns fallback when useMock is true', () async {
      final fallbackService = LlmNudgeService(useMock: true);
      final msg = await fallbackService.generateNudgeMessage(
        receiverName: 'Sam',
        habitName: 'Read',
        streakDays: 3,
        recentMissReasons: [],
      );
      expect(msg, isNotEmpty);
    });

    test('generateMorningActivation returns non-empty string', () async {
      final msg = await service.generateMorningActivation(
        userName: 'Diana',
        friendsCompleted: 2,
      );
      expect(msg, isNotEmpty);
    });

    test('generatePreemptiveWarning returns non-empty string', () async {
      final msg = await service.generatePreemptiveWarning(
        habitName: 'LeetCode',
        missPattern: 'Thursday evenings',
      );
      expect(msg, isNotEmpty);
    });
  });
}
