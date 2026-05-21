import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/home_button.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/person_analysis.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/purchase_service.dart';

class PremiumPurchaseScreen extends StatefulWidget {
  final PersonAnalysis analysis;
  const PremiumPurchaseScreen({super.key, required this.analysis});

  @override
  State<PremiumPurchaseScreen> createState() => _PremiumPurchaseScreenState();
}

class _PremiumPurchaseScreenState extends State<PremiumPurchaseScreen> {
  int _credits = 0;
  AuthUser? _user;
  bool _loading = true;
  String? _creditLoadError;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService(prefs);
    if (auth.isLoggedIn) {
      // Krediyi backend'den çek — auth.me endpoint'inden
      try {
        final user = await auth.fetchMe();
        if (mounted) {
          setState(() {
            _credits = user?.credits ?? 0;
            _user = user;
          });
        }
      } catch (e) {
        debugPrint('Credit load error: $e');
        if (mounted) {
          setState(() {
            _creditLoadError =
                'Kredi bilgisi alınamadı. Bağlantını ve giriş durumunu kontrol et.';
          });
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onProceed() {
    if (_user?.isAdmin == true ||
        _user?.hasActivePremium == true ||
        _credits >= kCreditsPerPremiumAnalysis ||
        kIsWeb) {
      context.push(AppRoutes.premiumLoading, extra: widget.analysis);
    } else {
      context.push(AppRoutes.premium);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF130A1E), Color(0xFF0A0E1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
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
                      child: Text('Detaylı Analiz',
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center),
                    ),
                    const HomeButton(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Column(
                    children: [
                      // Kişi bilgisi
                      Text(
                        analysis.name,
                        style: AppTextStyles.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis.pinCodeFormatted,
                        style:
                            AppTextStyles.bodyMedium.copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: 32),

                      // Ne kazanacak
                      _WhatYouGet(),
                      const SizedBox(height: 28),

                      // Fiyat kartı
                      _PriceCard(
                        credits: _credits,
                        user: _user,
                        loading: _loading,
                        error: _creditLoadError,
                        onTap: _onProceed,
                      ),
                      const SizedBox(height: 16),

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
}

class _WhatYouGet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.person_outline,
        'Kişilik',
        '9 hanenin tamamı ayrı ayrı yorumlanır'
      ),
      (
        Icons.auto_awesome_mosaic_outlined,
        'Element Analizi',
        'Baskın ve zayıf elementlerin hayatına etkisi'
      ),
      (
        Icons.school_outlined,
        'Yaşam Dersin',
        'Bu yaşamdaki en derin öğrenme alanın'
      ),
      (
        Icons.wb_sunny_outlined,
        'Bu Yıl',
        'Bu yıl için özel enerji ve odak noktası'
      ),
      (
        Icons.psychology_outlined,
        'Gölge Taraflar',
        'Güçlü yönlerin yanı sıra zorlu kalıpların'
      ),
      (
        Icons.bookmark_outline,
        'Kaydedilir',
        'Analizini istediğin zaman tekrar okuyabilirsin'
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 15, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('Detaylı Analizinde Neler Var?',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textGold)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.$1, size: 16, color: AppColors.gold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2,
                              style: AppTextStyles.titleMedium
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(item.$3, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final int credits;
  final AuthUser? user;
  final bool loading;
  final String? error;
  final VoidCallback onTap;
  const _PriceCard({
    required this.credits,
    required this.user,
    required this.loading,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              AppStrings.premiumSingleDetail,
              style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.background, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.priceSingleDetail,
              style: AppTextStyles.displayMedium
                  .copyWith(color: AppColors.background),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.background.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Analizi Aç',
                style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.background, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            if (loading)
              const CircularProgressIndicator(
                  color: AppColors.background, strokeWidth: 2)
            else if (error != null)
              Text(
                error!,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background.withValues(alpha: 0.78)),
                textAlign: TextAlign.center,
              )
            else if (kIsWeb)
              Text(
                'Web test modu • kredi alınmadan analiz açılır',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background.withValues(alpha: 0.85)),
                textAlign: TextAlign.center,
              )
            else if (user?.hasActivePremium == true)
              Text(
                'Premium aktif • Tekil ${user!.monthlySingleRemaining}/10 hakkınız var',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background.withValues(alpha: 0.85)),
                textAlign: TextAlign.center,
              )
            else if (credits >= kCreditsPerPremiumAnalysis)
              Text(
                '$credits krediniz var • $kCreditsPerPremiumAnalysis kredi harcanacak',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background.withValues(alpha: 0.85)),
              )
            else
              Text(
                'Yetersiz kredi • Kredi satın al',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background.withValues(alpha: 0.7)),
              ),
          ],
        ),
      ),
    );
  }
}
