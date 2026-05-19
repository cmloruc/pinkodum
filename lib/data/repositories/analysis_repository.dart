import '../models/person_analysis.dart';
import '../models/person_premium_analysis.dart';
import '../models/relationship_analysis.dart';
import '../models/relationship_premium_analysis.dart';

/// Backend'e geçişte bu interface değişmez; sadece implementasyon swap edilir.
abstract class AnalysisRepository {
  Future<List<PersonAnalysis>> getPersonAnalyses();
  Future<PersonAnalysis?> getPersonAnalysis(String id);
  Future<void> savePersonAnalysis(PersonAnalysis analysis);
  Future<void> deletePersonAnalysis(String id);

  Future<List<PersonPremiumAnalysis>> getPremiumAnalyses();
  Future<void> savePremiumAnalysis(PersonPremiumAnalysis analysis);
  Future<void> deletePremiumAnalysis(String id);

  Future<List<RelationshipPremiumAnalysis>> getRelationshipPremiumAnalyses();
  Future<void> saveRelationshipPremiumAnalysis(RelationshipPremiumAnalysis a);
  Future<void> deleteRelationshipPremiumAnalysis(String id);

  Future<List<RelationshipAnalysis>> getRelationshipAnalyses();
  Future<RelationshipAnalysis?> getRelationshipAnalysis(String id);
  Future<void> saveRelationshipAnalysis(RelationshipAnalysis analysis);
  Future<void> deleteRelationshipAnalysis(String id);

  Future<void> clearAll();
}
