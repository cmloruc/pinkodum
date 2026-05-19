import 'dart:convert';

class RelationshipPremiumAnalysis {
  final String id;
  final String firstName;
  final DateTime firstBirthDate;
  final List<int> firstPinCode;
  final String secondName;
  final DateTime secondBirthDate;
  final List<int> secondPinCode;
  final List<int> combinedPinCode;
  final String relationshipType;

  // Ortak pin kodunun 9 hane yorumu
  final String h1Combined;   // Kişilik
  final String h2Combined;   // Sosyal Bilinç
  final String h3Combined;   // Küresel Bilinçlilik
  final String h4Combined;   // Yaşam Döngüsü
  final String h5Combined;   // Ders / Potansiyel
  final String h6Combined;   // İçsel Benlik
  final String h7Combined;   // İçsel Çocuk
  final String h8Combined;   // Ruh Duygusu
  final String h9Combined;   // Evren

  // Derinlemesine bölümler
  final String elementCompatibility;
  final String communicationStyle;
  final String conflictPatterns;
  final String growthOpportunity;
  final String sexualCompatibility;
  final String yearMessage;
  final String lifeLesson;
  final String overallSummary;

  final DateTime createdAt;

  const RelationshipPremiumAnalysis({
    required this.id,
    required this.firstName,
    required this.firstBirthDate,
    required this.firstPinCode,
    required this.secondName,
    required this.secondBirthDate,
    required this.secondPinCode,
    required this.combinedPinCode,
    required this.relationshipType,
    required this.h1Combined,
    required this.h2Combined,
    required this.h3Combined,
    required this.h4Combined,
    required this.h5Combined,
    required this.h6Combined,
    required this.h7Combined,
    required this.h8Combined,
    required this.h9Combined,
    required this.elementCompatibility,
    required this.communicationStyle,
    required this.conflictPatterns,
    required this.growthOpportunity,
    required this.sexualCompatibility,
    required this.yearMessage,
    required this.lifeLesson,
    required this.overallSummary,
    required this.createdAt,
  });

  String get title => '$firstName & $secondName';
  String get combinedPinFormatted => combinedPinCode.join('-');

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'firstBirthDate': firstBirthDate.toIso8601String(),
        'firstPinCode': firstPinCode,
        'secondName': secondName,
        'secondBirthDate': secondBirthDate.toIso8601String(),
        'secondPinCode': secondPinCode,
        'combinedPinCode': combinedPinCode,
        'relationshipType': relationshipType,
        'h1Combined': h1Combined,
        'h2Combined': h2Combined,
        'h3Combined': h3Combined,
        'h4Combined': h4Combined,
        'h5Combined': h5Combined,
        'h6Combined': h6Combined,
        'h7Combined': h7Combined,
        'h8Combined': h8Combined,
        'h9Combined': h9Combined,
        'elementCompatibility': elementCompatibility,
        'communicationStyle': communicationStyle,
        'conflictPatterns': conflictPatterns,
        'growthOpportunity': growthOpportunity,
        'sexualCompatibility': sexualCompatibility,
        'yearMessage': yearMessage,
        'lifeLesson': lifeLesson,
        'overallSummary': overallSummary,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RelationshipPremiumAnalysis.fromJson(Map<String, dynamic> json) =>
      RelationshipPremiumAnalysis(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        firstBirthDate: DateTime.parse(json['firstBirthDate'] as String),
        firstPinCode: List<int>.from(json['firstPinCode'] as List),
        secondName: json['secondName'] as String,
        secondBirthDate: DateTime.parse(json['secondBirthDate'] as String),
        secondPinCode: List<int>.from(json['secondPinCode'] as List),
        combinedPinCode: List<int>.from(json['combinedPinCode'] as List),
        relationshipType: json['relationshipType'] as String,
        h1Combined: json['h1Combined'] as String,
        h2Combined: json['h2Combined'] as String,
        h3Combined: json['h3Combined'] as String,
        h4Combined: json['h4Combined'] as String,
        h5Combined: json['h5Combined'] as String,
        h6Combined: json['h6Combined'] as String,
        h7Combined: json['h7Combined'] as String,
        h8Combined: json['h8Combined'] as String,
        h9Combined: json['h9Combined'] as String,
        elementCompatibility: json['elementCompatibility'] as String,
        communicationStyle: json['communicationStyle'] as String,
        conflictPatterns: json['conflictPatterns'] as String,
        growthOpportunity: json['growthOpportunity'] as String,
        sexualCompatibility: json['sexualCompatibility'] as String,
        yearMessage: json['yearMessage'] as String,
        lifeLesson: json['lifeLesson'] as String,
        overallSummary: json['overallSummary'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
}
