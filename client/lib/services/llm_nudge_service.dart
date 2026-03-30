// client/lib/services/llm_nudge_service.dart
import 'dart:math';

/// Generates LLM-powered nudge messages.
///
/// Mock mode (default): selects from rotating template pools, personalizes
/// with name + habit. Matches the spec 2.8 requirement that the message is
/// "LLM-generated, read-only" — users see it but cannot edit.
///
/// Real mode: calls Gemini 2.5 Flash API via HTTP. Requires GEMINI_API_KEY
/// env var. Commented out until backend proxy is set up (Phase 9+ API layer).
///
/// Per spec 6.9 (LLM Fallback): if the real API fails, returns a template.
/// UI should show "Auto-generated nudge (AI is busy)" label when fallback used.
class LlmNudgeService {
  final bool useMock;
  static final _random = Random();

  LlmNudgeService({this.useMock = true});

  /// Whether the last call used a fallback template (UI can show the label).
  bool lastCallWasFallback = false;

  /// Generate a personalized nudge message for a friend.
  Future<String> generateNudgeMessage({
    required String receiverName,
    required String habitName,
    required int streakDays,
    required List<String> recentMissReasons,
  }) async {
    if (!useMock) {
      // TODO: Real Gemini 2.5 Flash call (Phase 9 API layer).
      // Fall through to mock on failure.
    }

    lastCallWasFallback = useMock;
    return _mockNudgeMessage(receiverName, habitName, streakDays);
  }

  /// Generate a morning activation notification message.
  Future<String> generateMorningActivation({
    required String userName,
    required int friendsCompleted,
  }) async {
    lastCallWasFallback = true;
    return _mockMorningActivation(userName, friendsCompleted);
  }

  /// Generate a preemptive warning message based on a miss pattern.
  Future<String> generatePreemptiveWarning({
    required String habitName,
    required String missPattern,
  }) async {
    lastCallWasFallback = true;
    return _mockPreemptiveWarning(habitName, missPattern);
  }

  String _mockNudgeMessage(String name, String habitName, int streakDays) {
    final templates = [
      '$name, your squad is rooting for you. One $habitName session stands between you and keeping the streak alive.',
      'Hey $name — $habitName is waiting. $streakDays days in, don\'t let today be the day you stop.',
      '$name, you\'ve been consistent. Today\'s $habitName is the one that keeps the momentum going.',
      'The group needs you today, $name. Even a short $habitName session counts. You\'ve got this.',
      '$name — $habitName. Today. You already know.',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  String _mockMorningActivation(String name, int friendsCompleted) {
    if (friendsCompleted == 0) {
      final templates = [
        'Rise and grind, $name — be the first one in the group to show up today.',
        'Morning, $name. Your habits are waiting. First mover energy.',
        'New day, $name. Let\'s make it count.',
      ];
      return templates[_random.nextInt(templates.length)];
    }
    final templates = [
      'Rise and grind — $name, $friendsCompleted people already knocked out habits before 9am.',
      '$name, $friendsCompleted friends already showed up today. Don\'t let them carry the team alone.',
      'Morning, $name. $friendsCompleted habits already done in your group. Your turn.',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  String _mockPreemptiveWarning(String habitName, String missPattern) {
    final templates = [
      '$missPattern — your kryptonite. Knock out $habitName now before the day gets away.',
      'Heads up: $missPattern is when you usually struggle with $habitName. Strike early today.',
      'Pattern alert: $habitName tends to slip during $missPattern. Get ahead of it.',
    ];
    return templates[_random.nextInt(templates.length)];
  }
}
