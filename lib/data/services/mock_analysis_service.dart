import 'package:uuid/uuid.dart';

import '../mock/mock_data.dart';
import '../models/person_analysis.dart';
import '../models/relationship_analysis.dart';
import 'element_balance_calculator.dart';
import 'pin_code_calculator.dart';

abstract class AnalysisService {
  Future<PersonAnalysis> analyzePersone({
    required String name,
    required DateTime birthDate,
  });

  Future<RelationshipAnalysis> analyzeRelationship({
    required String firstName,
    required DateTime firstBirthDate,
    required String secondName,
    required DateTime secondBirthDate,
    required String relationshipType,
  });
}

class MockAnalysisService implements AnalysisService {
  final PinCodeCalculator _calculator;
  final ElementBalanceCalculator _elementCalc;
  final _uuid = const Uuid();

  MockAnalysisService({
    PinCodeCalculator? calculator,
    ElementBalanceCalculator? elementCalculator,
  })  : _calculator = calculator ?? const PinCodeCalculator(),
        _elementCalc = elementCalculator ?? const ElementBalanceCalculator();

  @override
  Future<PersonAnalysis> analyzePersone({
    required String name,
    required DateTime birthDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final pin = _calculator.calculate(birthDate);
    final h1 = pin[0];
    final h5 = pin[4];
    final h6 = pin[5];
    final h9 = pin[8];
    final elementBalance = _elementCalc.calculate(pin);

    return PersonAnalysis(
      id: _uuid.v4(),
      name: name,
      birthDate: birthDate,
      pinCode: pin,
      summary: MockAnalysisData.personalitySummaryTeaser(name, h1, h9),
      strength: MockAnalysisData.strengthTeaser(name, h5),
      warning: MockAnalysisData.warningTeaser(name, h6),
      elementBalance: elementBalance,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<RelationshipAnalysis> analyzeRelationship({
    required String firstName,
    required DateTime firstBirthDate,
    required String secondName,
    required DateTime secondBirthDate,
    required String relationshipType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final pin1 = _calculator.calculate(firstBirthDate);
    final pin2 = _calculator.calculate(secondBirthDate);
    final combined = _calculator.calculateCombined(pin1, pin2);
    final elem1 = _elementCalc.calculate(pin1);
    final elem2 = _elementCalc.calculate(pin2);
    final elemCombined = _elementCalc.calculate(combined);

    return RelationshipAnalysis(
      id: _uuid.v4(),
      firstName: firstName,
      firstBirthDate: firstBirthDate,
      firstPinCode: pin1,
      secondName: secondName,
      secondBirthDate: secondBirthDate,
      secondPinCode: pin2,
      relationshipType: relationshipType,
      combinedPinCode: combined,
      summary: MockAnalysisData.relationshipSummary(
          firstName, secondName, relationshipType, combined),
      harmonyPoint:
          MockAnalysisData.harmonyPoint(firstName, secondName, combined),
      challengePoint:
          MockAnalysisData.challengePoint(firstName, secondName, combined),
      combinedInsight:
          MockAnalysisData.combinedInsight(firstName, secondName, combined),
      firstElementBalance: elem1,
      secondElementBalance: elem2,
      combinedElementBalance: elemCombined,
      sexualCompatibility: MockAnalysisData.showSexualCompatibility(relationshipType)
          ? MockAnalysisData.sexualCompatibilityTeaser(
              firstName, secondName,
              elemCombined.fire, elemCombined.water,
              elemCombined.air, elemCombined.energyType)
          : null,
      createdAt: DateTime.now(),
    );
  }
}
