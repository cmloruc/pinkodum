import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/gradient_card.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _purchaseService = PurchaseService();
  AuthUser? _user;
  int _credits = 0;
  bool _loading = true;
  bool _purchasing = false;
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthService(prefs);

      if (!kIsWeb) {
        await _purchaseService.init().timeout(const Duration(seconds: 10));
        _purchaseService.listenPurchases(_onPurchaseUpdate);
      }

      AuthUser? user = auth.currentUser;
      if (auth.isLoggedIn) {
        user =
            await auth.fetchMe().timeout(const Duration(seconds: 10)) ?? user;
      }

      if (mounted) {
        setState(() {
          _user = user;
          _credits = user?.credits ?? 0;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Premium init error: $e');
      if (mounted) {
        setState(() => _loading = false);
        _showError('Premium bilgileri yüklenemedi. Lütfen tekrar deneyin.');
      }
    }
  }

  Future<void> _onPurchaseUpdate(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      try {
        final totalCredits = await _purchaseService.verifyWithBackend(purchase);
        await _purchaseService.completePurchase(purchase);

        if (mounted) {
          setState(() {
            _credits = totalCredits;
            _purchasing = false;
            _purchasingId = null;
          });
          _showSuccess(totalCredits);
        }
      } catch (e) {
        debugPrint('Purchase verification error: $e');
        if (mounted) {
          setState(() {
            _purchasing = false;
            _purchasingId = null;
          });
          _showError(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    } else if (purchase.status == PurchaseStatus.error) {
      await _purchaseService.completePurchase(purchase);
      if (mounted) {
        setState(() {
          _purchasing = false;
          _purchasingId = null;
        });
        _showError(purchase.error?.message ?? 'Satın alma başarısız.');
      }
    } else if (purchase.status == PurchaseStatus.canceled) {
      if (mounted) {
        setState(() {
          _purchasing = false;
          _purchasingId = null;
        });
      }
    } else if (purchase.status == PurchaseStatus.pending) {
      if (mounted) {
        setState(() {
          _purchasing = true;
          _purchasingId = purchase.productID;
        });
      }
    }
  }

  Future<void> _buy(ProductDetails product) async {
    if (!_purchaseService.isAvailable) {
      _showError('App Store şu an kullanılamıyor.');
      return;
    }
    setState(() {
      _purchasing = true;
      _purchasingId = product.id;
    });
    final started = await _purchaseService.buy(product);
    if (!started && mounted) {
      setState(() {
        _purchasing = false;
        _purchasingId = null;
      });
      _showError('Satın alma başlatılamadı.');
    }
  }

  void _showSuccess(int? totalCredits) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 52, color: AppColors.success),
            const SizedBox(height: 16),
            Text('Satın Alma Başarılı!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            if (totalCredits != null)
              Text('Toplam krediniz: $totalCredits',
                  style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),
            GoldButton(
                label: 'Harika!', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
    ));
  }

  @override
  void dispose() {
    _purchaseService.dispose();
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
                      child: Text(AppStrings.premiumTitle,
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
                        child: CircularProgressIndicator(color: AppColors.gold))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _PremiumHeader(credits: _credits, user: _user),
                            const SizedBox(height: 28),
                            if (_user == null) ...[
                              _LoginGate(onLogin: () async {
                                await context.push(AppRoutes.login);
                                _init();
                              }),
                            ] else ...[
                              const _SectionTitle('Kredi Paketleri'),
                              const SizedBox(height: 12),
                              ..._buildProductCards(),
                              const SizedBox(height: 16),
                              _CreditsInfo(),
                            ],
                            const SizedBox(height: 24),
                            Text(AppStrings.legalDisclaimer,
                                style: AppTextStyles.disclaimer,
                                textAlign: TextAlign.center),
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

  List<Widget> _buildProductCards() {
    if (kIsWeb) {
      return [
        GradientCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Web sürümünde App Store satın alma kapalı. PDF ve analiz testleri için detaylı analiz ekranından web test moduyla devam edebilirsiniz.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    if (!_purchaseService.isAvailable) {
      return [
        GradientCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text('App Store şu an kullanılamıyor.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.warning)),
              ),
            ],
          ),
        ),
      ];
    }

    // App Store'dan ürünler yüklendiyse gerçek fiyat, yoksa sabit label
    return kCreditProducts.map((cp) {
      final storeProduct = _purchaseService.products
          .cast<ProductDetails?>()
          .firstWhere((p) => p?.id == cp.id, orElse: () => null);

      final price = storeProduct?.price ?? cp.priceLabel;
      final isBuying = _purchasing && _purchasingId == cp.id;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _CreditPackageCard(
          credits: cp.credits,
          title: cp.title,
          description: cp.description,
          price: price,
          isSubscription: cp.isSubscription,
          loading: isBuying,
          onTap: (_purchasing || storeProduct == null)
              ? null
              : () => _buy(storeProduct),
        ),
      );
    }).toList();
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  final int credits;
  final AuthUser? user;
  const _PremiumHeader({required this.credits, required this.user});

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
                  color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 24)
            ],
          ),
          child: const Icon(Icons.star, size: 36, color: AppColors.background),
        ),
        const SizedBox(height: 20),
        Text(AppStrings.premiumTitle, style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        Text('Detaylı analizlere kredi satın alarak erişin.',
            style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        if (user != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.toll_outlined,
                    size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('$credits kredi',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.gold)),
              ],
            ),
          ),
          if (user!.hasActivePremium) ...[
            const SizedBox(height: 10),
            Text(
              'Premium aktif • Tekil ${user!.monthlySingleRemaining}/10 • İlişki ${user!.monthlyRelationshipRemaining}/10',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}

// ─── Giriş Zorunluluğu ───────────────────────────────────────────────────────
class _LoginGate extends StatelessWidget {
  final VoidCallback onLogin;
  const _LoginGate({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 40, color: AppColors.gold),
          const SizedBox(height: 16),
          Text('Giriş Gerekli', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Kredi satın almak için hesabına giriş yapman gerekiyor.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GoldButton(label: 'Giriş Yap', icon: Icons.login, onPressed: onLogin),
        ],
      ),
    );
  }
}

// ─── Kredi Paketi Kartı ───────────────────────────────────────────────────────
class _CreditPackageCard extends StatelessWidget {
  final int credits;
  final String title;
  final String description;
  final String price;
  final bool isSubscription;
  final bool loading;
  final VoidCallback? onTap;

  const _CreditPackageCard({
    required this.credits,
    required this.title,
    required this.description,
    required this.price,
    required this.isSubscription,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: Center(
              child: isSubscription
                  ? const Icon(Icons.workspace_premium,
                      color: AppColors.background)
                  : Text('$credits',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.background)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.gold),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.gold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: onTap != null
                            ? AppColors.goldGradient
                            : const LinearGradient(colors: [
                                AppColors.textMuted,
                                AppColors.textMuted
                              ]),
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

// ─── Kredi Kullanım Bilgisi ───────────────────────────────────────────────────
class _CreditsInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kredi Kullanımı',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.textGold)),
          const SizedBox(height: 12),
          const _InfoRow(Icons.auto_awesome, 'Detaylı tekil analiz', '2 kredi'),
          const _InfoRow(Icons.favorite, 'Detaylı ilişki analizi', '3 kredi'),
          const _InfoRow(Icons.payments_outlined, '1 kredi', '49 TL'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
          Text(value,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGold)),
        ],
      ),
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
