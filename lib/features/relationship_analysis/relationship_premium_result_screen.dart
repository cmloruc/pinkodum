import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/pin_code_tree.dart';
import '../../data/models/relationship_premium_analysis.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/element_balance_calculator.dart';

class RelationshipPremiumResultScreen extends StatefulWidget {
  final RelationshipPremiumAnalysis analysis;
  const RelationshipPremiumResultScreen({super.key, required this.analysis});

  @override
  State<RelationshipPremiumResultScreen> createState() =>
      _RelationshipPremiumResultScreenState();
}

class _RelationshipPremiumResultScreenState
    extends State<RelationshipPremiumResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = await getRepository();
      await repo.saveRelationshipPremiumAnalysis(widget.analysis);
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final showSexual = a.sexualCompatibility.isNotEmpty;

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
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(a.title,
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center),
                    ),
                    const HomeButton(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rozet
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.purpleGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.favorite,
                                size: 13, color: Colors.white),
                            const SizedBox(width: 6),
                            Text('Detaylı İlişki Analizi',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(a.relationshipType,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.purpleLight)),
                      ),
                      const SizedBox(height: 16),

                      // Genel özet
                      _SummaryCard(text: a.overallSummary),
                      const SizedBox(height: 20),

                      // Ortak pin ağacı
                      _SectionTitle(
                          'Ortak Pin Kodunuz', Icons.grid_view_outlined),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.border, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          PinCodeTree(pinCode: a.combinedPinCode),
                          const SizedBox(height: 8),
                          Text(a.combinedPinFormatted,
                              style: AppTextStyles.pinDigitSmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  letterSpacing: 3)),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      // 9 Hane Yorumu
                      _SectionTitle(
                          'Ortak Pin Kodu Yorumu', Icons.layers_outlined),
                      const SizedBox(height: 10),
                      _HaneCard(
                          hane: 'H1',
                          title: 'İlişkinin Kişiliği',
                          text: a.h1Combined,
                          color: const Color(0xFFD4AF37)),
                      _HaneCard(
                          hane: 'H2',
                          title: 'Sosyal Bilinç',
                          text: a.h2Combined,
                          color: const Color(0xFF60A5FA)),
                      _HaneCard(
                          hane: 'H3',
                          title: 'Küresel Bilinçlilik',
                          text: a.h3Combined,
                          color: const Color(0xFFF97316)),
                      _HaneCard(
                          hane: 'H4',
                          title: 'Yaşam Döngüsü',
                          text: a.h4Combined,
                          color: const Color(0xFF34D399)),
                      _HaneCard(
                          hane: 'H5',
                          title: 'Ders ve Potansiyel',
                          text: a.h5Combined,
                          color: const Color(0xFFD4AF37)),
                      _HaneCard(
                          hane: 'H6',
                          title: 'İçsel Dinamik',
                          text: a.h6Combined,
                          color: const Color(0xFFF97316)),
                      _HaneCard(
                          hane: 'H7',
                          title: 'İçsel Çocuk',
                          text: a.h7Combined,
                          color: const Color(0xFFA78BFA),
                          special: true),
                      _HaneCard(
                          hane: 'H8',
                          title: 'Ruh Duygusu',
                          text: a.h8Combined,
                          color: const Color(0xFF34D399),
                          special: true),
                      _HaneCard(
                          hane: 'H9',
                          title: 'Evren',
                          text: a.h9Combined,
                          color: const Color(0xFFA78BFA),
                          special: true),
                      const SizedBox(height: 20),

                      // Element tablosu
                      _SectionTitle('Element Uyumunuz',
                          Icons.auto_awesome_mosaic_outlined),
                      const SizedBox(height: 10),
                      _ElementTable(a: a),
                      const SizedBox(height: 10),
                      _DetailCard(
                          icon: Icons.air,
                          color: const Color(0xFF60A5FA),
                          text: a.elementCompatibility),
                      const SizedBox(height: 16),

                      // İletişim
                      _SectionTitle(
                          'İletişim Tarzınız', Icons.chat_bubble_outline),
                      const SizedBox(height: 10),
                      _DetailCard(
                          icon: Icons.chat_bubble_outline,
                          color: const Color(0xFF60A5FA),
                          text: a.communicationStyle),
                      const SizedBox(height: 12),

                      // Çatışma
                      _SectionTitle('Çatışma Kalıpları', Icons.bolt_outlined),
                      const SizedBox(height: 10),
                      _DetailCard(
                          icon: Icons.bolt_outlined,
                          color: AppColors.warning,
                          text: a.conflictPatterns),
                      const SizedBox(height: 12),

                      // Büyüme
                      _SectionTitle('Büyüme Fırsatları', Icons.trending_up),
                      const SizedBox(height: 10),
                      _DetailCard(
                          icon: Icons.trending_up,
                          color: AppColors.success,
                          text: a.growthOpportunity),
                      const SizedBox(height: 12),

                      // Fiziksel uyum
                      if (showSexual) ...[
                        _SectionTitle('Fiziksel Uyum',
                            Icons.local_fire_department_outlined),
                        const SizedBox(height: 10),
                        _DetailCard(
                            icon: Icons.local_fire_department_outlined,
                            color: const Color(0xFFF97316),
                            text: a.sexualCompatibility),
                        const SizedBox(height: 12),
                      ],

                      // Yıl
                      _SectionTitle('${DateTime.now().year} Yılı',
                          Icons.wb_sunny_outlined),
                      const SizedBox(height: 10),
                      _DetailCard(
                          icon: Icons.wb_sunny_outlined,
                          color: AppColors.gold,
                          text: a.yearMessage),
                      const SizedBox(height: 12),

                      // Ders
                      _SectionTitle('İlişkinizin Dersi', Icons.school_outlined),
                      const SizedBox(height: 10),
                      _DetailCard(
                          icon: Icons.school_outlined,
                          color: AppColors.purpleLight,
                          text: a.lifeLesson),
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

