import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/theme_service.dart';
import '../../core/theme/app_theme_data.dart';
import '../../app/router.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/gradient_card.dart';
import '../../data/services/api_key_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/feedback_service.dart';
import '../../data/services/notification_service.dart';

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
  NotificationService? _notificationService;
  List<AppNotification> _unreadNotifications = const [];
  bool _notificationsLoading = false;

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
      var authUser = auth.currentUser;
      if (auth.isLoggedIn) {
        authUser = await auth.fetchMe() ?? authUser;
      }
      if (mounted) {
        setState(() {
          _apiKeyService = svc;
          _selectedProvider = svc.provider;
          _apiKeyController.text = svc.apiKey;
          _selectedModel = svc.model;
          _apiKeyLoaded = true;
          _authUser = authUser;
          _notificationService =
              auth.token == null ? null : NotificationService(auth.token!);
        });
      }
      await _loadUnreadNotifications();
    } catch (_) {
      if (mounted) setState(() => _apiKeyLoaded = true);
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final service = _notificationService;
    if (service == null) return;
    if (mounted) setState(() => _notificationsLoading = true);
    try {
      final unread = await service.getUnread();
      if (mounted) setState(() => _unreadNotifications = unread);
    } catch (_) {
      // Ayarlar bildirim sunucusu gecici olarak ulasilamaz olsa da acilsin.
    } finally {
      if (mounted) setState(() => _notificationsLoading = false);
    }
  }

  Future<void> _readNotification(AppNotification notification) async {
    await _showNotificationSheet(context, notification);
    final service = _notificationService;
    if (service == null) return;
    try {
      await service.markRead(notification.id);
      if (!mounted) return;
      setState(() {
        _unreadNotifications = _unreadNotifications
            .where((item) => item.id != notification.id)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    final prefs = await SharedPreferences.getInstance();
    await AuthService(prefs).logout();
    if (mounted) {
      setState(() {
        _authUser = null;
        _loggingOut = false;
      });
    }
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
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
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
                      const _SectionHeader('Hesap'),
                      const SizedBox(height: 12),
                      _authUser != null
                          ? GradientCard(
                              padding: const EdgeInsets.all(16),
                              borderColor:
                                  AppColors.gold.withValues(alpha: 0.2),
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
                                        child: Icon(Icons.person,
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
                                            if (_authUser!.birthDate != null)
                                              Text(
                                                'Doğum: ${_formatBirthDate(_authUser!.birthDate!)}',
                                                style: AppTextStyles.bodySmall,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_authUser!.hasActivePremium) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.gold
                                                .withValues(alpha: 0.22)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.star_outline,
                                                  size: 18,
                                                  color: AppColors.gold),
                                              const SizedBox(width: 8),
                                              Text('Premium Üyelik',
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                          color:
                                                              AppColors.gold)),
                                            ],
                                          ),
                                          if (_authUser!.premiumUntil !=
                                              null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              'Bitiş tarihi: ${_formatDate(_authUser!.premiumUntil!)}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                      color:
                                                          AppColors.textMuted),
                                            ),
                                          ],
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _QuotaItem(
                                                  label: 'Tekil Analiz',
                                                  remaining: _authUser!
                                                      .monthlySingleRemaining,
                                                  total: 10,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _QuotaItem(
                                                  label: 'İlişki Analizi',
                                                  remaining: _authUser!
                                                      .monthlyRelationshipRemaining,
                                                  total: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (!(_authUser!.isAdmin)) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.22),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.toll_outlined,
                                              size: 20, color: AppColors.gold),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Kredi Bakiyesi',
                                                    style: AppTextStyles
                                                        .labelMedium
                                                        .copyWith(
                                                            color: AppColors
                                                                .gold)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Detaylı analizlerde kullanılır.',
                                                  style:
                                                      AppTextStyles.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${_authUser!.credits} kredi',
                                            style: AppTextStyles.titleMedium
                                                .copyWith(
                                              color: AppColors.textGold,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                      // ── Admin Panel (yalnızca admin kullanıcıya görünür) ──
                      if (_authUser != null && _authUser!.isAdmin) ...[
                        const SizedBox(height: 8),
                        GradientCard(
                          padding: EdgeInsets.zero,
                          borderColor: AppColors.gold.withValues(alpha: 0.3),
                          child: _ActionTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Admin Panel',
                            onTap: () => context.push(AppRoutes.admin),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const _SectionHeader('Tercihler'),
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
                            const _InfoTile(
                              icon: Icons.language_outlined,
                              title: AppStrings.settingsLanguage,
                              trailing: AppStrings.settingsLanguageValue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GradientCard(
                        padding: const EdgeInsets.all(16),
                        child: _ThemePicker(),
                      ),
                      const SizedBox(height: 24),
                      if (_authUser != null && !_authUser!.isAdmin) ...[
                        const _SectionHeader('Bildirim Kutusu'),
                        const SizedBox(height: 12),
                        GradientCard(
                          padding: EdgeInsets.zero,
                          child: _NotificationInbox(
                            notifications: _unreadNotifications,
                            loading: _notificationsLoading,
                            onOpen: _readNotification,
                            onRefresh: _loadUnreadNotifications,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // ── Geri Bildirim ─────────────────────────────────
                      if (_authUser != null) ...[
                        const _SectionHeader('Geri Bildirim'),
                        const SizedBox(height: 12),
                        GradientCard(
                          padding: EdgeInsets.zero,
                          child: _ActionTile(
                            icon: Icons.feedback_outlined,
                            title: 'Geri Bildirim Gönder',
                            onTap: () => _showFeedbackSheet(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const _SectionHeader('Yasal'),
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
                      const _SectionHeader('Hakkında'),
                      const SizedBox(height: 12),
                      const GradientCard(
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
                              child: Icon(Icons.auto_awesome,
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

  String _formatBirthDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  void _showFeedbackSheet(BuildContext context) {
    String selectedType = 'dilek';
    final messageController = TextEditingController();
    bool sending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                Text('Geri Bildirim Gönder',
                    style: AppTextStyles.headlineLarge),
                const SizedBox(height: 6),
                Text('Dilek, şikayet veya talebini iletebilirsin.',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 20),
                Text('Kategori', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: FeedbackService.types.entries.map((e) {
                    final selected = selectedType == e.key;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.gold.withValues(alpha: 0.15)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppColors.gold : AppColors.border,
                          ),
                        ),
                        child: Text(
                          e.value,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: selected
                                ? AppColors.textGold
                                : AppColors.textPrimary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Mesaj', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  maxLength: 500,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Düşüncelerini yaz...',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GoldButton(
                    label: sending ? 'Gönderiliyor...' : 'Gönder',
                    icon: Icons.send_outlined,
                    loading: sending,
                    onPressed: sending
                        ? null
                        : () async {
                            final msg = messageController.text.trim();
                            if (msg.isEmpty) return;
                            setModalState(() => sending = true);
                            try {
                              await FeedbackService.send(
                                  type: selectedType, message: msg);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Geri bildiriminiz alındı, teşekkürler!'),
                                    backgroundColor: AppColors.surface,
                                  ),
                                );
                              }
                            } catch (_) {
                              setModalState(() => sending = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Gönderilemedi, tekrar dene.'),
                                    backgroundColor: AppColors.surface,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
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

  Future<void> _showNotificationSheet(
    BuildContext context,
    AppNotification notification,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(notification.title, style: AppTextStyles.headlineLarge),
              const SizedBox(height: 12),
              Text(notification.message, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 18),
              Text(
                'Okundu',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaItem extends StatelessWidget {
  final String label;
  final int remaining;
  final int total;

  const _QuotaItem(
      {required this.label, required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('$remaining',
                style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.gold, fontWeight: FontWeight.w700)),
            Text('/$total kaldı',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? remaining / total : 0,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            minHeight: 4,
          ),
        ),
      ],
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

class _ThemePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: ThemeService.instance.notifier,
      builder: (context, selectedTheme, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined,
                    size: 20, color: AppColors.textGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Tema', style: AppTextStyles.titleMedium),
                ),
                Text(selectedTheme.name, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: allThemes.map((theme) {
                final selected = theme.id == selectedTheme.id;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: theme == allThemes.first ? 6 : 0,
                      left: theme == allThemes.last ? 6 : 0,
                    ),
                    child: _ThemePreview(
                      theme: theme,
                      selected: selected,
                      onTap: () => ThemeService.instance.setTheme(theme),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationInbox extends StatelessWidget {
  final List<AppNotification> notifications;
  final bool loading;
  final ValueChanged<AppNotification> onOpen;
  final VoidCallback onRefresh;

  const _NotificationInbox({
    required this.notifications,
    required this.loading,
    required this.onOpen,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && notifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    if (notifications.isEmpty) {
      return _InfoTile(
        icon: Icons.notifications_none_outlined,
        title: 'Okunmamış bildirim yok',
        trailing: 'Yenile',
        onTap: onRefresh,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < notifications.length; index++) ...[
          _NotificationTile(
            notification: notifications[index],
            onTap: () => onOpen(notifications[index]),
          ),
          if (index != notifications.length - 1)
            Divider(height: 1, color: AppColors.border, indent: 56),
        ],
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = notification.type == 'announcement'
        ? Icons.campaign_outlined
        : Icons.auto_awesome_outlined;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final AppThemeData theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemePreview({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 114,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: theme.backgroundGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? theme.gold : theme.border,
              width: selected ? 1.5 : 0.8,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.gold.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.purple,
                      border: Border.all(color: theme.purpleLight),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.gold,
                      border: Border.all(color: theme.goldLight),
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, size: 17, color: theme.goldLight),
                ],
              ),
              const Spacer(),
              Text(
                theme.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                theme.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.textSecondary,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
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
            Text(trailing, style: AppTextStyles.bodyMedium),
          ],
        ),
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
            Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
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
              Icon(Icons.key_outlined, size: 16, color: AppColors.gold),
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
            decoration: InputDecoration(
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
              prefixIcon: Icon(Icons.vpn_key_outlined,
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
            decoration: InputDecoration(
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
                Icon(Icons.info_outline, size: 14, color: AppColors.warning),
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
