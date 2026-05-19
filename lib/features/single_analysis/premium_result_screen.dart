import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/pin_code_tree.dart';
import '../../data/models/person_premium_analysis.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/element_balance_calculator.dart';

class PremiumResultScreen extends StatefulWidget {
  final PersonPremiumAnalysis analysis;
  const PremiumResultScreen({super.key, required this.analysis});

  @override
  State<PremiumResultScreen> createState() => _PremiumResultScreenState();
}

class _PremiumResultScreenState extends State<PremiumResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = await getRepository();
      await repo.savePremiumAnalysis(widget.analysis);
    });
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
              _PremiumAppBar(name: analysis.name),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Rozet ───────────────────────────────────────────
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 13, color: AppColors.background),
                              const SizedBox(width: 6),
                              Text(
                                'Detaylı Analiz Raporu',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Genel Özet ───────────────────────────────────────
                      _SummaryCard(analysis: analysis),
                      const SizedBox(height: 20),

                      // ── Pin Kodu Şablonu ─────────────────────────────────
                      _SectionTitle('Pin Kodun', Icons.grid_view_outlined),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.border, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            PinCodeTree(pinCode: analysis.pinCode),
                            const SizedBox(height: 8),
                            Text(
                              analysis.pinCode.join('-'),
                              style: AppTextStyles.pinDigitSmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  letterSpacing: 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 9 Hane Yorumu ────────────────────────────────────
                      _SectionTitle('9 Hane Yorumların', Icons.layers_outlined),
                      const SizedBox(height: 10),
                      _HaneCard(
                          hane: 'H1',
                          title: 'Kişilik',
                          text: analysis.h1Personality,
                          color: const Color(0xFFD4AF37)),
                      _HaneCard(
                          hane: 'H2',
                          title: 'Sosyal Bilinç',
                          text: analysis.h2Social,
                          color: const Color(0xFF60A5FA)),
                      _HaneCard(
                          hane: 'H3',
                          title: 'Küresel Bilinçlilik',
                          text: analysis.h3Global,
                          color: const Color(0xFFF97316)),
                      _HaneCard(
                          hane: 'H4',
                          title: 'Yaşam Döngüsü',
                          text: analysis.h4LifeCycle,
                          color: const Color(0xFF34D399)),
                      _HaneCard(
                          hane: 'H5',
                          title: 'Ders ve Potansiyel',
                          text: analysis.h5Lesson,
                          color: const Color(0xFFD4AF37)),
                      _HaneCard(
                          hane: 'H6',
                          title: 'İçsel Benlik',
                          text: analysis.h6InnerSelf,
                          color: const Color(0xFFF97316)),
                      _HaneCard(
                          hane: 'H7',
                          title: 'İçsel Çocuk',
                          text: analysis.h7InnerChild,
                          color: const Color(0xFFA78BFA),
                          special: true),
                      _HaneCard(
                          hane: 'H8',
                          title: 'Ruh Duygusu',
                          text: analysis.h8Soul,
                          color: const Color(0xFF34D399),
                          special: true),
                      _HaneCard(
                          hane: 'H9',
                          title: 'Evren',
                          text: analysis.h9Universe,
                          color: const Color(0xFFA78BFA),
                          special: true),
                      const SizedBox(height: 20),

                      // ── Element Dağılım Tablosu ──────────────────────────
                      _SectionTitle('Element Haritanın Anlamı',
                          Icons.auto_awesome_mosaic_outlined),
                      const SizedBox(height: 10),
                      _ElementTable(pinCode: analysis.pinCode),
                      const SizedBox(height: 10),
                      _DetailCard(
                        icon: Icons.air,
                        color: const Color(0xFF60A5FA),
                        text: analysis.elementDetail,
                      ),
                      const SizedBox(height: 16),

                      // ── Yaşam Dersi ──────────────────────────────────────
                      _SectionTitle('Yaşam Dersin', Icons.school_outlined),
                      const SizedBox(height: 10),
                      _DetailCard(
                        icon: Icons.lightbulb_outline,
                        color: AppColors.gold,
                        text: analysis.lifeLesson,
                      ),
                      const SizedBox(height: 16),

                      // ── Bu Yıl ───────────────────────────────────────────
                      _SectionTitle('${DateTime.now().year} Yılı Enerjin',
                          Icons.calendar_today_outlined),
                      const SizedBox(height: 10),
                      _DetailCard(
                        icon: Icons.wb_sunny_outlined,
                        color: AppColors.purpleLight,
                        text: analysis.yearMessage,
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh,
                              size: 16, color: AppColors.textMuted),
                          label: Text('Yeni Analiz',
                              style: AppTextStyles.bodyMedium),
                          onPressed: () => context.go('/'),
                        ),
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
class _PremiumAppBar extends StatelessWidget {
  final String name;
  const _PremiumAppBar({required this.name});

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
            child: Text(name,
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
          ),
          const HomeButton(),
        ],
      ),
    );
  }
}

