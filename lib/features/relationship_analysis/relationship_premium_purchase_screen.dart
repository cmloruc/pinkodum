import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/home_button.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/relationship_analysis.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/purchase_service.dart';

class RelationshipPremiumPurchaseScreen extends StatefulWidget {
  final RelationshipAnalysis analysis;
  const RelationshipPremiumPurchaseScreen({super.key, required this.analysis});

  @override
  State<RelationshipPremiumPurchaseScreen> createState() =>
      _RelationshipPremiumPurchaseScreenState();
}

class _RelationshipPremiumPurchaseScreenState
    extends State<RelationshipPremiumPurchaseScreen> {
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
        _credits >= kCreditsPerRelationshipPremium ||
        kIsWeb) {
      context.push(AppRoutes.relPremiumLoading, extra: widget.analysis);
    } else {
      context.push(AppRoutes.premium);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
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
                      child: Text('Detaylı İlişki Analizi',
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
                      Text(
                        '${a.firstName}  ✦  ${a.secondName}',
                        style: AppTextStyles.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _WhatYouGet(),
                      const SizedBox(height: 28),
                      _PriceCard(
                        credits: _credits,
                        user: _user,
                        loading: _loading,
                        error: _creditLoadError,
                        onTap: _onProceed,
                      ),
                      const SizedBox(height: 16),
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
    final items = [
      (
        Icons.favorite_outline,
        'İlişki Enerjisi',
        'Ortak pin kodunuzun tam yorumu'
      ),
      (
        Icons.auto_awesome_mosaic_outlined,
        'Element Uyumu',
        'İki enerjinin element dengesi ve etkisi'
      ),
      (
        Icons.handshake_outlined,
        'Uyum Alanları',
        'Birlikte güçlü olduğunuz konular'
      ),
      (
        Icons.bolt_outlined,
        'Zorluk Alanları',
        'Büyüme fırsatı sunan dinamikler'
      ),
      (
        Icons.wb_sunny_outlined,
        'Bu Yıl Enerjisi',
        'Bu yıl ilişkinizin odak noktası'
      ),
      (
        Icons.bookmark_outline,
        'Kaydedilir',
        'Analizinizi istediğiniz zaman tekrar okuyun'
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, size: 15, color: AppColors.purpleLight),
              const SizedBox(width: 8),
              Text('Detaylı Analizde Neler Var?',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.purpleLight)),
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
                        color: AppColors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(item.$1, size: 16, color: AppColors.purpleLight),
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
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              'Detaylı İlişki Analizi',
              style: AppTextStyles.titleLarge
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${kCreditsPerRelationshipPremium} Kredi',
              style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Analizi Aç',
                style: AppTextStyles.titleLarge
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            if (loading)
              const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)
            else if (error != null)
              Text(
                error!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.78)),
                textAlign: TextAlign.center,
              )
            else if (kIsWeb)
              Text(
                'Web test modu • kredi alınmadan analiz açılır',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                textAlign: TextAlign.center,
              )
            else if (user?.hasActivePremium == true)
              Text(
                'Premium aktif • İlişki ${user!.monthlyRelationshipRemaining}/5 hakkınız var',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                textAlign: TextAlign.center,
              )
            else if (credits >= kCreditsPerRelationshipPremium)
              Text(
                '$credits krediniz var • $kCreditsPerRelationshipPremium kredi harcanacak',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.85)),
              )
            else
              Text(
                'Yetersiz kredi • Kredi satın al',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
          ],
        ),
      ),
    );
  }
}
