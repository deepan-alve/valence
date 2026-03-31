// client/lib/services/api_client.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Thrown when the server returns a non-OK response.
class ApiException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  const ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException($statusCode): $code — $message';
}

/// Base HTTP client for the Valence API.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final data = await client.get('/habits');
/// ```
///
/// Every request automatically attaches the Firebase ID token as
/// `Authorization: Bearer <token>`. If Firebase is not configured,
/// the request proceeds without auth (dev/offline mode).
class ApiClient {
  /// Change this to your production URL before shipping.
  static const String _baseUrl = 'http://10.0.2.2:3000/api/v1';

  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  // Dev bypass: set this to a real user ID when running without Firebase
  // to use the server's X-Dev-User-Id header shortcut (NODE_ENV=development only).
  static String? devUserId;

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (devUserId != null) {
      headers['X-Dev-User-Id'] = devUserId!;
      return headers;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Firebase not configured or user not signed in — proceed without auth
    }

    return headers;
  }

  dynamic _parse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'];
    }
    final err = body['error'] as Map<String, dynamic>? ?? {};
    throw ApiException(
      code: err['code'] as String? ?? 'UNKNOWN',
      message: err['message'] as String? ?? response.body,
      statusCode: response.statusCode,
    );
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (query != null) uri = uri.replace(queryParameters: query);
    final response = await http.get(uri, headers: await _headers());
    return _parse(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _parse(response);
  }
}
