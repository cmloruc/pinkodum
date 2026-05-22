import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/pin_code_tree.dart';
import '../../data/models/element_balance.dart';
import '../../data/models/person_analysis.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/pdf_service.dart';
import '../../data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleAnalysisResultScreen extends StatefulWidget {
  final PersonAnalysis analysis;
  final bool saveOnOpen;

  const SingleAnalysisResultScreen({
    super.key,
    required this.analysis,
    this.saveOnOpen = true,
  });

  @override
  State<SingleAnalysisResultScreen> createState() =>
      _SingleAnalysisResultScreenState();
}

class _SingleAnalysisResultScreenState
    extends State<SingleAnalysisResultScreen> {
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    if (!widget.saveOnOpen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = await getRepository();
      await repo.savePersonAnalysis(widget.analysis);
    });
  }

  Future<void> _sharePdf() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final file = await PdfService.generatePersonAnalysis(widget.analysis);
      await PdfService.share(file,
          subject: 'Pin Kodum — ${widget.analysis.name}');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _ResultAppBar(
                  name: a.name, onShare: _sharePdf, sharing: _sharing),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    children: [
                      // Pin kodu şablonu
                      _PinCard(analysis: a),
                      const SizedBox(height: 12),
                      // Element haritası — sadece sayılar, yorum kilitli
                      _ElementTeaser(elementBalance: a.elementBalance),
                      const SizedBox(height: 12),
                      // Kişilik — teaser
                      _InsightCard(
                        icon: Icons.auto_awesome,
                        title: AppStrings.resultPersonality,
                        content: a.summary,
                        iconColor: AppColors.gold,
                      ),
                      const SizedBox(height: 8),
                      // Güçlü yön — teaser
                      _InsightCard(
                        icon: Icons.bolt,
                        title: AppStrings.resultStrength,
                        content: a.strength,
                        iconColor: AppColors.success,
                        borderColor: AppColors.success.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      // Dikkat — teaser
                      _InsightCard(
                        icon: Icons.visibility_outlined,
                        title: AppStrings.resultWarning,
                        content: a.warning,
                        iconColor: AppColors.purpleLight,
                        borderColor: AppColors.purple.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      // Premium çekim kartı
                      _PremiumHook(onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final user = AuthService(prefs).currentUser;
                        if (!context.mounted) return;
                        if (user?.isAdmin == true ||
                            user?.hasActivePremium == true) {
                          context.push(AppRoutes.premiumLoading, extra: a);
                        } else {
                          context.push(AppRoutes.premiumPurchase, extra: a);
                        }
                      }),
                      const SizedBox(height: 20),
                      GhostButton(
                        label: AppStrings.btnNewAnalysis,
                        icon: Icons.refresh,
                        onPressed: () => context.pop(),
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

class _ResultAppBar extends StatelessWidget {
  final String name;
  final VoidCallback onShare;
  final bool sharing;
  const _ResultAppBar(
      {required this.name, required this.onShare, required this.sharing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          sharing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.gold))
              : IconButton(
                  icon: Icon(Icons.picture_as_pdf_outlined,
                      size: 20, color: AppColors.gold),
                  onPressed: onShare,
                  tooltip: 'PDF Rapor',
                ),
          const HomeButton(),
        ],
      ),
    );
  }
}

class _PinCard extends StatelessWidget {
  final PersonAnalysis analysis;
  const _PinCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.06),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          Text(analysis.name, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 3),
          Text(
            DateFormatter.format(analysis.birthDate),
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(AppStrings.resultPinCode, style: AppTextStyles.labelMedium),
          const SizedBox(height: 16),
          // Hiyerarşik ağaç şablonu
          PinCodeTree(pinCode: analysis.pinCode),
          const SizedBox(height: 12),
          Text(
            analysis.pinCodeFormatted,
            style: AppTextStyles.pinDigitSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 3,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;
  final Color? borderColor;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      borderColor: borderColor ?? AppColors.border,
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
          const SizedBox(height: 12),
          Text(content, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

// ─── Element teaser: sadece sayılar + kilitli yorum ──────────────────────────
class _ElementTeaser extends StatelessWidget {
  final ElementBalance elementBalance;

  const _ElementTeaser({required this.elementBalance});

  @override
  Widget build(BuildContext context) {
    final e = elementBalance;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_mosaic_outlined,
                  size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text('Element Haritan',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.gold)),
              const Spacer(),
              // Baskın element rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Baskın: ${e.dominantElement}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dört element sayıları — sade rozet sırası
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _ElemBadge('Hava', e.air, const Color(0xFF60A5FA)),
              _ElemBadge('Su', e.water, const Color(0xFF38BDF8)),
              _ElemBadge('Ateş', e.fire, const Color(0xFFF97316)),
              _ElemBadge('Toprak', e.earth, const Color(0xFF84CC16)),
              if (e.balanceNine > 0)
                _ElemBadge('Denge', e.balanceNine, AppColors.gold),
            ],
          ),
          const SizedBox(height: 12),
          // Kilitli yorum alanı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.borderGold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 14, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Element yorumun detaylı analizde seni bekliyor',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
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

class _ElemBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _ElemBadge(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label  $count',
        style: AppTextStyles.bodySmall
            .copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

// ─── Premium çekim kartı ─────────────────────────────────────────────────────
class _PremiumHook extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumHook({required this.onTap});

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
              color: AppColors.gold.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: AppColors.background),
                const SizedBox(width: 8),
                Text(
                  'Detaylı Analizi Aç',
                  style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.background, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.background),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              'Tam kişilik analizi (5 bölüm)',
              'Tüm hane yorumları',
              'Element haritası yorumu',
              'Güçlü yön ve gelişim alanı detayı',
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 13, color: AppColors.background),
                      const SizedBox(width: 6),
                      Text(
                        item,
                        style: AppTextStyles.bodySmall.copyWith(
                            color:
                                AppColors.background.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
