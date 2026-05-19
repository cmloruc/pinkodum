import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_config.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;
  const AuthUser({required this.id, required this.email, required this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: (json['name'] as String?) ?? '',
      );
}

class AuthService {
  static const _tokenKey = 'auth_jwt_token';
  static const _userKey = 'auth_user_json';

  final SharedPreferences _prefs;
  AuthService(this._prefs);

  String? get token => _prefs.getString(_tokenKey);
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  AuthUser? get currentUser {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/auth/register'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'email': email, 'name': name, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(_extractError(body));
    }
    return _handleAuthResponse(body);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/auth/login'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_extractError(body));
    }
    return _handleAuthResponse(body);
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  Future<AuthUser> _handleAuthResponse(Map<String, dynamic> body) async {
    final token = body['token'] as String;
    final user = AuthUser.fromJson(body['user'] as Map<String, dynamic>);
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode({
      'id': user.id,
      'email': user.email,
      'name': user.name,
    }));
    return user;
  }

  String _extractError(Map<String, dynamic> body) {
    final msg = body['message'];
    if (msg is String) return msg;
    if (msg is List) return msg.join(', ');
    return 'Bir hata oluştu.';
  }
}
