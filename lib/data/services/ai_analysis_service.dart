import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_config.dart';
import '../mock/mock_data.dart';
import '../models/person_analysis.dart';
import '../models/person_premium_analysis.dart';
import '../models/relationship_analysis.dart';
import '../models/relationship_premium_analysis.dart';
import 'api_key_service.dart';
import 'auth_service.dart';
import 'element_balance_calculator.dart';
import 'mock_analysis_service.dart';
import 'pin_code_calculator.dart';
import 'prompt_builder.dart';

/// Seçili AI sağlayıcısı ile gerçek analiz üretir.
/// API anahtarı yoksa veya istek başarısız olursa hatayı çağırana iletir.
class AiAnalysisService implements AnalysisService {
  static const _anthropicApiUrl = 'https://api.anthropic.com/v1/messages';
  static const _openAiApiUrl = 'https://api.openai.com/v1/responses';
  static const _anthropicVersion = '2023-06-01';

  final ApiKeyService _keyService;
  final PinCodeCalculator _calculator;
  final ElementBalanceCalculator _elementCalc;
  final _uuid = const Uuid();

  AiAnalysisService({
    required ApiKeyService keyService,
    PinCodeCalculator? calculator,
    ElementBalanceCalculator? elementCalculator,
  })  : _keyService = keyService,
        _calculator = calculator ?? const PinCodeCalculator(),
        _elementCalc = elementCalculator ?? const ElementBalanceCalculator();

  // ─── Tek Kişi Analizi ─────────────────────────────────────────────────────
  @override
  Future<PersonAnalysis> analyzePersone({
    required String name,
    required DateTime birthDate,
  }) async {
    final pin = _calculator.calculate(birthDate);
    final elementBalance = _elementCalc.calculate(pin);
    final birthDateStr =
        '${birthDate.day}.${birthDate.month}.${birthDate.year}';

    try {
      final userPrompt = PromptBuilder.singleAnalysis(
        name: name,
        birthDate: birthDateStr,
        pinCode: pin,
        elementBalance: elementBalance,
      );

      final data = await _callApi(userPrompt);
      final texts = _parseJson(data);

      return PersonAnalysis(
        id: _uuid.v4(),
        name: name,
        birthDate: birthDate,
        pinCode: pin,
        summary: texts['summary'] ?? '',
        strength: texts['strength'] ?? '',
        warning: texts['warning'] ?? '',
        elementBalance: elementBalance,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception(_analysisErrorMessage(e));
    }
  }

  // ─── İlişki Analizi ───────────────────────────────────────────────────────
  @override
  Future<RelationshipAnalysis> analyzeRelationship({
    required String firstName,
    required DateTime firstBirthDate,
    required String secondName,
    required DateTime secondBirthDate,
    required String relationshipType,
  }) async {
    final pin1 = _calculator.calculate(firstBirthDate);
    final pin2 = _calculator.calculate(secondBirthDate);
    final combined = _calculator.calculateCombined(pin1, pin2);
    final elem1 = _elementCalc.calculate(pin1);
    final elem2 = _elementCalc.calculate(pin2);
    final elemCombined = _elementCalc.calculate(combined);

    final includeSexual =
        MockAnalysisData.showSexualCompatibility(relationshipType);

    try {
      final userPrompt = PromptBuilder.relationshipAnalysis(
        name1: firstName,
        birthDate1:
            '${firstBirthDate.day}.${firstBirthDate.month}.${firstBirthDate.year}',
        pinCode1: pin1,
        elem1: elem1,
        name2: secondName,
        birthDate2:
            '${secondBirthDate.day}.${secondBirthDate.month}.${secondBirthDate.year}',
        pinCode2: pin2,
        elem2: elem2,
        combinedPin: combined,
        combinedElem: elemCombined,
        relationshipType: relationshipType,
        includeSexual: includeSexual,
      );

      final data = await _callApi(userPrompt);
      final texts = _parseJson(data);

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
        summary: texts['summary'] ?? '',
        harmonyPoint: texts['harmonyPoint'] ?? '',
        challengePoint: texts['challengePoint'] ?? '',
        combinedInsight: '',
        firstElementBalance: elem1,
        secondElementBalance: elem2,
        combinedElementBalance: elemCombined,
        createdAt: DateTime.now(),
        sexualCompatibility:
            includeSexual ? texts['sexualCompatibility'] : null,
      );
    } catch (e) {
      throw Exception(_analysisErrorMessage(e));
    }
  }