// ─── Element tablosu ──────────────────────────────────────────────────────────
class _ElementTable extends StatelessWidget {
  final RelationshipPremiumAnalysis a;
  const _ElementTable({required this.a});

  static const _colors = {
    'Hava': Color(0xFF60A5FA),
    'Su': Color(0xFF38BDF8),
    'Ateş': Color(0xFFF97316),
    'Toprak': Color(0xFF84CC16),
    'Denge': Color(0xFFD4AF37),
  };
  static const _icons = {
    'Hava': Icons.air,
    'Su': Icons.water_drop_outlined,
    'Ateş': Icons.local_fire_department_outlined,
    'Toprak': Icons.landscape_outlined,
    'Denge': Icons.balance,
  };

  @override
  Widget build(BuildContext context) {
    final calc = const ElementBalanceCalculator();
    final e1 = calc.calculate(a.firstPinCode);
    final e2 = calc.calculate(a.secondPinCode);
    final ec = calc.calculate(a.combinedPinCode);

    Color c(String el) => _colors[el] ?? AppColors.gold;
    IconData ico(String el) => _icons[el] ?? Icons.circle;

    // Haneden element tablosu (combined için)
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
    String digitToEl(int d) {
      if (d == 1 || d == 5) return 'Hava';
      if (d == 2 || d == 7) return 'Su';
      if (d == 3 || d == 6) return 'Ateş';
      if (d == 4 || d == 8) return 'Toprak';
      return 'Denge';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // İki kişi yan yana
        Row(children: [
          Expanded(
              child: _PersonElemBox(
                  name: a.firstName,
                  elem: e1,
                  color: c(e1.dominantElement),
                  icon: ico(e1.dominantElement))),
          const SizedBox(width: 10),
          Expanded(
              child: _PersonElemBox(
                  name: a.secondName,
                  elem: e2,
                  color: c(e2.dominantElement),
                  icon: ico(e2.dominantElement))),
        ]),
        const Divider(color: AppColors.border, height: 20),
        // Ortak pin haneden element tablosu
        Row(children: [
          const Icon(Icons.auto_awesome, size: 13, color: AppColors.gold),
          const SizedBox(width: 6),
          Text('Ortak Pin Kodunun Element Dağılımı',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold)),
        ]),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(0.6),
            2: FlexColumnWidth(1.4),
          },
          children: [
            TableRow(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Hane',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center)),
              Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Rakam',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center)),
              Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Element',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center)),
            ]),
            ...List.generate(9, (i) {
              final digit = a.combinedPinCode[i];
              final elName = digitToEl(digit);
              final color = c(elName);
              final icon = ico(elName);
              return TableRow(children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('H${i + 1} ${haneNames[i]}',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        textAlign: TextAlign.center)),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('$digit',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: color, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 11, color: color),
                          const SizedBox(width: 3),
                          Text(elName,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: color, fontSize: 10)),
                        ])),
              ]);
            }),
          ],
        ),
        const Divider(color: AppColors.border, height: 20),
        // Ortak element barları
        ...[
          ('Hava', ec.air),
          ('Su', ec.water),
          ('Ateş', ec.fire),
          ('Toprak', ec.earth),
          if (ec.balanceNine > 0) ('Denge', ec.balanceNine)
        ].map((el) {
          final color = c(el.$1);
          final icon = ico(el.$1);
          final total = ec.air + ec.water + ec.fire + ec.earth + ec.balanceNine;
          final frac = total == 0 ? 0.0 : el.$2 / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(icon, size: 13, color: color),
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
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color)),
              )),
              const SizedBox(width: 8),
              Text('${el.$2}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          );
        }),
        const Divider(color: AppColors.border, height: 16),
        Row(children: [
          Expanded(
              child: _ScoreChip(
                  label: 'Baskın',
                  value: ec.dominantScore,
                  color: AppColors.gold)),
          const SizedBox(width: 8),
          Expanded(
              child: _ScoreChip(
                  label: 'Edilgen',
                  value: ec.passiveScore,
                  color: AppColors.purpleLight)),
          const SizedBox(width: 8),
          Expanded(child: _EnergyChip(type: ec.energyType)),
        ]),
      ]),
    );
  }
}

