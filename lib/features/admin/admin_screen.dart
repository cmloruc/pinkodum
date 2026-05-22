import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_card.dart';
import '../../data/services/admin_service.dart';
import '../../data/services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  AdminStats? _stats;
  List<AdminUser>? _users;
  AiConfig? _aiConfig;
  AiBillingSummary? _aiBilling;
  List<AdminFeedback>? _feedbacks;
  bool _loading = true;
  String? _error;
  AdminService? _adminService;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthService(prefs);
      final token = auth.token;
      if (token == null) throw Exception('Oturum bulunamadı.');
      final svc = AdminService(token);
      _adminService = svc;
      final results = await Future.wait([
        svc.getStats(),
        svc.getUsers(),
        svc.getAiConfig(),
        svc.getAiBilling(),
        svc.getFeedbacks(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as AdminStats;
          _users = results[1] as List<AdminUser>;
          _aiConfig = results[2] as AiConfig;
          _aiBilling = results[3] as AiBillingSummary;
          _feedbacks = results[4] as List<AdminFeedback>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _showCreditDialog(AdminUser user) async {
    final controller = TextEditingController(text: user.credits.toString());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Kredi Ayarla', style: AppTextStyles.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(labelText: 'Kredi miktarı'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('İptal', style: AppTextStyles.bodySmall),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Kaydet',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final credits = int.tryParse(controller.text.trim());
    if (credits == null || credits < 0) return;

    try {
      await _adminService!.setCredits(user.id, credits);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                      child: Text('Admin Panel',
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh,
                          size: 20, color: AppColors.textMuted),
                      onPressed: _load,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.gold))
                    : _error != null
                        ? _ErrorView(error: _error!, onRetry: _load)
                        : _Body(
                            stats: _stats!,
                            users: _users!,
                            aiConfig: _aiConfig!,
                            aiBilling: _aiBilling!,
                            feedbacks: _feedbacks!,
                            onCreditTap: _showCreditDialog,
                            adminService: _adminService!,
                            onReload: _load,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(error,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text('Tekrar Dene',
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final AdminStats stats;
  final List<AdminUser> users;
  final AiConfig aiConfig;
  final AiBillingSummary aiBilling;
  final List<AdminFeedback> feedbacks;
  final void Function(AdminUser) onCreditTap;
  final AdminService adminService;
  final VoidCallback onReload;

  const _Body({
    required this.stats,
    required this.users,
    required this.aiConfig,
    required this.aiBilling,
    required this.feedbacks,
    required this.onCreditTap,
    required this.adminService,
    required this.onReload,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onPremiumToggle(AdminUser user, bool activate) async {
    try {
      await widget.adminService.setPremium(user.id, activate: activate);
      widget.onReload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  List<AdminUser> get _filtered {
    if (_query.isEmpty) return widget.users;
    return widget.users.where((u) {
      return u.name.toLowerCase().contains(_query) ||
          u.email.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppColors.background,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.labelMedium,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(4),
            tabs: [
              const Tab(text: 'İstatistik'),
              const Tab(text: 'Kullanıcılar'),
              const Tab(text: 'AI Config'),
              const Tab(text: 'Bildirimler'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Geri Bildirimler'),
                    if (widget.feedbacks.any((f) => !f.isRead)) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ── Tab 1: İstatistikler ──
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [_StatsGrid(stats: widget.stats)],
              ),

              // ── Tab 2: Kullanıcılar ──
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'İsim veya e-posta ara...',
                        prefixIcon: Icon(Icons.search,
                            size: 20, color: AppColors.textMuted),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close,
                                    size: 18, color: AppColors.textMuted),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          _query.isEmpty
                              ? '${widget.users.length} kullanıcı'
                              : '${_filtered.length} sonuç',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Sonuç bulunamadı',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _UserTile(
                                user: _filtered[i],
                                onCreditTap: widget.onCreditTap,
                                onPremiumToggle: _onPremiumToggle,
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              // ── Tab 3: AI Config ──
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  _AiBillingCard(summary: widget.aiBilling),
                  const SizedBox(height: 12),
                  _AiConfigCard(
                    config: widget.aiConfig,
                    adminService: widget.adminService,
                    onSaved: widget.onReload,
                  ),
                ],
              ),

              // ── Tab 4: Kullanıcı bildirimleri ──
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  _BroadcastCard(adminService: widget.adminService),
                ],
              ),

              // ── Tab 5: Kullanıcılardan gelen geri bildirimler ──
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  const _FeedbackHeader(),
                  const SizedBox(height: 12),
                  if (widget.feedbacks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text('Henüz geri bildirim yok.',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    ...widget.feedbacks.map((fb) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FeedbackTile(
                            feedback: fb,
                            onRead: () async {
                              if (!fb.isRead) {
                                await widget.adminService
                                    .markFeedbackRead(fb.id);
                                widget.onReload();
                              }
                            },
                          ),
                        )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Toplam Kullanıcı',
                    value: '${stats.totalUsers}',
                    icon: Icons.people_outline)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Toplam Analiz',
                    value: '${stats.totalAnalyses}',
                    icon: Icons.analytics_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Premium Üye',
                    value: '${stats.premiumUsers}',
                    icon: Icons.star_outline,
                    highlight: true)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Bugün Yeni',
                    value: '${stats.newUsersToday}',
                    icon: Icons.person_add_outlined)),
          ],
        ),
        if (stats.analysesByType.isNotEmpty) ...[
          const SizedBox(height: 10),
          GradientCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analiz Türleri', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                ...stats.analysesByType.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(_typeLabel(s.type),
                                  style: AppTextStyles.bodySmall)),
                          Text('${s.count}',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.gold)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'single':
        return 'Tekil (Ücretsiz)';
      case 'single_premium':
        return 'Tekil (Detaylı)';
      case 'relationship':
        return 'İlişki (Ücretsiz)';
      case 'relationship_premium':
        return 'İlişki (Detaylı)';
      default:
        return type;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(14),
      borderColor:
          highlight ? AppColors.gold.withValues(alpha: 0.3) : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: highlight ? AppColors.gold : AppColors.textMuted),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.headlineLarge.copyWith(
                  color: highlight ? AppColors.gold : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AdminUser user;
  final void Function(AdminUser) onCreditTap;
  final void Function(AdminUser, bool) onPremiumToggle;

  const _UserTile(
      {required this.user,
      required this.onCreditTap,
      required this.onPremiumToggle});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(14),
      borderColor: user.isAdmin
          ? AppColors.gold.withValues(alpha: 0.3)
          : AppColors.border,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.isPremium
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.surfaceLight,
            ),
            child: Icon(
              user.isAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.person_outline,
              size: 18,
              color: user.isPremium ? AppColors.gold : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name.isNotEmpty ? user.name : user.email,
                        style: AppTextStyles.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isPremium)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Premium',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gold, fontSize: 10)),
                      ),
                  ],
                ),
                Text(user.email,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
                Text(
                  _formatDate(user.createdAt),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: () => onPremiumToggle(user, !user.isPremium),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: user.isPremium
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: user.isPremium
                            ? AppColors.gold.withValues(alpha: 0.4)
                            : AppColors.border),
                  ),
                  child: Text(
                    user.isPremium ? '★ Premium' : '☆ Premium',
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          user.isPremium ? AppColors.gold : AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => onCreditTap(user),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.2)),
                  ),
                  child: Text('${user.credits} kr',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gold, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader();

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.gold.withValues(alpha: 0.18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 20,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kullanıcı Geri Bildirimleri',
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: 2),
                Text(
                  'Talep, şikayet, dilek ve diğer mesajlar burada toplanır.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feedback Tile ─────────────────────────────────────────────────────────────

class _FeedbackTile extends StatelessWidget {
  final AdminFeedback feedback;
  final VoidCallback onRead;
  const _FeedbackTile({required this.feedback, required this.onRead});

  Color get _typeColor {
    switch (feedback.type) {
      case 'sikayet':
        return AppColors.error;
      case 'talep':
        return AppColors.gold;
      case 'dilek':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRead,
      child: GradientCard(
        padding: const EdgeInsets.all(14),
        borderColor: feedback.isRead
            ? AppColors.border
            : AppColors.gold.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    feedback.typeLabel,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: _typeColor, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedback.userName ?? feedback.userEmail ?? 'Anonim',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!feedback.isRead)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                  ),
                const SizedBox(width: 6),
                Text(
                  '${feedback.createdAt.day.toString().padLeft(2, '0')}.${feedback.createdAt.month.toString().padLeft(2, '0')}.${feedback.createdAt.year}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.message, style: AppTextStyles.bodyMedium),
            if (!feedback.isRead) ...[
              const SizedBox(height: 6),
              Text('Okundu olarak işaretle için dokun',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted, fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── AI Billing Card ───────────────────────────────────────────────────────────

class _AiBillingCard extends StatelessWidget {
  final AiBillingSummary summary;
  const _AiBillingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.gold.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('AI Maliyet',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bu ayki API maliyeti',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          ...summary.providers.map(
            (provider) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AiBillingProviderRow(provider: provider),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Kalan bakiye sağlayıcı API tarafından verilmediği için panelde '
              'yalnızca resmi maliyet raporu gösterilir.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBillingProviderRow extends StatelessWidget {
  final AiBillingProvider provider;
  const _AiBillingProviderRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final ready = provider.status == 'ready';
    final color = ready ? AppColors.success : AppColors.textMuted;
    final detail = switch (provider.status) {
      'ready' => '\$${provider.monthSpendUsd!.toStringAsFixed(2)}',
      'needs_admin_key' => provider.missingSecret ?? 'Admin key gerekli',
      _ => provider.message ?? 'Maliyet alınamadı',
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            provider.provider == 'openai'
                ? Icons.bubble_chart_outlined
                : Icons.auto_awesome_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.label, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  ready ? 'Ay başından bugüne' : 'Maliyet erişimi bekliyor',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontFamily: ready ? null : 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Config Card ────────────────────────────────────────────────────────────

class _AiConfigCard extends StatefulWidget {
  final AiConfig config;
  final AdminService adminService;
  final VoidCallback onSaved;

  const _AiConfigCard({
    required this.config,
    required this.adminService,
    required this.onSaved,
  });

  @override
  State<_AiConfigCard> createState() => _AiConfigCardState();
}

class _AiConfigCardState extends State<_AiConfigCard> {
  static final _claudeModels = {
    'claude-haiku-4-5-20251001': 'Claude Haiku 4.5 (Hızlı)',
    'claude-sonnet-4-6': 'Claude Sonnet 4.6 (Dengeli)',
    'claude-opus-4-7': 'Claude Opus 4.7 (Güçlü)',
  };
  static final _openaiModels = {
    'o4-mini': 'o4-mini (Hızlı)',
    'o3': 'o3 (Güçlü)',
  };

  late String _provider;
  late String _model;
  final _keyController = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _provider = widget.config.provider;
    _model = widget.config.model;
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Map<String, String> get _currentModels =>
      _provider == 'openai' ? _openaiModels : _claudeModels;

  void _onProviderChanged(String? p) {
    if (p == null) return;
    final defaultModel =
        p == 'openai' ? 'o4-mini' : 'claude-haiku-4-5-20251001';
    setState(() {
      _provider = p;
      _model = _currentModels.containsKey(widget.config.model) &&
              p == widget.config.provider
          ? widget.config.model
          : defaultModel;
      _status = null;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _status = null;
    });
    try {
      final apiKey = _keyController.text.trim().isEmpty
          ? null
          : _keyController.text.trim();
      await widget.adminService.setAiConfig(_provider, _model, apiKey: apiKey);
      if (mounted) setState(() => _status = 'success');
      widget.onSaved();
    } catch (e) {
      if (mounted) setState(() => _status = 'error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedKey = widget.config.apiKeyMasked;

    return GradientCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('AI Sağlayıcı',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.gold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.config.provider == 'openai' ? 'OpenAI' : 'Claude',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.success, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Sağlayıcı', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _provider,
            dropdownColor: AppColors.surfaceLight,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.hub_outlined,
                  color: AppColors.textMuted, size: 18),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'claude', child: Text('Anthropic Claude')),
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
            ],
            onChanged: _onProviderChanged,
          ),
          const SizedBox(height: 12),
          Text('Model', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _currentModels.containsKey(_model)
                ? _model
                : _currentModels.keys.first,
            dropdownColor: AppColors.surfaceLight,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.model_training_outlined,
                  color: AppColors.textMuted, size: 18),
            ),
            items: _currentModels.entries
                .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (m) => setState(() => _model = m!),
          ),
          const SizedBox(height: 12),
          Text('API Anahtarı', style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text('Mevcut: $maskedKey',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _keyController,
            obscureText: _obscure,
            style: AppTextStyles.bodyMedium
                .copyWith(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Değiştirmek için yeni anahtarı gir',
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.background),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _status == 'success'
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _status == 'success'
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _status == 'success'
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    size: 16,
                    color: _status == 'success'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _status == 'success'
                        ? 'AI yapılandırması güncellendi ✓'
                        : 'Güncelleme başarısız.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _status == 'success'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Toplu Bildirim Kartı ──────────────────────────────────────────────────────
class _BroadcastCard extends StatefulWidget {
  final AdminService adminService;
  const _BroadcastCard({required this.adminService});

  @override
  State<_BroadcastCard> createState() => _BroadcastCardState();
}

class _BroadcastCardState extends State<_BroadcastCard> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;
  String _type = 'affirmation';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isEmpty || message.isEmpty) return;

    setState(() => _sending = true);
    try {
      final result = await widget.adminService.sendBroadcast(
        title,
        message,
        type: _type,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gönderildi: ${result.sent} kullanıcı'
                '${result.failed > 0 ? ', ${result.failed} başarısız' : ''}'),
            backgroundColor: AppColors.success,
          ),
        );
        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text('Kullanıcılara Bildirim Gönder',
                  style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              hintText: 'Günün Olumlaması',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _type,
            dropdownColor: AppColors.surfaceLight,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(labelText: 'Bildirim tipi'),
            items: const [
              DropdownMenuItem(value: 'affirmation', child: Text('Olumlama')),
              DropdownMenuItem(value: 'announcement', child: Text('Duyuru')),
            ],
            onChanged: _sending
                ? null
                : (value) => setState(() => _type = value ?? 'affirmation'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            style: AppTextStyles.bodyMedium,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mesaj',
              hintText: 'Bugün harika şeyler seni bekliyor...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _sending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.background),
                    )
                  : const Text('Tüm Kullanıcılara Gönder'),
            ),
          ),
        ],
      ),
    );
  }
}
