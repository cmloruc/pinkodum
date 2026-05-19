import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_config.dart';
import '../models/person_analysis.dart';
import '../models/person_premium_analysis.dart';
import '../models/relationship_analysis.dart';
import '../models/relationship_premium_analysis.dart';
import 'analysis_repository.dart';

/// Backend API üzerinden analiz kayıt/okuma işlemleri yapar.
/// Analizler backend'de `type` + `result` (jsonb) olarak saklanır.
/// result JSON içindeki `id`, analizin kendi id'sidir; silmede backend satır id'si ile eşleştirilir.
class ApiAnalysisRepository implements AnalysisRepository {
  final String _token;
  final String _base = '${AppConfig.backendBaseUrl}/analyses';

  ApiAnalysisRepository(this._token);

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        'authorization': 'Bearer $_token',
      };

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    final res = await http
        .get(Uri.parse(_base), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Geçmiş yüklenemedi.');
    return (jsonDecode(res.body) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> _fetchByType(String type) async {
    final all = await _fetchAll();
    return all.where((e) => e['type'] == type).toList();
  }

  Future<void> _save(String type, Map<String, dynamic> result,
      {required String subjectName,
      required DateTime subjectBirthDate,
      String? partnerName,
      DateTime? partnerBirthDate,
      String? relationshipType}) async {
    final body = <String, dynamic>{
      'type': type,
      'subjectName': subjectName,
      'subjectBirthDate': subjectBirthDate.toIso8601String(),
      'result': result,
      if (partnerName != null) 'partnerName': partnerName,
      if (partnerBirthDate != null)
        'partnerBirthDate': partnerBirthDate.toIso8601String(),
      if (relationshipType != null) 'relationshipType': relationshipType,
    };
    final res = await http
        .post(Uri.parse(_base),
            headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 201) throw Exception('Analiz kaydedilemedi.');
  }

  // Analiz model id'si ile backend satır id'sini eşleştirip siler.
  Future<void> _deleteByAnalysisId(String type, String analysisId) async {
    final rows = await _fetchByType(type);
    final row = rows.cast<Map<String, dynamic>?>().firstWhere(
          (r) =>
              (r!['result'] as Map<String, dynamic>)['id'] == analysisId,
          orElse: () => null,
        );
    if (row == null) return;
    await http
        .delete(Uri.parse('$_base/${row['id']}'), headers: _headers)
        .timeout(const Duration(seconds: 15));
  }

  // ─── Person ──────────────────────────────────────────────────────────────────

  @override
  Future<List<PersonAnalysis>> getPersonAnalyses() async {
    final rows = await _fetchByType('single');
    return rows
        .map((e) =>
            PersonAnalysis.fromJson(e['result'] as Map<String, dynamic>))
        .toList();
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
  Future<void> savePersonAnalysis(PersonAnalysis analysis) => _save(
        'single',
        analysis.toJson(),
        subjectName: analysis.name,
        subjectBirthDate: analysis.birthDate,
      );

  @override
  Future<void> deletePersonAnalysis(String id) =>
      _deleteByAnalysisId('single', id);

  // ─── Relationship ─────────────────────────────────────────────────────────────

  @override
  Future<List<RelationshipAnalysis>> getRelationshipAnalyses() async {
    final rows = await _fetchByType('relationship');
    return rows
        .map((e) =>
            RelationshipAnalysis.fromJson(e['result'] as Map<String, dynamic>))
        .toList();
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
  Future<void> saveRelationshipAnalysis(RelationshipAnalysis analysis) =>
      _save(
        'relationship',
        analysis.toJson(),
        subjectName: analysis.firstName,
        subjectBirthDate: analysis.firstBirthDate,
        partnerName: analysis.secondName,
        partnerBirthDate: analysis.secondBirthDate,
        relationshipType: analysis.relationshipType,
      );

  @override
  Future<void> deleteRelationshipAnalysis(String id) =>
      _deleteByAnalysisId('relationship', id);

  // ─── Premium Tekil ────────────────────────────────────────────────────────────

  @override
  Future<List<PersonPremiumAnalysis>> getPremiumAnalyses() async {
    final rows = await _fetchByType('single_premium');
    return rows
        .map((e) => PersonPremiumAnalysis.fromJson(
            e['result'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> savePremiumAnalysis(PersonPremiumAnalysis analysis) => _save(
        'single_premium',
        analysis.toJson(),
        subjectName: analysis.name,
        subjectBirthDate: analysis.birthDate,
      );

  @override
  Future<void> deletePremiumAnalysis(String id) =>
      _deleteByAnalysisId('single_premium', id);

  // ─── Premium İlişki ───────────────────────────────────────────────────────────

  @override
  Future<List<RelationshipPremiumAnalysis>> getRelationshipPremiumAnalyses() async {
    final rows = await _fetchByType('relationship_premium');
    return rows
        .map((e) => RelationshipPremiumAnalysis.fromJson(
            e['result'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRelationshipPremiumAnalysis(RelationshipPremiumAnalysis a) =>
      _save(
        'relationship_premium',
        a.toJson(),
        subjectName: a.firstName,
        subjectBirthDate: a.firstBirthDate,
        partnerName: a.secondName,
        partnerBirthDate: a.secondBirthDate,
        relationshipType: a.relationshipType,
      );

  @override
  Future<void> deleteRelationshipPremiumAnalysis(String id) =>
      _deleteByAnalysisId('relationship_premium', id);

  // ─── Clear ────────────────────────────────────────────────────────────────────

  @override
  Future<void> clearAll() async {
    final rows = await _fetchAll();
    await Future.wait(rows.map((r) => http
        .delete(Uri.parse('$_base/${r['id']}'), headers: _headers)
        .timeout(const Duration(seconds: 15))));
  }
}
