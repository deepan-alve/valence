// client/lib/services/group_service.dart
import 'api_client.dart';

/// Wraps all /groups API endpoints.
class GroupService {
  final ApiClient _client;
  GroupService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /groups — list groups the current user belongs to.
  Future<List<dynamic>> fetchGroups() async {
    final data = await _client.get('/groups');
    return (data as List).cast<dynamic>();
  }

  /// POST /groups — create a new group.
  Future<Map<String, dynamic>> createGroup(String name) async {
    final data = await _client.post('/groups', body: {'name': name});
    return data as Map<String, dynamic>;
  }

  /// POST /groups/join — join a group with invite code.
  Future<Map<String, dynamic>> joinGroup(String inviteCode) async {
    final data = await _client.post('/groups/join', body: {'invite_code': inviteCode});
    return data as Map<String, dynamic>;
  }

  /// GET /groups/:id — full group detail with members.
  Future<Map<String, dynamic>> fetchGroup(String groupId) async {
    final data = await _client.get('/groups/$groupId');
    return data as Map<String, dynamic>;
  }

  /// GET /groups/:id/feed — paginated feed for a group.
  Future<List<dynamic>> fetchFeed(String groupId, {int limit = 30, String? before}) async {
    final data = await _client.get(
      '/groups/$groupId/feed',
      query: {
        'limit': '$limit',
        if (before != null) 'before': before,
      },
    );
    return (data as List).cast<dynamic>();
  }

  /// GET /groups/:id/streak — current group streak + chain links.
  Future<Map<String, dynamic>> fetchStreak(String groupId) async {
    final data = await _client.get('/groups/$groupId/streak');
    return data as Map<String, dynamic>;
  }

  /// GET /groups/:id/leaderboard — weekly scores.
  Future<List<dynamic>> fetchLeaderboard(String groupId, {String period = 'week'}) async {
    final data = await _client.get('/groups/$groupId/leaderboard', query: {'period': period});
    return (data as List).cast<dynamic>();
  }

  /// POST /groups/:id/freeze — use a streak freeze.
  Future<Map<String, dynamic>> useStreakFreeze(String groupId) async {
    final data = await _client.post('/groups/$groupId/freeze');
    return data as Map<String, dynamic>;
  }
}
