import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/person_analysis.dart';
import '../models/person_premium_analysis.dart';
import '../models/relationship_analysis.dart';
import '../models/relationship_premium_analysis.dart';
import 'analysis_repository.dart';

class LocalAnalysisRepository implements AnalysisRepository {
  static const _personKey = 'person_analyses';
  static const _relationshipKey = 'relationship_analyses';
  static const _premiumKey = 'premium_analyses';
  static const _relPremiumKey = 'relationship_premium_analyses';

  final SharedPreferences _prefs;

  LocalAnalysisRepository(this._prefs);

  // ─── Person ────────────────────────────────────────────────────────────────

  @override
  Future<List<PersonAnalysis>> getPersonAnalyses() async {
    final raw = _prefs.getStringList(_personKey) ?? [];
    final seen = <String>{};
    return raw
        .map((s) =>
            PersonAnalysis.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .where((analysis) => seen.add(analysis.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<PersonAnalysis?> getPersonAnalysis(String id) async {
    final list = await getPersonAnalyses();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePersonAnalysis(PersonAnalysis analysis) async {
    final list = await getPersonAnalyses();
    final updated = list.where((e) => e.id != analysis.id).toList()
      ..insert(0, analysis);
    await _prefs.setStringList(
      _personKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<void> deletePersonAnalysis(String id) async {
    final list = await getPersonAnalyses();
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final updated = [...list]..removeAt(index);
    await _prefs.setStringList(
      _personKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // ─── Relationship ──────────────────────────────────────────────────────────

  @override
  Future<List<RelationshipAnalysis>> getRelationshipAnalyses() async {
    final raw = _prefs.getStringList(_relationshipKey) ?? [];
    final seen = <String>{};
    return raw
        .map((s) => RelationshipAnalysis.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .where((analysis) => seen.add(analysis.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<RelationshipAnalysis?> getRelationshipAnalysis(String id) async {
    final list = await getRelationshipAnalyses();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveRelationshipAnalysis(RelationshipAnalysis analysis) async {
    final list = await getRelationshipAnalyses();
    final updated = list.where((e) => e.id != analysis.id).toList()
      ..insert(0, analysis);
    await _prefs.setStringList(
      _relationshipKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<void> deleteRelationshipAnalysis(String id) async {
    final list = await getRelationshipAnalyses();
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final updated = [...list]..removeAt(index);
    await _prefs.setStringList(
      _relationshipKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // ─── Premium ──────────────────────────────────────────────────────────────

  @override
  Future<List<PersonPremiumAnalysis>> getPremiumAnalyses() async {
    final raw = _prefs.getStringList(_premiumKey) ?? [];
    final seen = <String>{};
    return raw
        .map((s) => PersonPremiumAnalysis.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .where((analysis) => seen.add(analysis.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> savePremiumAnalysis(PersonPremiumAnalysis analysis) async {
    final list = await getPremiumAnalyses();
    final updated = list.where((e) => e.id != analysis.id).toList()
      ..insert(0, analysis);
    await _prefs.setStringList(
      _premiumKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<void> deletePremiumAnalysis(String id) async {
    final list = await getPremiumAnalyses();
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final updated = [...list]..removeAt(index);
    await _prefs.setStringList(
      _premiumKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // ─── Relationship Premium ──────────────────────────────────────────────────

  @override
  Future<List<RelationshipPremiumAnalysis>>
      getRelationshipPremiumAnalyses() async {
    final raw = _prefs.getStringList(_relPremiumKey) ?? [];
    final seen = <String>{};
    return raw
        .map((s) => RelationshipPremiumAnalysis.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .where((analysis) => seen.add(analysis.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveRelationshipPremiumAnalysis(
      RelationshipPremiumAnalysis a) async {
    final list = await getRelationshipPremiumAnalyses();
    final updated = list.where((e) => e.id != a.id).toList()..insert(0, a);
    await _prefs.setStringList(
      _relPremiumKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<void> deleteRelationshipPremiumAnalysis(String id) async {
    final list = await getRelationshipPremiumAnalyses();
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final updated = [...list]..removeAt(index);
    await _prefs.setStringList(
      _relPremiumKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_personKey);
    await _prefs.remove(_relationshipKey);
    await _prefs.remove(_premiumKey);
    await _prefs.remove(_relPremiumKey);
  }
}
