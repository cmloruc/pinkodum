import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_config.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;
  final DateTime? birthDate;
  final int credits;
  final bool isPremium;
  final bool isAdmin;
  final DateTime? premiumUntil;
  final int monthlySingleRemaining;
  final int monthlyRelationshipRemaining;
  final DateTime? premiumQuotaResetAt;
  final DateTime? dailyInsightUntil;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.birthDate,
    this.credits = 0,
    this.isPremium = false,
    this.isAdmin = false,
    this.premiumUntil,
    this.monthlySingleRemaining = 0,
    this.monthlyRelationshipRemaining = 0,
    this.premiumQuotaResetAt,
    this.dailyInsightUntil,
  });

  bool get hasActivePremium =>
      isPremium &&
      premiumUntil != null &&
      premiumUntil!.isAfter(DateTime.now());

  bool get hasDailyInsightAccess =>
      isAdmin ||
      hasActivePremium ||
      (dailyInsightUntil != null && dailyInsightUntil!.isAfter(DateTime.now()));

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: (json['name'] as String?) ?? '',
        birthDate: json['birthDate'] == null
            ? null
            : DateTime.parse(json['birthDate'] as String),
        credits: (json['credits'] as int?) ?? 0,
        isPremium: (json['isPremium'] as bool?) ?? false,
        isAdmin: (json['isAdmin'] as bool?) ?? false,
        premiumUntil: _parseDate(json['premiumUntil']),
        monthlySingleRemaining: (json['monthlySingleRemaining'] as int?) ?? 0,
        monthlyRelationshipRemaining:
            (json['monthlyRelationshipRemaining'] as int?) ?? 0,
        premiumQuotaResetAt: _parseDate(json['premiumQuotaResetAt']),
        dailyInsightUntil: _parseDate(json['dailyInsightUntil']),
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.parse(value);
    }
    return null;
  }
}

class AuthService {
  static const _tokenKey = 'auth_jwt_token';
  static const _userKey = 'auth_user_json';
  static final authChanges = ValueNotifier<int>(0);

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
    required DateTime birthDate,
    required String password,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/auth/register'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'name': name,
            'birthDate': birthDate.toIso8601String(),
            'password': password,
          }),
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

  Future<AuthUser?> fetchMe() async {
    if (!isLoggedIn) return null;
    final res = await http.get(
      Uri.parse('${AppConfig.backendBaseUrl}/auth/me'),
      headers: {
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final user =
        AuthUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    authChanges.value++;
  }

  Future<void> cacheUser(AuthUser user) async {
    await _saveUser(user);
    authChanges.value++;
  }

  Future<AuthUser> _handleAuthResponse(Map<String, dynamic> body) async {
    final token = body['token'] as String;
    final user = AuthUser.fromJson(body['user'] as Map<String, dynamic>);
    await _prefs.setString(_tokenKey, token);
    await _saveUser(user);
    authChanges.value++;
    return user;
  }

  Future<void> _saveUser(AuthUser user) async {
    await _prefs.setString(
        _userKey,
        jsonEncode({
          'id': user.id,
          'email': user.email,
          'name': user.name,
          'birthDate': user.birthDate?.toIso8601String(),
          'credits': user.credits,
          'isPremium': user.isPremium,
          'isAdmin': user.isAdmin,
          'premiumUntil': user.premiumUntil?.toIso8601String(),
          'monthlySingleRemaining': user.monthlySingleRemaining,
          'monthlyRelationshipRemaining': user.monthlyRelationshipRemaining,
          'premiumQuotaResetAt': user.premiumQuotaResetAt?.toIso8601String(),
          'dailyInsightUntil': user.dailyInsightUntil?.toIso8601String(),
        }));
  }

  String _extractError(Map<String, dynamic> body) {
    final msg = body['message'];
    if (msg is String) return msg;
    if (msg is List) return msg.join(', ');
    return 'Bir hata oluştu.';
  }
}
