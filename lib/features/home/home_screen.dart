import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                      borderColor:
                          const Color(0xFF60A5FA).withOpacity(0.25),
                      onTap: () => context.push(AppRoutes.insights),
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      icon: Icons.history_outlined,
                      title: AppStrings.homeHistory,
                      subtitle: AppStrings.homeHistoryDesc,
                      onTap: () => context.push(AppRoutes.history),
                    ),
                    const SizedBox(height: 12),
                    _PremiumBanner(
                      onTap: () => context.push(AppRoutes.premium),
                    ),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pin Kodum',
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.homeSubtitle,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
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
          const Icon(
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
            const Icon(Icons.star, size: 28, color: AppColors.background),
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
            const Icon(Icons.chevron_right,
                color: AppColors.background, size: 20),
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
      decoration: const BoxDecoration(
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
