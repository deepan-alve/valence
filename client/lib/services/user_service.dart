// client/lib/services/user_service.dart
import 'api_client.dart';

/// Wraps /users endpoints: profile, XP, shop.
class UserService {
  final ApiClient _client;
  UserService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /users/me — fetch the current user's full profile.
  Future<Map<String, dynamic>> fetchMe() async {
    final data = await _client.get('/users/me');
    return data as Map<String, dynamic>;
  }

  /// PATCH /users/me — update display name or persona.
  Future<Map<String, dynamic>> updateMe({
    String? name,
    String? personaType,
  }) async {
    final data = await _client.patch('/users/me', body: {
      if (name != null) 'name': name,
      if (personaType != null) 'persona_type': personaType,
    });
    return data as Map<String, dynamic>;
  }

  /// GET /users/me/stats — XP history, streak stats, habit graduation counts.
  Future<Map<String, dynamic>> fetchStats() async {
    final data = await _client.get('/users/me/stats');
    return data as Map<String, dynamic>;
  }
}
