import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_card.dart';
import '../../data/services/insight_service.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    const service = InsightService();
    final daily = service.getDailyInsight(today);
    final weekly = service.getWeeklyTheme(today);
    final affirmation = service.getAffirmation(today);

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Gün bilgisi
                      _DateBadge(date: today),
                      const SizedBox(height: 20),
                      // Günlük içgörü
                      _InsightSection(
                        icon: Icons.wb_sunny,
                        iconColor: AppColors.gold,
                        title: AppStrings.insightTitle,
                        content: daily,
                        gradientColors: [
                          AppColors.gold.withOpacity(0.08),
                          AppColors.cardBackground,
                        ],
                        borderColor: AppColors.gold.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      // Haftalık tema
                      _InsightSection(
                        icon: Icons.calendar_view_week_outlined,
                        iconColor: AppColors.purpleLight,
                        title: AppStrings.insightWeeklyTheme,
                        content: weekly,
                        gradientColors: [
                          AppColors.purple.withOpacity(0.08),
                          AppColors.cardBackground,
                        ],
                        borderColor: AppColors.purple.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      // Olumlama
                      _AffirmationCard(text: affirmation),
                      const SizedBox(height: 16),
                      // Premium teaser
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
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
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
            color: AppColors.purple.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.format_quote,
              size: 28, color: Colors.white54),
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
            style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white60),
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
        borderColor: AppColors.gold.withOpacity(0.25),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline,
                    size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(
                  AppStrings.insightPremiumTeaser,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.gold),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Premium\'a Geç →',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
