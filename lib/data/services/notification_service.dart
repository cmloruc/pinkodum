import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: (json['type'] as String?) ?? 'affirmation',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationService {
  final String token;

  const NotificationService(this.token);

  Map<String, String> get _headers => {
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

  Future<List<AppNotification>> getUnread() async {
    final res = await http
        .get(
          Uri.parse('${AppConfig.backendBaseUrl}/notifications'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Bildirimler alınamadı.');
    }

    return (jsonDecode(res.body) as List<dynamic>)
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    final res = await http
        .patch(
          Uri.parse('${AppConfig.backendBaseUrl}/notifications/$id/read'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Bildirim okundu olarak işaretlenemedi.');
    }
  }
}