  // ─── Premium İlişki Analizi ───────────────────────────────────────────────
  Future<RelationshipPremiumAnalysis> analyzeRelationshipPremium({
    required String firstName,
    required DateTime firstBirthDate,
    required String secondName,
    required DateTime secondBirthDate,
    required String relationshipType,
  }) async {
    final pin1 = _calculator.calculate(firstBirthDate);
    final pin2 = _calculator.calculate(secondBirthDate);
    final combined = _calculator.calculateCombined(pin1, pin2);
    final elem1 = _elementCalc.calculate(pin1);
    final elem2 = _elementCalc.calculate(pin2);
    final elemCombined = _elementCalc.calculate(combined);
    final includeSexual =
        MockAnalysisData.showSexualCompatibility(relationshipType);

    final firstBirthDateStr =
        '${firstBirthDate.day}.${firstBirthDate.month}.${firstBirthDate.year}';
    final secondBirthDateStr =
        '${secondBirthDate.day}.${secondBirthDate.month}.${secondBirthDate.year}';
    final currentYear = DateTime.now().year;

    final firstParts = await Future.wait([
      _callApi(
        PromptBuilder.premiumRelationshipHaneSection(
          name1: firstName,
          birthDate1: firstBirthDateStr,
          pin1: pin1,
          elem1: elem1,
          name2: secondName,
          birthDate2: secondBirthDateStr,
          pin2: pin2,
          elem2: elem2,
          combined: combined,
          combinedElem: elemCombined,
          relationshipType: relationshipType,
        ),
        maxTokens: 2600,
      ),
      _callApi(
        PromptBuilder.premiumRelationshipDynamicsSection(
          name1: firstName,
          birthDate1: firstBirthDateStr,
          pin1: pin1,
          elem1: elem1,
          name2: secondName,
          birthDate2: secondBirthDateStr,
          pin2: pin2,
          elem2: elem2,
          combined: combined,
          combinedElem: elemCombined,
          relationshipType: relationshipType,
          includeSexual: includeSexual,
        ),
        maxTokens: 2200,
      ),
    ]);
    final synthesisData = await _callApi(
      PromptBuilder.premiumRelationshipSynthesisSection(
        name1: firstName,
        birthDate1: firstBirthDateStr,
        pin1: pin1,
        elem1: elem1,
        name2: secondName,
        birthDate2: secondBirthDateStr,
        pin2: pin2,
        elem2: elem2,
        combined: combined,
        combinedElem: elemCombined,
        relationshipType: relationshipType,
        currentYear: currentYear,
      ),
      maxTokens: 1900,
    );

    final texts = <String, String>{
      ..._parseJson(firstParts[0]),
      ..._parseJson(firstParts[1]),
      ..._parseJson(synthesisData),
    };

    const requiredFields = [
      'h1Combined',
      'h2Combined',
      'h3Combined',
      'h4Combined',
      'h5Combined',
      'h6Combined',
      'h7Combined',
      'h8Combined',
      'h9Combined',
      'elementCompatibility',
      'communicationStyle',
      'conflictPatterns',
      'growthOpportunity',
      'sexualCompatibility',
      'yearMessage',
      'lifeLesson',
      'overallSummary',
    ];
    final missingFields = requiredFields
        .where((field) => (texts[field] ?? '').trim().isEmpty)
        .toList();
    if (missingFields.isNotEmpty) {
      final missingData = await _callApi(
        PromptBuilder.premiumRelationshipMissingFields(
          name1: firstName,
          birthDate1: firstBirthDateStr,
          pin1: pin1,
          elem1: elem1,
          name2: secondName,
          birthDate2: secondBirthDateStr,
          pin2: pin2,
          elem2: elem2,
          combined: combined,
          combinedElem: elemCombined,
          relationshipType: relationshipType,
          missingFields: missingFields,
        ),
        maxTokens: 1200,
      );
      texts.addAll(_parseJson(missingData));
    }

    return RelationshipPremiumAnalysis(
      id: _uuid.v4(),
      firstName: firstName,
      firstBirthDate: firstBirthDate,
      firstPinCode: pin1,
      secondName: secondName,
      secondBirthDate: secondBirthDate,
      secondPinCode: pin2,
      combinedPinCode: combined,
      relationshipType: relationshipType,
      h1Combined: texts['h1Combined'] ?? '',
      h2Combined: texts['h2Combined'] ?? '',
      h3Combined: texts['h3Combined'] ?? '',
      h4Combined: texts['h4Combined'] ?? '',
      h5Combined: texts['h5Combined'] ?? '',
      h6Combined: texts['h6Combined'] ?? '',
      h7Combined: texts['h7Combined'] ?? '',
      h8Combined: texts['h8Combined'] ?? '',
      h9Combined: texts['h9Combined'] ?? '',
      elementCompatibility: texts['elementCompatibility'] ?? '',
      communicationStyle: texts['communicationStyle'] ?? '',
      conflictPatterns: texts['conflictPatterns'] ?? '',
      growthOpportunity: texts['growthOpportunity'] ?? '',
      sexualCompatibility: texts['sexualCompatibility'] ?? '',
      yearMessage: texts['yearMessage'] ?? '',
      lifeLesson: texts['lifeLesson'] ?? '',
      overallSummary: texts['overallSummary'] ?? '',
      createdAt: DateTime.now(),
    );
  }

