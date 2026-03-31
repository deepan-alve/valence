// client/lib/services/social_service.dart
import 'api_client.dart';

/// Wraps /social endpoints: nudge, kudos.
class SocialService {
  final ApiClient _client;
  SocialService({ApiClient? client}) : _client = client ?? ApiClient();

  /// POST /social/nudge — send an AI-personalised nudge to a group member.
  Future<Map<String, dynamic>> sendNudge({
    required String receiverId,
    required String groupId,
  }) async {
    final data = await _client.post('/social/nudge', body: {
      'receiver_id': receiverId,
      'group_id': groupId,
    });
    return data as Map<String, dynamic>;
  }

  /// POST /social/kudos — send kudos to a group member.
  Future<Map<String, dynamic>> sendKudos({
    required String receiverId,
    required String groupId,
  }) async {
    final data = await _client.post('/social/kudos', body: {
      'receiver_id': receiverId,
      'group_id': groupId,
    });
    return data as Map<String, dynamic>;
  }
}