// ─── Genel özet kartı ────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final PersonPremiumAnalysis analysis;
  const _SummaryCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1040), Color(0xFF0A0E1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('Genel Özet',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 14),
          Text(analysis.overallSummary, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

// ─── Bölüm başlığı ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionTitle(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(text,
            style:
                AppTextStyles.titleMedium.copyWith(color: AppColors.textGold)),
      ],
    );
  }
}

// ─── Hane kartı ──────────────────────────────────────────────────────────────
class _HaneCard extends StatelessWidget {
  final String hane;
  final String title;
  final String text;
  final Color color;
  final bool special;

  const _HaneCard({
    required this.hane,
    required this.title,
    required this.text,
    required this.color,
    this.special = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: special ? color.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: special ? 0.4 : 0.2)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(hane,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: AppTextStyles.labelMedium.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Text(text, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}

// ─── Detay kartı ─────────────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _DetailCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyLarge),
          ),
        ],
      ),
    );
  }
}

// ─── Element dağılım tablosu ──────────────────────────────────────────────────
class _ElementTable extends StatelessWidget {
  final List<int> pinCode;
  const _ElementTable({required this.pinCode});

  static const _elementColors = {
    'Hava': Color(0xFF60A5FA),
    'Su': Color(0xFF38BDF8),
    'Ateş': Color(0xFFF97316),
    'Toprak': Color(0xFF84CC16),
    'Denge': Color(0xFFD4AF37),
  };

  static const _elementIcons = {
    'Hava': Icons.air,
    'Su': Icons.water_drop_outlined,
    'Ateş': Icons.local_fire_department_outlined,
    'Toprak': Icons.landscape_outlined,
    'Denge': Icons.balance,
  };

  @override
  Widget build(BuildContext context) {
    final e = const ElementBalanceCalculator().calculate(pinCode);
    final total = e.air + e.water + e.fire + e.earth + e.balanceNine;
    final elements = [
      ('Hava', e.air),
      ('Su', e.water),
      ('Ateş', e.fire),
      ('Toprak', e.earth),
      if (e.balanceNine > 0) ('Denge', e.balanceNine),
    ];
    // Her hanenin hangi elemente karşılık geldiği
    final haneNames = [
      'Kişilik',
      'Sosyal',
      'Küresel',
      'Yaşam',
      'Ders',
      'İçsel Ben',
      'İçsel Çoc.',
      'Ruh',
      'Evren'
    ];
    final digitToElement = (int d) {
      if (d == 1 || d == 5) return 'Hava';
      if (d == 2 || d == 7) return 'Su';
      if (d == 3 || d == 6) return 'Ateş';
      if (d == 4 || d == 8) return 'Toprak';
      return 'Denge';
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Haneden elemente dönüşüm tablosu ──
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(0.6),
              2: FlexColumnWidth(1.4),
            },
            children: [
              // Başlık satırı
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Hane',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Rakam',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Element',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center),
                ),
              ]),
              // Her hane için satır
              ...List.generate(9, (i) {
                final digit = pinCode[i];
                final elName = digitToElement(digit);
                final color = _elementColors[elName] ?? AppColors.gold;
                final icon = _elementIcons[elName] ?? Icons.circle;
                return TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text('H${i + 1} ${haneNames[i]}',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text('$digit',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: color, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 11, color: color),
                        const SizedBox(width: 4),
                        Text(elName,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: color, fontSize: 10)),
                      ],
                    ),
                  ),
                ]);
              }),
            ],
          ),
          const Divider(color: AppColors.border, height: 20),
          // ── Element toplamları progress barları ──
          ...elements.map((el) {
            final color = _elementColors[el.$1] ?? AppColors.gold;
            final icon = _elementIcons[el.$1] ?? Icons.circle;
            final frac = total == 0 ? 0.0 : el.$2 / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                SizedBox(
                    width: 52,
                    child: Text(el.$1,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11))),
                Expanded(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: frac,
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color)),
                )),
                const SizedBox(width: 8),
                Text('${el.$2}',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ]),
            );
          }),
          const Divider(color: AppColors.border, height: 20),
          Row(children: [
            Expanded(
                child: _SChip(
                    label: 'Baskın',
                    value: e.dominantScore,
                    color: AppColors.gold)),
            const SizedBox(width: 8),
            Expanded(
                child: _SChip(
                    label: 'Edilgen',
                    value: e.passiveScore,
                    color: AppColors.purpleLight)),
            const SizedBox(width: 8),
            Expanded(child: _EChip(type: e.energyType)),
          ]),
        ],
      ),
    );
  }
}

class _SChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(fontSize: 9, color: AppColors.textMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value % 1 == 0 ? value.toInt().toString() : value.toString(),
              style: AppTextStyles.titleMedium.copyWith(color: color)),
        ]),
      );
}

class _EChip extends StatelessWidget {
  final String type;
  const _EChip({required this.type});
  @override
  Widget build(BuildContext context) {
    final color = type == ElementBalanceCalculator.energyDominant
        ? AppColors.gold
        : type == ElementBalanceCalculator.energyPassive
            ? AppColors.purpleLight
            : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Text('Enerji',
            style: AppTextStyles.bodySmall
                .copyWith(fontSize: 9, color: AppColors.textMuted),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(type,
            style: AppTextStyles.bodySmall
                .copyWith(color: color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
