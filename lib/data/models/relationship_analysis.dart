import 'dart:convert';
import 'element_balance.dart';

class RelationshipAnalysis {
  final String id;
  final String firstName;
  final DateTime firstBirthDate;
  final List<int> firstPinCode;
  final String secondName;
  final DateTime secondBirthDate;
  final List<int> secondPinCode;
  final String relationshipType;
  final List<int> combinedPinCode;
  final String summary;
  final String harmonyPoint;
  final String challengePoint;
  final String combinedInsight;
  final ElementBalance firstElementBalance;
  final ElementBalance secondElementBalance;
  final ElementBalance combinedElementBalance;
  final String? sexualCompatibility; // Sadece ilgili ilişki türlerinde dolu
  final DateTime createdAt;

  const RelationshipAnalysis({
    required this.id,
    required this.firstName,
    required this.firstBirthDate,
    required this.firstPinCode,
    required this.secondName,
    required this.secondBirthDate,
    required this.secondPinCode,
    required this.relationshipType,
    required this.combinedPinCode,
    required this.summary,
    required this.harmonyPoint,
    required this.challengePoint,
    required this.combinedInsight,
    required this.firstElementBalance,
    required this.secondElementBalance,
    required this.combinedElementBalance,
    this.sexualCompatibility,
    required this.createdAt,
  });

  String get firstPinFormatted => firstPinCode.join('-');
  String get secondPinFormatted => secondPinCode.join('-');
  String get combinedPinFormatted => combinedPinCode.join('-');
  String get title => '$firstName & $secondName';

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'firstBirthDate': firstBirthDate.toIso8601String(),
        'firstPinCode': firstPinCode,
        'secondName': secondName,
        'secondBirthDate': secondBirthDate.toIso8601String(),
        'secondPinCode': secondPinCode,
        'relationshipType': relationshipType,
        'combinedPinCode': combinedPinCode,
        'summary': summary,
        'harmonyPoint': harmonyPoint,
        'challengePoint': challengePoint,
        'combinedInsight': combinedInsight,
        'firstElementBalance': firstElementBalance.toJson(),
        'secondElementBalance': secondElementBalance.toJson(),
        'combinedElementBalance': combinedElementBalance.toJson(),
        if (sexualCompatibility != null)
          'sexualCompatibility': sexualCompatibility,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RelationshipAnalysis.fromJson(Map<String, dynamic> json) =>
      RelationshipAnalysis(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        firstBirthDate: DateTime.parse(json['firstBirthDate'] as String),
        firstPinCode: List<int>.from(json['firstPinCode'] as List),
        secondName: json['secondName'] as String,
        secondBirthDate: DateTime.parse(json['secondBirthDate'] as String),
        secondPinCode: List<int>.from(json['secondPinCode'] as List),
        relationshipType: json['relationshipType'] as String,
        combinedPinCode: List<int>.from(json['combinedPinCode'] as List),
        summary: json['summary'] as String,
        harmonyPoint: json['harmonyPoint'] as String,
        challengePoint: json['challengePoint'] as String,
        combinedInsight: json['combinedInsight'] as String,
        firstElementBalance: ElementBalance.fromJson(
            json['firstElementBalance'] as Map<String, dynamic>),
        secondElementBalance: ElementBalance.fromJson(
            json['secondElementBalance'] as Map<String, dynamic>),
        combinedElementBalance: ElementBalance.fromJson(
            json['combinedElementBalance'] as Map<String, dynamic>),
        sexualCompatibility: json['sexualCompatibility'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory RelationshipAnalysis.fromJsonString(String jsonString) =>
      RelationshipAnalysis.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);
}
