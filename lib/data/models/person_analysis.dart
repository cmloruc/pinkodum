import 'dart:convert';
import 'element_balance.dart';

class PersonAnalysis {
  final String id;
  final String name;
  final DateTime birthDate;
  final List<int> pinCode;
  final String summary;
  final String strength;
  final String warning;
  final ElementBalance elementBalance;
  final DateTime createdAt;

  const PersonAnalysis({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.pinCode,
    required this.summary,
    required this.strength,
    required this.warning,
    required this.elementBalance,
    required this.createdAt,
  });

  String get pinCodeFormatted => pinCode.join('-');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'pinCode': pinCode,
        'summary': summary,
        'strength': strength,
        'warning': warning,
        'elementBalance': elementBalance.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory PersonAnalysis.fromJson(Map<String, dynamic> json) => PersonAnalysis(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        pinCode: List<int>.from(json['pinCode'] as List),
        summary: json['summary'] as String,
        strength: json['strength'] as String,
        warning: json['warning'] as String,
        elementBalance: ElementBalance.fromJson(
            json['elementBalance'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory PersonAnalysis.fromJsonString(String jsonString) =>
      PersonAnalysis.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
