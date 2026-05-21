import 'dart:convert';

class PersonPremiumAnalysis {
  final String id;
  final String name;
  final DateTime birthDate;
  final List<int> pinCode;

  // 9 hane yorumları
  final String h1Personality;
  final String h2Social;
  final String h3Global;
  final String h4LifeCycle;
  final String h5Lesson;
  final String h6InnerSelf;
  final String h7InnerChild;
  final String h8Soul;
  final String h9Universe;

  // Derinlemesine bölümler
  final String elementDetail;
  final String lifeLesson;
  final String yearMessage;
  final String overallSummary;

  final DateTime createdAt;

  const PersonPremiumAnalysis({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.pinCode,
    required this.h1Personality,
    required this.h2Social,
    required this.h3Global,
    required this.h4LifeCycle,
    required this.h5Lesson,
    required this.h6InnerSelf,
    required this.h7InnerChild,
    required this.h8Soul,
    required this.h9Universe,
    required this.elementDetail,
    required this.lifeLesson,
    required this.yearMessage,
    required this.overallSummary,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'pinCode': pinCode,
        'h1Personality': h1Personality,
        'h2Social': h2Social,
        'h3Global': h3Global,
        'h4LifeCycle': h4LifeCycle,
        'h5Lesson': h5Lesson,
        'h6InnerSelf': h6InnerSelf,
        'h7InnerChild': h7InnerChild,
        'h8Soul': h8Soul,
        'h9Universe': h9Universe,
        'elementDetail': elementDetail,
        'lifeLesson': lifeLesson,
        'yearMessage': yearMessage,
        'overallSummary': overallSummary,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PersonPremiumAnalysis.fromJson(Map<String, dynamic> json) =>
      PersonPremiumAnalysis(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        pinCode: List<int>.from(json['pinCode'] as List),
        h1Personality: json['h1Personality'] as String,
        h2Social: json['h2Social'] as String,
        h3Global: json['h3Global'] as String,
        h4LifeCycle: json['h4LifeCycle'] as String,
        h5Lesson: json['h5Lesson'] as String,
        h6InnerSelf: json['h6InnerSelf'] as String,
        h7InnerChild: json['h7InnerChild'] as String,
        h8Soul: json['h8Soul'] as String,
        h9Universe: json['h9Universe'] as String,
        elementDetail: json['elementDetail'] as String,
        lifeLesson: json['lifeLesson'] as String,
        yearMessage: json['yearMessage'] as String,
        overallSummary: json['overallSummary'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  String get resolvedOverallSummary {
    if (overallSummary.trim().isNotEmpty) return overallSummary;

    final parts = [
      elementDetail,
      lifeLesson,
      yearMessage,
    ].where((text) => text.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return '$name, bu detaylı rapor pin kodundaki ana temaların birlikte okunmasıyla oluşur. Güçlü taraflarını bilinçli kullanman, zorlandığın tekrarları fark etmen ve seçimlerini daha sakin bir yerden yapman bu haritanın ana davetidir.';
    }

    final joined = parts.join(' ');
    return joined.length <= 520
        ? joined
        : '${joined.substring(0, 520).trim()}...';
  }
}