class _PersonElemBox extends StatelessWidget {
  final String name;
  final dynamic elem;
  final Color color;
  final IconData icon;
  const _PersonElemBox(
      {required this.name,
      required this.elem,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 5),
        Row(children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(elem.dominantElement,
              style: AppTextStyles.bodySmall.copyWith(color: color)),
        ]),
        const SizedBox(height: 2),
        Text(elem.energyType,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textMuted, fontSize: 10)),
      ]),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ScoreChip(
      {required this.label, required this.value, required this.color});
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

class _EnergyChip extends StatelessWidget {
  final String type;
  const _EnergyChip({required this.type});
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

// ─── Ortak widget'lar ─────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String text;
  const _SummaryCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1040), Color(0xFF0A0E1A)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome,
                size: 16, color: AppColors.purpleLight),
            const SizedBox(width: 8),
            Text('Genel Özet',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.purpleLight)),
          ]),
          const SizedBox(height: 14),
          Text(text, style: AppTextStyles.bodyLarge),
        ]),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionTitle(this.text, this.icon);
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: AppColors.purpleLight),
        const SizedBox(width: 8),
        Text(text,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.purpleLight)),
      ]);
}

class _HaneCard extends StatelessWidget {
  final String hane, title, text;
  final Color color;
  final bool special;
  const _HaneCard(
      {required this.hane,
      required this.title,
      required this.text,
      required this.color,
      this.special = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: special ? color.withValues(alpha: 0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: color.withValues(alpha: special ? 0.4 : 0.2)),
          ),
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(hane,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.labelMedium.copyWith(color: color)),
            ]),
            const SizedBox(height: 10),
            Text(text, style: AppTextStyles.bodyLarge),
          ]),
        ),
      );
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _DetailCard(
      {required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
        ]),
      );
}
