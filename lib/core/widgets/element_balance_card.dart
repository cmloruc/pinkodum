import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../../data/models/element_balance.dart';
import '../../data/services/element_balance_calculator.dart';

class ElementBalanceCard extends StatelessWidget {
  final String name;
  final ElementBalance balance;
  final String insight;

  const ElementBalanceCard({
    super.key,
    required this.name,
    required this.balance,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111828), Color(0xFF0A0E1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(Icons.auto_awesome_mosaic_outlined,
                  size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'Element Haritan',
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baskın + Zayıf + Enerji tipi rozet satırı
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: 'Baskın',
                value: balance.dominantElement,
                color: _elementColor(balance.dominantElement),
                icon: _elementIcon(balance.dominantElement),
              ),
              _Badge(
                label: 'Zayıf',
                value: balance.weakestElement,
                color: AppColors.textMuted,
                icon: _elementIcon(balance.weakestElement),
                dim: true,
              ),
              _Badge(
                label: 'Enerji',
                value: balance.energyType,
                color: _energyColor(balance.energyType),
                icon: _energyIcon(balance.energyType),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Element dağılım barları
          _ElementBars(balance: balance),
          const SizedBox(height: 16),

          // Baskın / Edilgen skor
          Row(
            children: [
              Expanded(
                child: _ScoreChip(
                  label: 'Baskın Enerji',
                  value: balance.dominantScore,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ScoreChip(
                  label: 'Edilgen Enerji',
                  value: balance.passiveScore,
                  color: AppColors.purpleLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Yorum metni
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
            ),
            child: Text(insight, style: AppTextStyles.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class RelationshipElementCard extends StatelessWidget {
  final String name1;
  final String name2;
  final ElementBalance e1;
  final ElementBalance e2;
  final String insight;
  final String sharedStrength;
  final String complementary;
  final String friction;

  const RelationshipElementCard({
    super.key,
    required this.name1,
    required this.name2,
    required this.e1,
    required this.e2,
    required this.insight,
    required this.sharedStrength,
    required this.complementary,
    required this.friction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111828), Color(0xFF0A0E1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_mosaic_outlined,
                  size: 16, color: AppColors.purpleLight),
              const SizedBox(width: 8),
              Text(
                'Element Uyumunuz',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.purpleLight),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // İki kişinin özet rozetleri yan yana
          Row(
            children: [
              Expanded(child: _PersonElementSummary(name: name1, e: e1)),
              const SizedBox(width: 12),
              Expanded(child: _PersonElementSummary(name: name2, e: e2)),
            ],
          ),
          const SizedBox(height: 16),

          // Ortak güçlü, tamamlayıcı, sürtünme
          _InfoRow(
            icon: Icons.star_outline,
            color: AppColors.gold,
            label: 'Ortak Güçlü Element',
            value: sharedStrength,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.compare_arrows,
            color: AppColors.success,
            label: 'Tamamlayıcı',
            value: complementary,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.bolt_outlined,
            color: AppColors.warning,
            label: 'Dikkat Alanı',
            value: friction,
          ),
          const SizedBox(height: 16),

          // Yorum metni
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.purple.withValues(alpha: 0.15)),
            ),
            child: Text(insight, style: AppTextStyles.bodyLarge),
          ),
        ],
      ),
    );
  }
}

// ─── Yardımcı widget'lar ─────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool dim;

  const _Badge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dim ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: dim ? 0.15 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: dim ? AppColors.textMuted : color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontSize: 9, color: AppColors.textMuted)),
              Text(value,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: dim ? AppColors.textMuted : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ElementBars extends StatelessWidget {
  final ElementBalance balance;
  const _ElementBars({required this.balance});

  @override
  Widget build(BuildContext context) {
    final total = balance.air +
        balance.water +
        balance.fire +
        balance.earth +
        balance.balanceNine;
    return Column(
      children: [
        _Bar('Hava', balance.air, total,
            _elementColor(ElementBalanceCalculator.elementAir), Icons.air),
        const SizedBox(height: 6),
        _Bar(
            'Su',
            balance.water,
            total,
            _elementColor(ElementBalanceCalculator.elementWater),
            Icons.water_drop_outlined),
        const SizedBox(height: 6),
        _Bar(
            'Ateş',
            balance.fire,
            total,
            _elementColor(ElementBalanceCalculator.elementFire),
            Icons.local_fire_department_outlined),
        const SizedBox(height: 6),
        _Bar(
            'Toprak',
            balance.earth,
            total,
            _elementColor(ElementBalanceCalculator.elementEarth),
            Icons.landscape_outlined),
        if (balance.balanceNine > 0) ...[
          const SizedBox(height: 6),
          _Bar('Denge / 9', balance.balanceNine, total, AppColors.gold,
              Icons.balance),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _Bar(this.label, this.count, this.total, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        SizedBox(
          width: 52,
          child: Text(label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: AppTextStyles.bodySmall.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value % 1 == 0 ? value.toInt().toString() : value.toString(),
            style: AppTextStyles.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PersonElementSummary extends StatelessWidget {
  final String name;
  final ElementBalance e;
  const _PersonElementSummary({required this.name, required this.e});

  @override
  Widget build(BuildContext context) {
    final color = _elementColor(e.dominantElement);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(_elementIcon(e.dominantElement), size: 12, color: color),
              const SizedBox(width: 4),
              Text(e.dominantElement,
                  style: AppTextStyles.bodySmall.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(_energyIcon(e.energyType),
                  size: 12, color: _energyColor(e.energyType)),
              const SizedBox(width: 4),
              Text(e.energyType,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: _energyColor(e.energyType))),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: color, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Renk ve ikon yardımcıları ───────────────────────────────────────────────

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
