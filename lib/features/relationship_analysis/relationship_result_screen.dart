import 'package:flutter/material.dart';
import '../../core/widgets/home_button.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/pin_code_display.dart';
import '../../core/widgets/pin_code_tree.dart';
import '../../data/models/element_balance.dart';
import '../../data/models/relationship_analysis.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/pdf_service.dart';
import '../../data/services/element_balance_calculator.dart';

class RelationshipResultScreen extends StatefulWidget {
  final RelationshipAnalysis analysis;
  const RelationshipResultScreen({super.key, required this.analysis});

  @override
  State<RelationshipResultScreen> createState() =>
      _RelationshipResultScreenState();
}

class _RelationshipResultScreenState extends State<RelationshipResultScreen> {
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = await getRepository();
      await repo.saveRelationshipAnalysis(widget.analysis);
    });
  }

  Future<void> _sharePdf() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final file = await PdfService.generateRelationshipAnalysis(widget.analysis);
      await PdfService.share(file,
          subject: 'Pin Kodum — ${widget.analysis.firstName} & ${widget.analysis.secondName}');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _RelAppBar(title: a.title, onShare: _sharePdf, sharing: _sharing),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── İlişki türü etiketi ──────────────────────────────
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.purple.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite,
                                  size: 12, color: AppColors.purpleLight),
                              const SizedBox(width: 6),
                              Text(a.relationshipType,
                                  style: AppTextStyles.labelMedium
                                      .copyWith(color: AppColors.purpleLight)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Kişisel pin kodları — kompakt referans ────────────
                      _PersonalPinsRow(analysis: a),
                      const SizedBox(height: 16),

                      // ── Ortak pin kodu — ana vurgu ────────────────────────
                      _CombinedPinSection(analysis: a),
                      const SizedBox(height: 16),

                      // ── Ortak element haritası — kilitli yorum ────────────
                      _CombinedElementTeaser(
                          elementBalance: a.combinedElementBalance),
                      const SizedBox(height: 12),

                      // ── Cinsel uyum — koşullu gösterim ───────────────────
                      if ((a.sexualCompatibility ?? '').trim().isNotEmpty) ...[
                        _SexualCompatibilityCard(analysis: a),
                        const SizedBox(height: 8),
                      ],

                      // ── İlişki yorumları — kısa teaser ───────────────────
                      _RelInsightTeaser(
                        icon: Icons.favorite_outline,
                        iconColor: AppColors.purple,
                        title: AppStrings.resultRelationshipEnergy,
                        content: a.summary,
                      ),
                      const SizedBox(height: 8),
                      _RelInsightTeaser(
                        icon: Icons.handshake_outlined,
                        iconColor: AppColors.success,
                        title: AppStrings.resultHarmony,
                        content: a.harmonyPoint,
                      ),
                      const SizedBox(height: 8),
                      _RelInsightTeaser(
                        icon: Icons.bolt_outlined,
                        iconColor: AppColors.warning,
                        title: AppStrings.resultChallenge,
                        content: a.challengePoint,
                      ),
                      const SizedBox(height: 16),

                      // ── Premium çekim kartı ───────────────────────────────
                      _RelPremiumHook(
                          onTap: () => context.push(AppRoutes.relPremiumLoading,
                              extra: a)),
                      const SizedBox(height: 20),

                      const SizedBox(height: 8),
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

// ─── App bar ─────────────────────────────────────────────────────────────────
class _RelAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onShare;
  final bool sharing;
  const _RelAppBar({required this.title, required this.onShare, required this.sharing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(title,
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
          ),
          sharing
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))
              : IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20, color: AppColors.gold),
                  onPressed: onShare, tooltip: 'PDF Rapor'),
          const HomeButton(),
        ],
      ),
    );
  }
}

// ─── İki kişinin kompakt pin bilgisi yan yana ─────────────────────────────────
class _PersonalPinsRow extends StatelessWidget {
  final RelationshipAnalysis analysis;
  const _PersonalPinsRow({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactPersonPin(
            name: analysis.firstName,
            date: analysis.firstBirthDate,
            pin: analysis.firstPinCode,
            elementBalance: analysis.firstElementBalance,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CompactPersonPin(
            name: analysis.secondName,
            date: analysis.secondBirthDate,
            pin: analysis.secondPinCode,
            elementBalance: analysis.secondElementBalance,
          ),
        ),
      ],
    );
  }
}

class _CompactPersonPin extends StatelessWidget {
  final String name;
  final DateTime date;
  final List<int> pin;
  final ElementBalance elementBalance;

