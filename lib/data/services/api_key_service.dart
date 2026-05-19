import 'package:shared_preferences/shared_preferences.dart';

/// API anahtarı ve model tercihlerini SharedPreferences'ta saklar.
/// Üretimde anahtar sunucu tarafına taşınmalı (Aşama 2 backend).
class ApiKeyService {
  static const providerClaude = 'claude';
  static const providerOpenAi = 'openai';
  static const defaultProvider = providerClaude;

  static const _keyProvider = 'ai_provider';
  static const _keyClaudeApiKey = 'claude_api_key';
  static const _keyClaudeModel = 'claude_model';
  static const _keyOpenAiApiKey = 'openai_api_key';
  static const _keyOpenAiModel = 'openai_model';

  static const defaultClaudeModel = 'claude-haiku-4-5-20251001';
  static const premiumClaudeModel = 'claude-opus-4-7';
  static const defaultOpenAiModel = 'gpt-5-mini';
  static const premiumOpenAiModel = 'gpt-5.2';

  // Eski çağrı noktaları için aktif sağlayıcının varsayılan Claude modeli.
  static const defaultModel = defaultClaudeModel;
  static const premiumModel = premiumClaudeModel;

  static const providerLabels = {
    providerClaude: 'Claude',
    providerOpenAi: 'OpenAI',
  };

  static const claudeModels = {
    'claude-haiku-4-5-20251001': 'Claude Haiku (Hızlı & Ekonomik)',
    'claude-sonnet-4-6': 'Claude Sonnet (Dengeli)',
    'claude-opus-4-7': 'Claude Opus (En Güçlü)',
  };

  static const openAiModels = {
    'gpt-5-mini': 'GPT-5 mini (Hızlı & Ekonomik)',
    'gpt-5.2': 'GPT-5.2 (Güçlü)',
    'gpt-5.2-pro': 'GPT-5.2 pro (En Güçlü)',
  };

  static const availableModels = claudeModels;

  final SharedPreferences _prefs;
  ApiKeyService(this._prefs);

  String get provider => _prefs.getString(_keyProvider) ?? defaultProvider;
  bool get isClaude => provider == providerClaude;
  bool get isOpenAi => provider == providerOpenAi;

  String get apiKey => apiKeyForProvider(provider);
  bool get hasApiKey => apiKey.isNotEmpty;
  String get model => modelForProvider(provider);

  String apiKeyForProvider(String provider) {
    final key =
        provider == providerOpenAi ? _keyOpenAiApiKey : _keyClaudeApiKey;
    return _prefs.getString(key) ?? '';
  }

  String modelForProvider(String provider) {
    if (provider == providerOpenAi) {
      return _prefs.getString(_keyOpenAiModel) ?? defaultOpenAiModel;
    }
    return _prefs.getString(_keyClaudeModel) ?? defaultClaudeModel;
  }

  Map<String, String> modelsForProvider(String provider) =>
      provider == providerOpenAi ? openAiModels : claudeModels;

  Future<void> saveProvider(String provider) =>
      _prefs.setString(_keyProvider, provider);

  Future<void> saveApiKey(String key) => saveApiKeyForProvider(provider, key);

  Future<void> saveApiKeyForProvider(String provider, String key) {
    final prefKey =
        provider == providerOpenAi ? _keyOpenAiApiKey : _keyClaudeApiKey;
    return _prefs.setString(prefKey, key.trim());
  }

  Future<void> saveModel(String model) => saveModelForProvider(provider, model);

  Future<void> saveModelForProvider(String provider, String model) {
    final prefKey =
        provider == providerOpenAi ? _keyOpenAiModel : _keyClaudeModel;
    return _prefs.setString(prefKey, model);
  }

  Future<void> clearApiKey() => clearApiKeyForProvider(provider);

  Future<void> clearApiKeyForProvider(String provider) {
    final prefKey =
        provider == providerOpenAi ? _keyOpenAiApiKey : _keyClaudeApiKey;
    return _prefs.remove(prefKey);
  }
}