  // ─── Premium Tek Kişi Analizi ─────────────────────────────────────────────
  Future<PersonPremiumAnalysis> analyzePremium({
    required String name,
    required DateTime birthDate,
  }) async {
    final pin = _calculator.calculate(birthDate);
    final elementBalance = _elementCalc.calculate(pin);
    final birthDateStr =
        '${birthDate.day}.${birthDate.month}.${birthDate.year}';
    final currentYear = DateTime.now().year;

    final firstParts = await Future.wait([
      _callApi(
        PromptBuilder.premiumSingleIdentitySection(
          name: name,
          birthDate: birthDateStr,
          pinCode: pin,
          elementBalance: elementBalance,
        ),
        maxTokens: 1700,
      ),
      _callApi(
        PromptBuilder.premiumSingleLifeSection(
          name: name,
          birthDate: birthDateStr,
          pinCode: pin,
          elementBalance: elementBalance,
        ),
        maxTokens: 1700,
      ),
    ]);
    final soulData = await _callApi(
      PromptBuilder.premiumSingleSoulSection(
        name: name,
        birthDate: birthDateStr,
        pinCode: pin,
        elementBalance: elementBalance,
        currentYear: currentYear,
      ),
      maxTokens: 2100,
    );

    final texts = <String, String>{
      ..._parseJson(firstParts[0]),
      ..._parseJson(firstParts[1]),
      ..._parseJson(soulData),
    };
    _applyTextAliases(texts);

    const requiredFields = [
      'h1Personality',
      'h2Social',
      'h3Global',
      'h4LifeCycle',
      'h5Lesson',
      'h6InnerSelf',
      'h7InnerChild',
      'h8Soul',
      'h9Universe',
      'elementDetail',
      'lifeLesson',
      'yearMessage',
      'overallSummary',
    ];
    final missingFields = requiredFields
        .where((field) => (texts[field] ?? '').trim().isEmpty)
        .toList();
    if (missingFields.isNotEmpty) {
      final missingData = await _callApi(
        PromptBuilder.premiumSingleMissingFields(
          name: name,
          birthDate: birthDateStr,
          pinCode: pin,
          elementBalance: elementBalance,
          currentYear: currentYear,
          missingFields: missingFields,
        ),
        maxTokens: 1800,
      );
      texts.addAll(_parseJson(missingData));
      _applyTextAliases(texts);
    }

    final overallSummary = (texts['overallSummary'] ?? '').trim().isEmpty
        ? _fallbackOverallSummary(name, texts)
        : texts['overallSummary']!;

    return PersonPremiumAnalysis(
      id: _uuid.v4(),
      name: name,
      birthDate: birthDate,
      pinCode: pin,
      h1Personality: texts['h1Personality'] ?? '',
      h2Social: texts['h2Social'] ?? '',
      h3Global: texts['h3Global'] ?? '',
      h4LifeCycle: texts['h4LifeCycle'] ?? '',
      h5Lesson: texts['h5Lesson'] ?? '',
      h6InnerSelf: texts['h6InnerSelf'] ?? '',
      h7InnerChild: texts['h7InnerChild'] ?? '',
      h8Soul: texts['h8Soul'] ?? '',
      h9Universe: texts['h9Universe'] ?? '',
      elementDetail: texts['elementDetail'] ?? '',
      lifeLesson: texts['lifeLesson'] ?? '',
      yearMessage: texts['yearMessage'] ?? '',
      overallSummary: overallSummary,
      createdAt: DateTime.now(),
    );
  }

  // ─── AI API İsteği ───────────────────────────────────────────────────────
  // Kişisel API anahtarı varsa direkt çağrı, yoksa backend proxy kullanılır.
  Future<String> _callApi(String userMessage, {int maxTokens = 1024}) async {
    if (_keyService.hasApiKey) {
      if (_keyService.isOpenAi) {
        return _callOpenAiApi(userMessage, maxTokens: maxTokens);
      }
      return _callClaudeApi(userMessage, maxTokens: maxTokens);
    }
    return _callBackendProxy(userMessage, maxTokens: maxTokens);
  }

