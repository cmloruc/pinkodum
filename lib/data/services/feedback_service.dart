import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_config.dart';
import 'auth_service.dart';

class FeedbackService {
  static const types = {
    'dilek': 'Dilek',
    'sikayet': 'Şikayet',
    'talep': 'Talep',
    'diger': 'Diğer',
  };

  static Future<void> send({
    required String type,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    final token = auth.token;
    if (token == null) throw Exception('Giriş yapmanız gerekiyor.');

    final res = await http.post(
      Uri.parse('${AppConfig.backendBaseUrl}/feedback'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({'type': type, 'message': message}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Geri bildirim gönderilemedi.');
    }
  }
}
