import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_card.dart';
import '../../data/models/element_balance.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/element_balance_calculator.dart';
import '../../data/services/insight_service.dart';
import '../../data/services/pin_code_calculator.dart';
import '../../data/services/purchase_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _service = const InsightService();
  bool _loading = true;
  bool _isLoggedIn = false;
  bool _hasPersonalInsight = false;
  bool _hasInsightAccess = false;
  bool _isPremiumOrAdmin = false;
  bool _unlocking = false;
  String? _name;
  String? _daily;
  String? _weekly;
  String? _affirmation;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final today = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);

    var daily = _service.getDailyInsight(today);
    var weekly = _service.getWeeklyTheme(today);
    var affirmation = _service.getAffirmation(today);
    var hasPersonalInsight = false;
    var hasInsightAccess = false;
    var isPremiumOrAdmin = false;
    String? name;

    if (auth.isLoggedIn) {
      try {
        final user = await auth.fetchMe() ?? auth.currentUser;
        hasInsightAccess = user?.hasDailyInsightAccess ?? false;
        isPremiumOrAdmin = (user?.hasActivePremium ?? false) || (user?.isAdmin ?? false);
        final repo = await getRepository();
        final premiumAnalyses = await repo.getPremiumAnalyses();
        final standardAnalyses = await repo.getPersonAnalyses();

        ElementBalance? balance;
        List<int>? pinCode;
        String? focusText;
        var birthDate = user?.birthDate;
        DateTime? createdAt;
        name = user?.name;

        if (birthDate != null) {
          pinCode = const PinCodeCalculator().calculate(birthDate);
          balance = const ElementBalanceCalculator().calculate(pinCode);
        }

        if (premiumAnalyses.isNotEmpty) {
          premiumAnalyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final latest = premiumAnalyses.first;
          name ??= latest.name;
          birthDate ??= latest.birthDate;
          pinCode ??= latest.pinCode;
          balance ??=
              const ElementBalanceCalculator().calculate(latest.pinCode);
          focusText = latest.resolvedOverallSummary;
          createdAt = latest.createdAt;
        }

        if (standardAnalyses.isNotEmpty) {
          standardAnalyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final latest = standardAnalyses.first;
          if (createdAt == null || latest.createdAt.isAfter(createdAt)) {
            name ??= latest.name;
            birthDate ??= latest.birthDate;
            pinCode ??= latest.pinCode;
            balance ??= latest.elementBalance;
            focusText = latest.summary;
          }
        }

        if (name != null &&
            birthDate != null &&
            pinCode != null &&
            balance != null) {
          daily = _service.getPersonalDailyInsight(
            name: name,
            date: today,
            birthDate: birthDate,
            pinCode: pinCode,
            elementBalance: balance,
            focusText: focusText,
          );
          weekly = _service.getPersonalWeeklyTheme(balance);
          affirmation = _service.getPersonalAffirmation(name, balance);
          hasPersonalInsight = true;
        }
      } catch (e) {
        debugPrint('Personal insight load error: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoggedIn = auth.isLoggedIn;
      _hasPersonalInsight = hasPersonalInsight;
      _hasInsightAccess = hasInsightAccess;
      _isPremiumOrAdmin = isPremiumOrAdmin;
      _name = name;
      _daily = daily;
      _weekly = weekly;
      _affirmation = affirmation;
      _loading = false;
    });
  }

  Future<void> _unlockDailyInsight() async {
    if (_unlocking) return;
    if (!_isLoggedIn) {
      await context.push(AppRoutes.login);
      _loadInsights();
      return;
    }

    setState(() => _unlocking = true);
    try {
      await PurchaseService().unlockDailyInsight();
      await _loadInsights();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Günlük içgörü 24 saat açıldı.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _unlocking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

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
                      child: Text(AppStrings.insightTitle,
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Gün bilgisi
                            _DateBadge(date: today),
                            const SizedBox(height: 20),
                            _InsightModeCard(
                              isLoggedIn: _isLoggedIn,
                              hasPersonalInsight: _hasPersonalInsight,
                              name: _name,
                              onLogin: () async {
                                await context.push(AppRoutes.login);
                                _loadInsights();
                              },
                              onCreateAnalysis: () async {
                                await context.push(AppRoutes.singleForm);
                                _loadInsights();
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_hasInsightAccess) ...[
                              _InsightSection(
                                icon: Icons.wb_sunny,
                                iconColor: AppColors.gold,
                                title: AppStrings.insightTitle,
                                content: _daily ?? '',
                                gradientColors: [
                                  AppColors.gold.withValues(alpha: 0.08),
                                  AppColors.cardBackground,
                                ],
                                borderColor:
                                    AppColors.gold.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              _InsightSection(
                                icon: Icons.calendar_view_week_outlined,
                                iconColor: AppColors.purpleLight,
                                title: AppStrings.insightWeeklyTheme,
                                content: _weekly ?? '',
                                gradientColors: [
                                  AppColors.purple.withValues(alpha: 0.08),
                                  AppColors.cardBackground,
                                ],
                                borderColor:
                                    AppColors.purple.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              _AffirmationCard(text: _affirmation ?? ''),
                              const SizedBox(height: 16),
                            ] else ...[
                              _InsightAccessCard(
                                isLoggedIn: _isLoggedIn,
                                unlocking: _unlocking,
                                onUnlock: _unlockDailyInsight,
                                onPremium: () =>
                                    context.push(AppRoutes.premium),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Premium teaser
                            if (!_isPremiumOrAdmin)
                              _PremiumTeaser(
                                onTap: () => context.push(AppRoutes.premium),
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
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  const _DateBadge({required this.date});

  static const _months = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        '${date.day} ${_months[date.month]} ${date.year}',
        style: AppTextStyles.labelMedium,
      ),
    );
  }
}

class _InsightModeCard extends StatelessWidget {
  final bool isLoggedIn;
  final bool hasPersonalInsight;
  final String? name;
  final VoidCallback onLogin;
  final VoidCallback onCreateAnalysis;

  const _InsightModeCard({
    required this.isLoggedIn,
    required this.hasPersonalInsight,
    required this.name,
    required this.onLogin,
    required this.onCreateAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPersonalInsight) {
      return _StatusCard(
        icon: Icons.auto_awesome,
        title: '${name ?? 'Senin'} için kişisel içgörü',
        description:
            'Bu mesaj en son pin kodu analizin ve element dengene göre hazırlandı.',
        actionLabel: null,
        onTap: null,
      );
    }

    if (!isLoggedIn) {
      return _StatusCard(
        icon: Icons.lock_outline,
        title: 'Genel içgörü gösteriliyor',
        description:
            'Kişisel günlük içgörü için giriş yapıp pin kodunu oluşturabilirsin.',
        actionLabel: 'Giriş Yap',
        onTap: onLogin,
      );
    }

    return _StatusCard(
      icon: Icons.person_search_outlined,
      title: 'Genel içgörü gösteriliyor',
      description:
          'Kişisel günlük içgörü için önce tek kişi analizini oluşturman gerekiyor.',
      actionLabel: 'Pin Kodumu Oluştur',
      onTap: onCreateAnalysis,
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      borderColor: AppColors.gold.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySmall),
                if (actionLabel != null && onTap != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final List<Color>? gradientColors;
  final Color? borderColor;

  const _InsightSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.gradientColors,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradientColors: gradientColors,
      borderColor: borderColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.labelMedium.copyWith(color: iconColor)),
            ],
          ),
          const SizedBox(height: 14),
          Text(content, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

class _InsightAccessCard extends StatelessWidget {
  final bool isLoggedIn;
  final bool unlocking;
  final VoidCallback onUnlock;
  final VoidCallback onPremium;

  const _InsightAccessCard({
    required this.isLoggedIn,
    required this.unlocking,
    required this.onUnlock,
    required this.onPremium,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      borderColor: AppColors.gold.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 34, color: AppColors.gold),
          const SizedBox(height: 12),
          Text('Günlük içgörü premiumlara özel',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            isLoggedIn
                ? '1 kredi ile 24 saatlik erişim açabilir veya premium paketle sınırsız erişebilirsin.'
                : 'Günlük içgörüyü açmak için giriş yapabilir veya premium pakete geçebilirsin.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: unlocking ? null : onUnlock,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: unlocking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Text(
                            isLoggedIn ? '1 Kredi ile Aç' : 'Giriş Yap',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onPremium,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text('Premium',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textGold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AffirmationCard extends StatelessWidget {
  final String text;
  const _AffirmationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.format_quote, size: 28, color: Colors.white54),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.insightAffirmation,
            style: AppTextStyles.labelMedium.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _PremiumTeaser extends StatelessWidget {
  final VoidCallback? onTap;
  const _PremiumTeaser({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GradientCard(
        borderColor: AppColors.gold.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(
                  AppStrings.insightPremiumTeaser,
                  style:
                      AppTextStyles.labelMedium.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.insightPremiumLocked,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Premium\'a Geç →',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