  Future<String> _callBackendProxy(String userMessage,
      {int maxTokens = 1024}) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);

    if (!auth.isLoggedIn) {
      throw Exception('Analiz için giriş yapılması gerekiyor.');
    }

    final response = await http
        .post(
          Uri.parse('${AppConfig.backendBaseUrl}/ai/query'),
          headers: {
            'content-type': 'application/json',
            'authorization': 'Bearer ${auth.token}',
          },
          body:
              jsonEncode({'userMessage': userMessage, 'maxTokens': maxTokens}),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
          body['message'] ?? 'AI sorgu hatası: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['text'] as String;
  }

  Future<String> _callClaudeApi(
    String userMessage, {
    int maxTokens = 1024,
  }) async {
    final body = jsonEncode({
      'model': _keyService.model,
      'max_tokens': maxTokens,
      // System prompt cache_control ile cache'lenir, her istekte yeniden işlenmez.
      'system': [
        {
          'type': 'text',
          'text': PromptBuilder.systemPrompt,
          'cache_control': {'type': 'ephemeral'},
        }
      ],
      'messages': [
        {'role': 'user', 'content': userMessage}
      ],
    });

    final response = await http
        .post(
          Uri.parse(_anthropicApiUrl),
          headers: {
            'x-api-key': _keyService.apiKey,
            'anthropic-version': _anthropicVersion,
            'content-type': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      throw Exception(
        'Claude API hatası: ${response.statusCode} ${_extractApiError(response.body)}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['content'] as List<dynamic>;
    final textBlock =
        content.firstWhere((b) => b['type'] == 'text', orElse: () => null);
    if (textBlock == null) throw Exception('Yanıt içeriği boş');
    return textBlock['text'] as String;
  }

  Future<String> _callOpenAiApi(
    String userMessage, {
    int maxTokens = 1024,
  }) async {
    final outputTokenBudget = maxTokens < 2200 ? 2200 : maxTokens;
    final body = jsonEncode({
      'model': _keyService.model,
      'instructions': PromptBuilder.systemPrompt,
      'input': userMessage,
      'max_output_tokens': outputTokenBudget,
      'reasoning': {'effort': 'low'},
      'text': {
        'format': {'type': 'json_object'},
      },
    });

    final response = await http
        .post(
          Uri.parse(_openAiApiUrl),
          headers: {
            'authorization': 'Bearer ${_keyService.apiKey}',
            'content-type': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OpenAI API hatası: ${response.statusCode} ${_extractApiError(response.body)}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = decoded['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText;
    }

    final extracted = _extractOpenAiText(decoded).trim();
    if (extracted.isNotEmpty) return extracted;

    final status = decoded['status'];
    final incomplete = decoded['incomplete_details'];
    final error = decoded['error'];
    final details = [
      if (status != null) 'status: $status',
      if (incomplete != null) 'incomplete: $incomplete',
      if (error != null) 'error: $error',
    ].join(', ');
    throw Exception(
      details.isEmpty
          ? 'OpenAI yanıt içeriği boş'
          : 'OpenAI yanıt içeriği boş ($details)',
    );
  }

  String _extractOpenAiText(dynamic value) {
    if (value is String) return '';
    if (value is List) {
      return value
          .map(_extractOpenAiText)
          .where((part) => part.isNotEmpty)
          .join();
    }
    if (value is Map<String, dynamic>) {
      final type = value['type'];
      final text = value['text'];
      if ((type == 'output_text' || type == 'text') && text is String) {
        return text;
      }
      final content = value['content'];
      final output = value['output'];
      final parts = [
        if (content != null) _extractOpenAiText(content),
        if (output != null) _extractOpenAiText(output),
      ];
      return parts.where((part) => part.isNotEmpty).join();
    }
    return '';
  }

  String _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'];
        final message = error['message'];
        return [code, message]
            .where((part) => part != null && part.toString().trim().isNotEmpty)
            .join(': ');
      }
    } catch (_) {}

    final trimmed = body.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.length > 240 ? '${trimmed.substring(0, 240)}...' : trimmed;
  }

  String _analysisErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message == 'Analiz için giriş yapılması gerekiyor.') {
      return message;
    }
    return 'Analiz oluşturulamadı. Lütfen bağlantını kontrol edip tekrar dene.';
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'\bH[1-9]\s*=\s*\d+\s*,?\s*'), '')
        .replaceAll(RegExp(r'\bH[1-9]\s*[:=]\s*'), '')
        .replaceAll(
            RegExp(r'\bOrtak H[1-9]\b', caseSensitive: false), 'Bu alan')
        .replaceAll(RegExp(r'\bH[1-9]\b'), 'bu alan')
        .replaceAll('—', ',')
        .replaceAll('–', ',')
        .replaceAll(RegExp(r'\s+,'), ',')
        .replaceAll(RegExp(r',\s*,'), ',')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  // ─── JSON Yanıt Parse ─────────────────────────────────────────────────────
  Map<String, String> _parseJson(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    try {
      final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
      return decoded
          .map((k, v) => MapEntry(k, _sanitizeText(v?.toString() ?? '')));
    } on FormatException {
      final loose = _parseLooseJsonObject(cleaned);
      if (loose.isNotEmpty) return loose;
      rethrow;
    }
  }

  void _applyTextAliases(Map<String, String> texts) {
    const aliases = {
      'overall_summary': 'overallSummary',
      'generalSummary': 'overallSummary',
      'summary': 'overallSummary',
      'element_detail': 'elementDetail',
      'life_lesson': 'lifeLesson',
      'year_message': 'yearMessage',
    };

    for (final entry in aliases.entries) {
      final aliasValue = texts[entry.key];
      final canonicalValue = texts[entry.value];
      if ((canonicalValue == null || canonicalValue.trim().isEmpty) &&
          aliasValue != null &&
          aliasValue.trim().isNotEmpty) {
        texts[entry.value] = aliasValue;
      }
    }
  }

  String _fallbackOverallSummary(String name, Map<String, String> texts) {
    final parts = [
      texts['elementDetail'],
      texts['lifeLesson'],
      texts['yearMessage'],
    ]
        .where((text) => text != null && text.trim().isNotEmpty)
        .map((text) => text!.trim())
        .toList();

    if (parts.isEmpty) {
      return '$name, bu detaylı rapor pin kodundaki ana temaların birlikte okunmasıyla oluşur. Güçlü taraflarını bilinçli kullanman, zorlandığın tekrarları fark etmen ve seçimlerini daha sakin bir yerden yapman bu haritanın ana davetidir.';
    }

    final joined = parts.join(' ');
    return joined.length <= 520
        ? joined
        : '${joined.substring(0, 520).trim()}...';
  }

  Map<String, String> _parseLooseJsonObject(String raw) {
    const keys = [
      'summary',
      'strength',
      'warning',
      'harmonyPoint',
      'challengePoint',
      'combinedInsight',
      'sexualCompatibility',
      'h1Combined',
      'h2Combined',
      'h3Combined',
      'h4Combined',
      'h5Combined',
      'h6Combined',
      'h7Combined',
      'h8Combined',
      'h9Combined',
      'elementCompatibility',
      'communicationStyle',
      'conflictPatterns',
      'growthOpportunity',
      'yearMessage',
      'lifeLesson',
      'overallSummary',
      'h1Personality',
      'h2Social',
      'h3Global',
      'h4LifeCycle',
      'h5Lesson',
      'h6InnerSelf',
      'h7InnerChild',
      'h8Soul',
      'h9Universe',
      'elementDetail',
    ];
    final result = <String, String>{};

    for (final key in keys) {
      final startMatch = RegExp('"$key"' r'\s*:\s*"').firstMatch(raw);
      if (startMatch == null) continue;

      final valueStart = startMatch.end;
      var valueEnd = -1;
      for (var i = valueStart; i < raw.length; i++) {
        if (raw.codeUnitAt(i) != 34) continue;
        if (_isEscaped(raw, i)) continue;

        final rest = raw.substring(i + 1).trimLeft();
        if (rest.startsWith('}')) {
          valueEnd = i;
          break;
        }
        if (!rest.startsWith(',')) continue;

        final afterComma = rest.substring(1).trimLeft();
        if (keys.any((nextKey) => afterComma.startsWith('"$nextKey"'))) {
          valueEnd = i;
          break;
        }
      }

      if (valueEnd <= valueStart) continue;
      final value = raw.substring(valueStart, valueEnd).replaceAll(r'\"', '"');
      result[key] = _sanitizeText(value);
    }

    return result;
  }

  bool _isEscaped(String text, int index) {
    var slashCount = 0;
    for (var i = index - 1; i >= 0 && text.codeUnitAt(i) == 92; i--) {
      slashCount++;
    }
    return slashCount.isOdd;
  }
}
