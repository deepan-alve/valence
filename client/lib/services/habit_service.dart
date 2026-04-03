// client/lib/services/habit_service.dart
import 'api_client.dart';

/// Wraps all /habits API endpoints.
class HabitService {
  final ApiClient _client;
  HabitService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /habits — returns list of active habits with today's completion status.
  Future<List<dynamic>> fetchHabits() async {
    final data = await _client.get('/habits');
    return (data as List).cast<dynamic>();
  }

  /// POST /habits — create a new habit.
  Future<Map<String, dynamic>> createHabit({
    required String name,
    String intensity = 'moderate',
    String trackingMethod = 'manual',
    String? pluginId,
    String? redirectUrl,
    String visibility = 'full',
  }) async {
    final data = await _client.post('/habits', body: {
      'name': name,
      'intensity': intensity,
      'tracking_method': trackingMethod,
      if (pluginId != null) 'plugin_id': pluginId,
      if (redirectUrl != null) 'redirect_url': redirectUrl,
      'visibility': visibility,
      'frequency_rule': {'type': 'daily'},
    });
    return data as Map<String, dynamic>;
  }

  /// PATCH /habits/:id — update an existing habit.
  Future<Map<String, dynamic>> updateHabit(
    String habitId, {
    String? name,
    String? intensity,
    String? redirectUrl,
    String? visibility,
  }) async {
    final data = await _client.patch('/habits/$habitId', body: {
      if (name != null) 'name': name,
      if (intensity != null) 'intensity': intensity,
      if (redirectUrl != null) 'redirect_url': redirectUrl,
      if (visibility != null) 'visibility': visibility,
    });
    return data as Map<String, dynamic>;
  }

  /// DELETE /habits/:id — archive (soft-delete) a habit.
  Future<void> deleteHabit(String habitId) async {
    await _client.delete('/habits/$habitId');
  }

  /// POST /habits/:id/complete — mark a habit done for today.
  /// Returns { habit, points: { xpAwarded, sparksAwarded, newRank? }, perfectDay, milestoneReward }.
  Future<Map<String, dynamic>> completeHabit(
    String habitId, {
    String verificationSource = 'manual',
    String? proofUrl,
  }) async {
    final data = await _client.post('/habits/$habitId/complete', body: {
      'verification_source': verificationSource,
      if (proofUrl != null) 'proof_url': proofUrl,
    });
    return data as Map<String, dynamic>;
  }

  /// POST /habits/:id/miss — log a missed habit.
  Future<Map<String, dynamic>> missHabit(
    String habitId, {
    required String reasonCategory,
    String? reasonText,
  }) async {
    final data = await _client.post('/habits/$habitId/miss', body: {
      'reason_category': reasonCategory,
      if (reasonText != null) 'reason_text': reasonText,
    });
    return data as Map<String, dynamic>;
  }

  /// GET /habits/:id/logs — fetch completion logs (range: 'week' | 'month').
  Future<List<dynamic>> fetchLogs(String habitId, {String range = 'week'}) async {
    final data = await _client.get('/habits/$habitId/logs', query: {'range': range});
    return (data as List).cast<dynamic>();
  }
}
