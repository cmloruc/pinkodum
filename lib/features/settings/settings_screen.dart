import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/router.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/gradient_card.dart';
import '../../data/services/api_key_service.dart';
import '../../data/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  ApiKeyService? _apiKeyService;
  final _apiKeyController = TextEditingController();
  String _selectedProvider = ApiKeyService.defaultProvider;
  String _selectedModel = ApiKeyService.defaultModel;
  bool _apiKeyLoaded = false;
  bool _saving = false;
  String? _saveStatus;
  AuthUser? _authUser;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final svc = ApiKeyService(prefs);
      final auth = AuthService(prefs);
      if (mounted) {
        setState(() {
          _apiKeyService = svc;
          _selectedProvider = svc.provider;
          _apiKeyController.text = svc.apiKey;
          _selectedModel = svc.model;
          _apiKeyLoaded = true;
          _authUser = auth.currentUser;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _apiKeyLoaded = true);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    final prefs = await SharedPreferences.getInstance();
    await AuthService(prefs).logout();
    if (mounted) setState(() { _authUser = null; _loggingOut = false; });
  }

  Future<void> _saveApiKey() async {
    final svc = _apiKeyService;
    if (svc == null) return;
    setState(() {
      _saving = true;
      _saveStatus = null;
    });
    try {
      await svc.saveProvider(_selectedProvider);
      await svc.saveApiKeyForProvider(
        _selectedProvider,
        _apiKeyController.text,
      );
      await svc.saveModelForProvider(_selectedProvider, _selectedModel);
      if (mounted) setState(() => _saveStatus = 'success');
    } catch (_) {
      if (mounted) setState(() => _saveStatus = 'error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _changeProvider(String? provider) {
    final svc = _apiKeyService;
    if (provider == null || svc == null) return;
    setState(() {
      _selectedProvider = provider;
      _apiKeyController.text = svc.apiKeyForProvider(provider);
      _selectedModel = svc.modelForProvider(provider);
      _saveStatus = null;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(AppStrings.settingsTitle,
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hesap Bölümü ──────────────────────────────────
                      _SectionHeader('Hesap'),
                      const SizedBox(height: 12),
                      _authUser != null
                          ? GradientCard(
                              padding: const EdgeInsets.all(16),
                              borderColor: AppColors.gold.withValues(alpha: 0.2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColors.goldGradient,
                                        ),
                                        child: const Icon(Icons.person,
                                            size: 20,
                                            color: AppColors.background),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_authUser!.name,
                                                style:
                                                    AppTextStyles.titleMedium),
                                            Text(_authUser!.email,
                                                style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  GhostButton(
                                    label: _loggingOut
                                        ? 'Çıkış yapılıyor...'
                                        : 'Çıkış Yap',
                                    icon: Icons.logout,
                                    onPressed: _loggingOut ? null : _logout,
                                  ),
                                ],
                              ),
                            )
                          : GradientCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Giriş yaparak analizlerini tüm cihazlarda senkronize et.',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 14),
                                  GoldButton(
                                    label: 'Giriş Yap',
                                    icon: Icons.login,
                                    onPressed: () async {
                                      await context.push(AppRoutes.login);
                                      _loadSettings();
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  GhostButton(
                                    label: 'Hesap Oluştur',
                                    icon: Icons.person_add_outlined,
                                    onPressed: () async {
                                      await context.push(AppRoutes.register);
                                      _loadSettings();
                                    },
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 24),
                      // ── AI API Bölümü ─────────────────────────────────
                      _SectionHeader('AI API'),
                      const SizedBox(height: 8),
                      if (!_apiKeyLoaded)
                        const Center(
                          child:
                              CircularProgressIndicator(color: AppColors.gold),
                        )
                      else
                        _ApiKeySection(
                          controller: _apiKeyController,
                          selectedProvider: _selectedProvider,
                          selectedModel: _selectedModel,
                          onProviderChanged: _changeProvider,
                          onModelChanged: (m) =>
                              setState(() => _selectedModel = m!),
                          onSave: _saveApiKey,
                          saving: _saving,
                          saveStatus: _saveStatus,
                        ),
                      const SizedBox(height: 24),
                      _SectionHeader('Tercihler'),
                      const SizedBox(height: 12),
                      GradientCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _ToggleTile(
                              icon: Icons.notifications_outlined,
                              title: AppStrings.settingsNotifications,
                              subtitle: AppStrings.settingsNotificationsDesc,
                              value: _notificationsEnabled,
                              onChanged: (v) =>
                                  setState(() => _notificationsEnabled = v),
                            ),
                            Divider(
                                height: 1, color: AppColors.border, indent: 56),
                            _InfoTile(
                              icon: Icons.language_outlined,
                              title: AppStrings.settingsLanguage,
                              trailing: AppStrings.settingsLanguageValue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader('Yasal'),
                      const SizedBox(height: 12),
                      GradientCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _ActionTile(
                              icon: Icons.shield_outlined,
                              title: AppStrings.settingsPrivacy,
                              onTap: () => _showLegalSheet(
                                  context, 'Gizlilik Politikası', _privacyText),
                            ),
                            Divider(
                                height: 1, color: AppColors.border, indent: 56),
                            _ActionTile(
                              icon: Icons.article_outlined,
                              title: AppStrings.settingsTerms,
                              onTap: () => _showLegalSheet(
                                  context, 'Kullanım Şartları', _termsText),
                            ),
                            Divider(
                                height: 1, color: AppColors.border, indent: 56),
                            _ActionTile(
                              icon: Icons.warning_amber_outlined,
                              title: AppStrings.settingsDisclaimer,
                              onTap: () => _showLegalSheet(
                                  context,
                                  'Kullanım Uyarısı',
                                  AppStrings.legalDisclaimer),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader('Hakkında'),
                      const SizedBox(height: 12),
                      GradientCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _InfoTile(
                              icon: Icons.info_outline,
                              title: AppStrings.settingsAbout,
                              trailing: AppStrings.settingsVersion,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Uygulama logosu
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.goldGradient,
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  size: 24, color: AppColors.background),
                            ),
                            const SizedBox(height: 8),
                            Text('Pin Kodum',
                                style: AppTextStyles.headlineMedium),
                            const SizedBox(height: 4),
                            Text(AppStrings.settingsVersion,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.headlineLarge),
              const SizedBox(height: 16),
              Text(content, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGold));
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
          Text(trailing, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

const _privacyText = '''
Pin Kodum uygulaması kullanıcı verilerini korumayı taahhüt eder.

Toplanan Veriler:
Şu an uygulamamız kişisel veri toplamaz. Tüm analizler cihazınızda yerel olarak saklanır.

İleride:
Hesap oluşturma özelliği eklendiğinde, bu politika güncellenecek ve onayınız istenecektir.

Üçüncü Taraflar:
Üçüncü taraflarla veri paylaşmıyoruz.

İletişim:
Gizlilik ile ilgili sorularınız için uygulamayı güncelleyip bu politikayı yeniden inceleyebilirsiniz.
''';

const _termsText = '''
Pin Kodum'u kullanarak aşağıdaki koşulları kabul etmiş sayılırsınız:

1. Kullanım Amacı
Uygulama kişisel farkındalık ve eğlence amaçlıdır. Profesyonel danışmanlık yerine geçmez.

2. İçerik
Numeroloji analizleri öznel değerlendirmeler içerir. Kesinlik iddiası taşımaz.

3. Sorumluluk
Uygulama içeriğine dayanarak alınan kararların sorumluluğu kullanıcıya aittir.

4. Değişiklikler
Bu koşullar önceden bildirim yapılmaksızın güncellenebilir.

5. Uygulanacak Hukuk
Türkiye Cumhuriyeti hukuku geçerlidir.
''';

// ─── API Anahtarı Bölümü ─────────────────────────────────────────────────────
class _ApiKeySection extends StatefulWidget {
  final TextEditingController controller;
  final String selectedProvider;
  final String selectedModel;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<String?> onModelChanged;
  final VoidCallback onSave;
  final bool saving;
  final String? saveStatus;

  const _ApiKeySection({
    required this.controller,
    required this.selectedProvider,
    required this.selectedModel,
    required this.onProviderChanged,
    required this.onModelChanged,
    required this.onSave,
    this.saving = false,
    this.saveStatus,
  });

  @override
  State<_ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends State<_ApiKeySection> {
  bool _obscure = true;
  bool _testing = false;
  String? _testResult; // 'success' | 'error'
  String? _testMessage;

  Future<void> _testConnection() async {
    final key = widget.controller.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = 'error';
        _testMessage = 'Önce API anahtarını gir.';
      });
      return;
    }
    setState(() {
      _testing = true;
      _testResult = null;
      _testMessage = null;
    });
    try {
      final isOpenAi = widget.selectedProvider == ApiKeyService.providerOpenAi;
      final response = await http
          .post(
            Uri.parse(
              isOpenAi
                  ? 'https://api.openai.com/v1/responses'
                  : 'https://api.anthropic.com/v1/messages',
            ),
            headers: isOpenAi
                ? {
                    'authorization': 'Bearer $key',
                    'content-type': 'application/json',
                  }
                : {
                    'x-api-key': key,
                    'anthropic-version': '2023-06-01',
                    'content-type': 'application/json',
                  },
            body: jsonEncode(
              isOpenAi
                  ? {
                      'model': widget.selectedModel,
                      'input': 'Merhaba. Sadece JSON cevap ver: {"ok": true}',
                      'max_output_tokens': 32,
                      'text': {
                        'format': {'type': 'json_object'},
                      },
                    }
                  : {
                      'model': widget.selectedModel,
                      'max_tokens': 16,
                      'messages': [
                        {'role': 'user', 'content': 'Merhaba'},
                      ],
                    },
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final label = ApiKeyService.providerLabels[widget.selectedProvider];
        setState(() {
          _testResult = 'success';
          _testMessage = 'Bağlantı başarılı! $label yanıt verdi.';
        });
      } else {
        var msg = 'Bilinmeyen hata';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final error = body['error'];
          if (error is Map<String, dynamic>) {
            msg = error['message']?.toString() ?? msg;
          }
        } catch (_) {
          if (response.body.trim().isNotEmpty) msg = response.body;
        }
        setState(() {
          _testResult = 'error';
          _testMessage = 'Hata ${response.statusCode}: $msg';
        });
      }
    } on Exception catch (e) {
      setState(() {
        _testResult = 'error';
        _testMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLabel =
        ApiKeyService.providerLabels[widget.selectedProvider] ?? 'AI';
    final modelOptions = widget.selectedProvider == ApiKeyService.providerOpenAi
        ? ApiKeyService.openAiModels
        : ApiKeyService.claudeModels;
    final keyHint = widget.selectedProvider == ApiKeyService.providerOpenAi
        ? 'sk-proj-...'
        : 'sk-ant-...';

    return GradientCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key_outlined, size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('$providerLabel API Anahtarı',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$providerLabel API anahtarınızı girerek gerçek AI analizleri alın. '
            'Anahtar girilmezse örnek analizler gösterilir.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          // Sağlayıcı seçimi
          Text('Sağlayıcı', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: widget.selectedProvider,
            dropdownColor: AppColors.surfaceLight,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.hub_outlined,
                  color: AppColors.textMuted, size: 18),
            ),
            items: ApiKeyService.providerLabels.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: AppTextStyles.bodySmall),
                    ))
                .toList(),
            onChanged: widget.onProviderChanged,
          ),
          const SizedBox(height: 12),
          // API Key alanı
          TextFormField(
            controller: widget.controller,
            obscureText: _obscure,
            style: AppTextStyles.bodyMedium
                .copyWith(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              hintText: keyHint,
              prefixIcon: const Icon(Icons.vpn_key_outlined,
                  color: AppColors.textMuted, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Model seçimi
          Text('Model', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: widget.selectedModel,
            dropdownColor: AppColors.surfaceLight,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.psychology_outlined,
                  color: AppColors.textMuted, size: 18),
            ),
            items: modelOptions.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: AppTextStyles.bodySmall),
                    ))
                .toList(),
            onChanged: widget.onModelChanged,
          ),
          const SizedBox(height: 16),
          GoldButton(
            label: 'Kaydet',
            icon: Icons.save_outlined,
            loading: widget.saving,
            onPressed: widget.saving ? null : widget.onSave,
          ),
          // Kaydetme durumu
          if (widget.saveStatus != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: widget.saveStatus == 'success'
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.saveStatus == 'success'
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.saveStatus == 'success'
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    size: 16,
                    color: widget.saveStatus == 'success'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.saveStatus == 'success'
                        ? 'API anahtarı kaydedildi ✓'
                        : 'Kaydetme başarısız. Tekrar dene.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: widget.saveStatus == 'success'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Test bağlantı butonu
          GhostButton(
            label: _testing ? 'Test ediliyor...' : 'Bağlantıyı Test Et',
            icon: Icons.wifi_tethering_outlined,
            onPressed: _testing ? null : _testConnection,
          ),
          // Test sonucu
          if (_testResult != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _testResult == 'success'
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _testResult == 'success'
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _testResult == 'success'
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    size: 16,
                    color: _testResult == 'success'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testMessage ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _testResult == 'success'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // CORS uyarısı (web için)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'API anahtarı cihazınızda yerel olarak saklanır. '
                    'Web tarayıcısında CORS kısıtlaması nedeniyle doğrudan API '
                    'çağrısı çalışmayabilir. iOS/Android için uygundur.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