  const _CompactPersonPin({
    required this.name,
    required this.date,
    required this.pin,
    required this.elementBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: AppTextStyles.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(DateFormatter.format(date), style: AppTextStyles.bodySmall),
          const SizedBox(height: 10),
          PinCodeDisplay(pinCode: pin, large: false),
          const SizedBox(height: 8),
          // Baskın element rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _elementColor(elementBalance.dominantElement)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: _elementColor(elementBalance.dominantElement)
                      .withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _elementIcon(elementBalance.dominantElement),
                  size: 10,
                  color: _elementColor(elementBalance.dominantElement),
                ),
                const SizedBox(width: 4),
                Text(
                  elementBalance.dominantElement,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _elementColor(elementBalance.dominantElement),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
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

// ─── Ortak pin kodu ana bölümü ────────────────────────────────────────────────
class _CombinedPinSection extends StatelessWidget {
  final RelationshipAnalysis analysis;
  const _CombinedPinSection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.08),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'Ortak Pin Kodunuz',
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${analysis.firstName}  ✦  ${analysis.secondName}',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          // Tam ağaç şablonu — kombine pin
          PinCodeTree(pinCode: analysis.combinedPinCode),
          const SizedBox(height: 10),
          Text(
            analysis.combinedPinFormatted,
            style: AppTextStyles.pinDigitSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 3,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ortak element haritası — kilitli yorum ───────────────────────────────────
class _CombinedElementTeaser extends StatelessWidget {
  final ElementBalance elementBalance;
  const _CombinedElementTeaser({required this.elementBalance});

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
              const Icon(Icons.auto_awesome_mosaic_outlined,
                  size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text('Ortak Element Haritanız',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.gold)),
              const Spacer(),
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
          const SizedBox(height: 4),
          Text(
            'Ortak pin kodunuzdan hesaplandı',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 10),
          // Enerji tipi
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _energyColor(e.energyType).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _energyColor(e.energyType).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_energyIcon(e.energyType),
                        size: 12, color: _energyColor(e.energyType)),
                    const SizedBox(width: 5),
                    Text(
                      'Ortak Enerji: ${e.energyType}',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: _energyColor(e.energyType),
                          fontWeight: FontWeight.w600,
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Kilitli yorum
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
                const Icon(Icons.lock_outline, size: 14, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ortak element yorumunuz detaylı analizde sizi bekliyor',
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

// ─── Cinsel uyum kartı ───────────────────────────────────────────────────────
class _SexualCompatibilityCard extends StatelessWidget {
  final RelationshipAnalysis analysis;
  const _SexualCompatibilityCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final e = analysis.combinedElementBalance;
    final isHighFire = e.fire >= 3;
    final accentColor = isHighFire
        ? const Color(0xFFF97316) // turuncu-kırmızı — ateş
        : AppColors.purpleLight;

    final text = analysis.sexualCompatibility?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        // Ateş yüksekse hafif glow
        boxShadow: isHighFire
            ? [
                BoxShadow(
                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_outlined,
                  size: 14, color: accentColor),
              const SizedBox(width: 6),
              Text(
                'Fiziksel & Cinsel Uyum',
                style: AppTextStyles.labelMedium.copyWith(color: accentColor),
              ),
              if (isHighFire) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFFF97316).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 10, color: Color(0xFFF97316)),
                      const SizedBox(width: 3),
                      Text(
                        'Güçlü Ateş Enerjisi',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFFF97316),
                            fontWeight: FontWeight.w600,
                            fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

// ─── İlişki teaser kartı ─────────────────────────────────────────────────────
class _RelInsightTeaser extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _RelInsightTeaser({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.labelMedium.copyWith(color: iconColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

// ─── Premium çekim kartı ─────────────────────────────────────────────────────
class _RelPremiumHook extends StatelessWidget {
  final VoidCallback onTap;
  const _RelPremiumHook({required this.onTap});

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
                const Icon(Icons.auto_awesome,
                    size: 18, color: AppColors.background),
                const SizedBox(width: 8),
                Text(
                  'Detaylı İlişki Analizini Aç',
                  style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.background, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.background),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              'Ortak element yorumu (tam metin)',
              'Her hanenin ilişkiye etkisi',
              'Uyum ve zorluk alanları detayı',
              'İki kişinin enerji uyum raporu',
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
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

// ─── Yardımcı fonksiyonlar ────────────────────────────────────────────────────
Color _elementColor(String element) {
  switch (element) {
    case ElementBalanceCalculator.elementAir:
      return const Color(0xFF60A5FA);
    case ElementBalanceCalculator.elementWater:
      return const Color(0xFF38BDF8);
    case ElementBalanceCalculator.elementFire:
      return const Color(0xFFF97316);
    case ElementBalanceCalculator.elementEarth:
      return const Color(0xFF84CC16);
    default:
      return AppColors.gold;
  }
}

IconData _elementIcon(String element) {
  switch (element) {
    case ElementBalanceCalculator.elementAir:
      return Icons.air;
    case ElementBalanceCalculator.elementWater:
      return Icons.water_drop_outlined;
    case ElementBalanceCalculator.elementFire:
      return Icons.local_fire_department_outlined;
    case ElementBalanceCalculator.elementEarth:
      return Icons.landscape_outlined;
    default:
      return Icons.balance;
  }
}

Color _energyColor(String type) {
  switch (type) {
    case ElementBalanceCalculator.energyDominant:
      return AppColors.gold;
    case ElementBalanceCalculator.energyPassive:
      return AppColors.purpleLight;
    default:
      return AppColors.success;
  }
}

IconData _energyIcon(String type) {
  switch (type) {
    case ElementBalanceCalculator.energyDominant:
      return Icons.bolt;
    case ElementBalanceCalculator.energyPassive:
      return Icons.waves;
    default:
      return Icons.balance;
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
