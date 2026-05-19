import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/gradient_card.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      child: Text(AppStrings.premiumTitle,
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
                      // Header
                      const _PremiumHeader(),
                      const SizedBox(height: 28),
                      // Tek seferlik
                      _SectionTitle('Tek Seferlik Analizler'),
                      const SizedBox(height: 12),
                      _PriceCard(
                        icon: Icons.person_search_outlined,
                        title: AppStrings.premiumSingleDetail,
                        description:
                            'Kişiliğin, güçlü yönlerin ve gelişim alanlarının tam analizi.',
                        price: AppStrings.priceSingleDetail,
                        credit: AppStrings.credit1,
                        onTap: () => _showMockPurchase(context),
                      ),
                      const SizedBox(height: 12),
                      _PriceCard(
                        icon: Icons.favorite_outlined,
                        title: AppStrings.premiumRelationshipDetail,
                        description:
                            'İki kişinin tam uyum raporu ve ilişki rehberi.',
                        price: AppStrings.priceRelationshipDetail,
                        credit: AppStrings.credit2,
                        onTap: () => _showMockPurchase(context),
                      ),
                      const SizedBox(height: 24),
                      // Abonelik
                      _SectionTitle('Abonelik Paketleri'),
                      const SizedBox(height: 12),
                      _PremiumPlanCard(
                        title: AppStrings.premiumMonthly,
                        price: AppStrings.priceMonthly,
                        features: const [
                          '10 analiz kredisi / ay',
                          'Günlük detaylı içgörü',
                          'Haftalık tema yorumu',
                          'PDF rapor',
                        ],
                        onTap: () => _showMockPurchase(context),
                      ),
                      const SizedBox(height: 12),
                      _PremiumPlanCard(
                        title: AppStrings.premiumYearly,
                        price: AppStrings.priceYearly,
                        badge: 'En Avantajlı',
                        features: const [
                          '50 analiz kredisi / yıl',
                          'Tüm aylık özellikler',
                          'Öncelikli destek',
                          'Gelecek özellikler ücretsiz',
                        ],
                        highlighted: true,
                        onTap: () => _showMockPurchase(context),
                      ),
                      const SizedBox(height: 24),
                      // Mock uyarısı
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.premiumMockNotice,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Hukuki uyarı
                      Text(
                        AppStrings.legalDisclaimer,
                        style: AppTextStyles.disclaimer,
                        textAlign: TextAlign.center,
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

  void _showMockPurchase(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.construction, size: 44, color: AppColors.gold),
            const SizedBox(height: 16),
            Text('Ödeme sistemi hazırlanıyor',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Gerçek ödeme sistemi yakında aktif olacak. Şu an tüm analizler ücretsiz olarak kullanılabilir.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GoldButton(
              label: 'Anladım',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.3),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(Icons.star, size: 36, color: AppColors.background),
        ),
        const SizedBox(height: 20),
        Text(AppStrings.premiumTitle,
            style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        Text(
          AppStrings.premiumSubtitle,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.titleMedium),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String price;
  final String credit;
  final VoidCallback onTap;

  const _PriceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    required this.credit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.1),
              border:
                  Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, size: 20, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(description, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(credit,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.purpleLight)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.gold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Satın Al',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final String? badge;
  final bool highlighted;
  final VoidCallback onTap;

  const _PremiumPlanCard({
    required this.title,
    required this.price,
    required this.features,
    this.badge,
    this.highlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: highlighted
              ? AppColors.goldGradient
              : null,
          color: highlighted ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: highlighted
              ? null
              : Border.all(color: AppColors.borderGold, width: 0.5),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.2),
                    blurRadius: 16,
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: highlighted
                          ? AppColors.background
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: highlighted
                          ? AppColors.background.withOpacity(0.2)
                          : AppColors.gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: highlighted
                            ? AppColors.background
                            : AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: AppTextStyles.displayMedium.copyWith(
                color: highlighted
                    ? AppColors.background
                    : AppColors.gold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: highlighted
                            ? AppColors.background.withOpacity(0.7)
                            : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: highlighted
                              ? AppColors.background.withOpacity(0.85)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: highlighted
                    ? AppColors.background.withOpacity(0.15)
                    : AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: highlighted
                      ? AppColors.background.withOpacity(0.3)
                      : AppColors.gold.withOpacity(0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Başla →',
                style: AppTextStyles.buttonTextSecondary.copyWith(
                  color: highlighted
                      ? AppColors.background
                      : AppColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
