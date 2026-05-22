import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_config.dart';

class AdminStats {
  final int totalUsers;
  final int totalAnalyses;
  final int premiumUsers;
  final int newUsersToday;
  final List<AnalysisTypeStat> analysesByType;

  const AdminStats({
    required this.totalUsers,
    required this.totalAnalyses,
    required this.premiumUsers,
    required this.newUsersToday,
    required this.analysesByType,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        totalUsers: (json['totalUsers'] as int?) ?? 0,
        totalAnalyses: (json['totalAnalyses'] as int?) ?? 0,
        premiumUsers: (json['premiumUsers'] as int?) ?? 0,
        newUsersToday: (json['newUsersToday'] as int?) ?? 0,
        analysesByType: (json['analysesByType'] as List<dynamic>? ?? [])
            .map((e) => AnalysisTypeStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AnalysisTypeStat {
  final String type;
  final int count;
  const AnalysisTypeStat({required this.type, required this.count});
  factory AnalysisTypeStat.fromJson(Map<String, dynamic> json) =>
      AnalysisTypeStat(
        type: json['type'] as String,
        count: (json['count'] as int?) ?? 0,
      );
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final int credits;
  final bool isPremium;
  final bool isAdmin;
  final DateTime? premiumUntil;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.credits,
    required this.isPremium,
    required this.isAdmin,
    this.premiumUntil,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: (json['name'] as String?) ?? '',
        credits: (json['credits'] as int?) ?? 0,
        isPremium: (json['isPremium'] as bool?) ?? false,
        isAdmin: (json['isAdmin'] as bool?) ?? false,
        premiumUntil: json['premiumUntil'] == null
            ? null
            : DateTime.parse(json['premiumUntil'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AdminService {
  final String token;
  AdminService(this.token);

  Map<String, String> get _headers => {
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

  Future<AdminStats> getStats() async {
    final res = await http
        .get(Uri.parse('${AppConfig.backendBaseUrl}/admin/stats'),
            headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('İstatistikler alınamadı.');
    return AdminStats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<AdminUser>> getUsers() async {
    final res = await http
        .get(Uri.parse('${AppConfig.backendBaseUrl}/admin/users'),
            headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Kullanıcılar alınamadı.');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> setCredits(String userId, int credits) async {
    final res = await http
        .patch(
          Uri.parse('${AppConfig.backendBaseUrl}/admin/users/$userId/credits'),
          headers: _headers,
          body: jsonEncode({'credits': credits}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Kredi güncellenemedi.');
  }

  Future<AiConfig> getAiConfig() async {
    final res = await http
        .get(Uri.parse('${AppConfig.backendBaseUrl}/admin/ai-config'),
            headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('AI config alınamadı.');
    return AiConfig.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<AiBillingSummary> getAiBilling() async {
    final res = await http
        .get(Uri.parse('${AppConfig.backendBaseUrl}/admin/ai-billing'),
            headers: _headers)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw Exception('AI maliyet özeti alınamadı.');
    return AiBillingSummary.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> setPremium(String userId, {required bool activate}) async {
    final res = await http
        .patch(
          Uri.parse('${AppConfig.backendBaseUrl}/admin/users/$userId/premium'),
          headers: _headers,
          body: jsonEncode({'activate': activate}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Premium durumu güncellenemedi.');
  }

  Future<List<AdminFeedback>> getFeedbacks() async {
    final res = await http
        .get(Uri.parse('${AppConfig.backendBaseUrl}/feedback'),
            headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Geri bildirimler alınamadı.');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => AdminFeedback.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markFeedbackRead(String id) async {
    await http
        .patch(Uri.parse('${AppConfig.backendBaseUrl}/feedback/$id/read'),
            headers: _headers)
        .timeout(const Duration(seconds: 10));
  }

  Future<BroadcastResult> sendBroadcast(
    String title,
    String message, {
    required String type,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/admin/push/broadcast'),
          headers: _headers,
          body: jsonEncode({'title': title, 'message': message, 'type': type}),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 201) throw Exception('Bildirim gönderilemedi.');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return BroadcastResult(
      sent: (json['sent'] as int?) ?? 0,
      failed: (json['failed'] as int?) ?? 0,
    );
  }

  Future<AiConfig> setAiConfig(String provider, String model,
      {String? apiKey}) async {
    final res = await http
        .patch(
          Uri.parse('${AppConfig.backendBaseUrl}/admin/ai-config'),
          headers: _headers,
          body: jsonEncode({
            'provider': provider,
            'model': model,
            if (apiKey != null) 'apiKey': apiKey
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('AI config güncellenemedi.');
    return AiConfig.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

class BroadcastResult {
  final int sent;
  final int failed;
  const BroadcastResult({required this.sent, required this.failed});
}

class AdminFeedback {
  final String id;
  final String? userEmail;
  final String? userName;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const AdminFeedback({
    required this.id,
    this.userEmail,
    this.userName,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminFeedback.fromJson(Map<String, dynamic> json) => AdminFeedback(
        id: json['id'] as String,
        userEmail: json['userEmail'] as String?,
        userName: json['userName'] as String?,
        type: json['type'] as String,
        message: json['message'] as String,
        isRead: (json['isRead'] as bool?) ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String get typeLabel {
    switch (type) {
      case 'dilek':
        return 'Dilek';
      case 'sikayet':
        return 'Şikayet';
      case 'talep':
        return 'Talep';
      default:
        return 'Diğer';
    }
  }
}

class AiConfig {
  final String provider;
  final String model;
  final String apiKeyMasked;

  const AiConfig(
      {required this.provider,
      required this.model,
      required this.apiKeyMasked});

  factory AiConfig.fromJson(Map<String, dynamic> json) => AiConfig(
        provider: json['provider'] as String,
        model: json['model'] as String,
        apiKeyMasked: json['apiKeyMasked'] as String,
      );
}

class AiBillingSummary {
  final DateTime periodStart;
  final DateTime periodEnd;
  final bool remainingBalanceSupported;
  final List<AiBillingProvider> providers;

  const AiBillingSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.remainingBalanceSupported,
    required this.providers,
  });

  factory AiBillingSummary.fromJson(Map<String, dynamic> json) =>
      AiBillingSummary(
        periodStart: DateTime.parse(json['periodStart'] as String),
        periodEnd: DateTime.parse(json['periodEnd'] as String),
        remainingBalanceSupported:
            (json['remainingBalanceSupported'] as bool?) ?? false,
        providers: (json['providers'] as List<dynamic>? ?? [])
            .map((e) => AiBillingProvider.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AiBillingProvider {
  final String provider;
  final String label;
  final double? monthSpendUsd;
  final String status;
  final String? missingSecret;
  final String? message;

  const AiBillingProvider({
    required this.provider,
    required this.label,
    required this.monthSpendUsd,
    required this.status,
    this.missingSecret,
    this.message,
  });

  factory AiBillingProvider.fromJson(Map<String, dynamic> json) =>
      AiBillingProvider(
        provider: json['provider'] as String,
        label: json['label'] as String,
        monthSpendUsd: (json['monthSpendUsd'] as num?)?.toDouble(),
        status: json['status'] as String,
        missingSecret: json['missingSecret'] as String?,
        message: json['message'] as String?,
      );
}
