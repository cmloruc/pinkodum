import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/numerology_seal.dart';
import '../../data/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPremiumBanner = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
    AuthService.authChanges.addListener(_checkUser);
  }

  @override
  void dispose() {
    AuthService.authChanges.removeListener(_checkUser);
    super.dispose();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = AuthService(prefs).currentUser;
    if (!mounted) return;
    setState(() {
      _showPremiumBanner =
          !(user?.hasActivePremium ?? false) && !(user?.isAdmin ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _FeatureCard(
                      icon: Icons.person_search_outlined,
                      title: AppStrings.homeSingleAnalysis,
                      subtitle: AppStrings.homeSingleAnalysisDesc,
                      gradientColors: [
                        AppColors.gold.withOpacity(0.15),
                        AppColors.cardBackground,
                      ],
                      borderColor: AppColors.gold.withOpacity(0.3),
                      onTap: () => context.push(AppRoutes.singleForm),
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      icon: Icons.favorite_outline,
                      title: AppStrings.homeRelationshipAnalysis,
                      subtitle: AppStrings.homeRelationshipAnalysisDesc,
                      gradientColors: [
                        AppColors.purple.withOpacity(0.15),
                        AppColors.cardBackground,
                      ],
                      borderColor: AppColors.purple.withOpacity(0.3),
                      onTap: () => context.push(AppRoutes.relationshipForm),
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      icon: Icons.wb_sunny_outlined,
                      title: AppStrings.homeDailyInsight,
                      subtitle: AppStrings.homeDailyInsightDesc,
                      gradientColors: [
                        const Color(0xFF60A5FA).withOpacity(0.12),
                        AppColors.cardBackground,
                      ],
                      borderColor: const Color(0xFF60A5FA).withOpacity(0.25),
                      onTap: () => context.push(AppRoutes.insights),
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      icon: Icons.history_outlined,
                      title: AppStrings.homeHistory,
                      subtitle: AppStrings.homeHistoryDesc,
                      onTap: () => context.push(AppRoutes.history),
                    ),
                    if (_showPremiumBanner) ...[
                      const SizedBox(height: 12),
                      _PremiumBanner(
                        onTap: () => context.push(AppRoutes.premium),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _loading = true;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  int _credits = 0;

  @override
  void initState() {
    super.initState();
    AuthService.authChanges.addListener(_loadAuthState);
    _loadAuthState();
  }

  @override
  void dispose() {
    AuthService.authChanges.removeListener(_loadAuthState);
    super.dispose();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    final cachedUser = auth.currentUser;
    AuthUser? user = cachedUser;
    if (auth.isLoggedIn) {
      try {
        user = await auth.fetchMe();
      } catch (_) {
        user = cachedUser;
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoggedIn = auth.isLoggedIn;
      _isAdmin = user?.isAdmin ?? false;
      _credits = user?.credits ?? 0;
      _loading = false;
    });
  }

  Future<void> _openAuth(String route) async {
    await context.push(route);
    await _loadAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pin Kodum', style: AppTextStyles.displayMedium),
                    Text(
                      'NUMEROLOJİ',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.purpleLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_loading && _isLoggedIn && !_isAdmin) ...[
                const SizedBox(width: 12),
                _CreditBadge(credits: _credits),
              ] else if (!_loading && !_isLoggedIn) ...[
                const SizedBox(width: 12),
                _HeaderAuthButton(
                  label: 'Giriş',
                  icon: Icons.login,
                  onTap: () => _openAuth(AppRoutes.login),
                ),
                const SizedBox(width: 8),
                _HeaderAuthButton(
                  label: 'Üye Ol',
                  icon: Icons.person_add_alt_1,
                  filled: true,
                  onTap: () => _openAuth(AppRoutes.register),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          const NumerologySeal(size: 184),
          Text(
            AppStrings.homeSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _CreditBadge extends StatelessWidget {
  final int credits;
  const _CreditBadge({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.toll_outlined, size: 15, color: AppColors.gold),
          const SizedBox(width: 5),
          Text(
            '$credits kredi',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeaderAuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.onAction : AppColors.textGold;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.actionGradient : null,
            color: filled ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.action.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradientColors,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradientColors: gradientColors,
      borderColor: borderColor,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (borderColor ?? AppColors.purple).withValues(alpha: 0.2),
                  AppColors.surfaceLight.withValues(alpha: 0.72),
                ],
              ),
              border: Border.all(
                  color: borderColor ?? AppColors.border, width: 0.5),
            ),
            child: Icon(icon, size: 22, color: AppColors.textGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final VoidCallback? onTap;
  const _PremiumBanner({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.star, size: 28, color: AppColors.background),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.homePremium,
                    style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppStrings.homePremiumDesc,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.background.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.background, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1:
              context.push(AppRoutes.insights);
            case 2:
              context.push(AppRoutes.history);
            case 3:
              context.push(AppRoutes.settings);
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined), label: 'İçgörü'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined), label: 'Geçmiş'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Ayarlar'),
        ],
      ),
    );
  }
}
