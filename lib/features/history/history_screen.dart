import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/home_button.dart';
import '../../data/models/person_analysis.dart';
import '../../data/models/person_premium_analysis.dart';
import '../../data/models/relationship_analysis.dart';
import '../../data/models/relationship_premium_analysis.dart';
import '../../data/repositories/repository_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PersonAnalysis> _persons = [];
  List<RelationshipAnalysis> _relationships = [];
  List<PersonPremiumAnalysis> _premiums = [];
  List<RelationshipPremiumAnalysis> _relPremiums = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final repo = await getRepository();
    final persons = await repo.getPersonAnalyses();
    final rels = await repo.getRelationshipAnalyses();
    final premiums = await repo.getPremiumAnalyses();
    final relPremiums = await repo.getRelationshipPremiumAnalyses();
    if (mounted) {
      setState(() {
        _persons = persons;
        _relationships = rels;
        _premiums = premiums;
        _relPremiums = relPremiums;
        _loading = false;
      });
    }
  }

  Future<void> _deletePerson(String id) async {
    await (await getRepository()).deletePersonAnalysis(id);
    if (mounted) setState(() => _persons.removeWhere((e) => e.id == id));
  }

  Future<void> _deleteRelationship(String id) async {
    await (await getRepository()).deleteRelationshipAnalysis(id);
    if (mounted) setState(() => _relationships.removeWhere((e) => e.id == id));
  }

  Future<void> _deletePremium(String id) async {
    await (await getRepository()).deletePremiumAnalysis(id);
    if (mounted) setState(() => _premiums.removeWhere((e) => e.id == id));
  }

  Future<void> _deleteRelPremium(String id) async {
    await (await getRepository()).deleteRelationshipPremiumAnalysis(id);
    if (mounted) setState(() => _relPremiums.removeWhere((e) => e.id == id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                      child: Text(AppStrings.homeHistory,
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center),
                    ),
                    const HomeButton(),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.gold,
                indicatorWeight: 2,
                labelColor: AppColors.textGold,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Tekil'),
                  Tab(text: 'İlişki'),
                  Tab(text: 'Det. Tekil'),
                  Tab(text: 'Det. İlişki'),
                ],
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _PersonList(items: _persons, onDelete: _deletePerson),
                          _RelationshipList(items: _relationships, onDelete: _deleteRelationship),
                          _PremiumList(items: _premiums, onDelete: _deletePremium),
                          _RelPremiumList(items: _relPremiums, onDelete: _deleteRelPremium),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Boş durum ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 56,
              color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(AppStrings.historyEmpty,
              style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(AppStrings.historyEmptyDesc,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Tekil analizler ─────────────────────────────────────────────────────────
class _PersonList extends StatelessWidget {
  final List<PersonAnalysis> items;
  final Future<void> Function(String id) onDelete;
  const _PersonList({required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: _DeleteBackground(),
          onDismissed: (_) => onDelete(item.id),
          child: GradientCard(
            onTap: () => context.push(AppRoutes.singleResult, extra: item),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _HistoryAvatar(icon: Icons.person_outline, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 2),
                      Text(item.pinCodeFormatted,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textGold, letterSpacing: 1.5)),
                      const SizedBox(height: 2),
                      Text(DateFormatter.formatRelative(item.createdAt),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── İlişki analizleri ───────────────────────────────────────────────────────
class _RelationshipList extends StatelessWidget {
  final List<RelationshipAnalysis> items;
  final Future<void> Function(String id) onDelete;
  const _RelationshipList({required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: _DeleteBackground(),
          onDismissed: (_) => onDelete(item.id),
          child: GradientCard(
            onTap: () => context.push(AppRoutes.relationshipResult, extra: item),
            borderColor: AppColors.purple.withValues(alpha: 0.25),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _HistoryAvatar(icon: Icons.favorite_outline, color: AppColors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 2),
                      Text(item.relationshipType,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.purpleLight)),
                      const SizedBox(height: 2),
                      Text(DateFormatter.formatRelative(item.createdAt),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Detaylı (premium) analizler ─────────────────────────────────────────────
class _PremiumList extends StatelessWidget {
  final List<PersonPremiumAnalysis> items;
  final Future<void> Function(String id) onDelete;
  const _PremiumList({required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: _DeleteBackground(),
          onDismissed: (_) => onDelete(item.id),
          child: GradientCard(
            onTap: () => context.push(AppRoutes.premiumResult, extra: item),
            borderColor: AppColors.gold.withValues(alpha: 0.3),
            gradientColors: [
              AppColors.gold.withValues(alpha: 0.06),
              AppColors.cardBackground,
            ],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _HistoryAvatar(icon: Icons.auto_awesome, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item.name, style: AppTextStyles.titleMedium),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Detaylı',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item.pinCode.join('-'),
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textGold, letterSpacing: 1.5)),
                      const SizedBox(height: 2),
                      Text(DateFormatter.formatRelative(item.createdAt),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Ortak avatar widget ──────────────────────────────────────────────────────
class _HistoryAvatar extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _HistoryAvatar({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

// ─── Detaylı ilişki analizleri ────────────────────────────────────────────────
class _RelPremiumList extends StatelessWidget {
  final List<RelationshipPremiumAnalysis> items;
  final Future<void> Function(String id) onDelete;
  const _RelPremiumList({required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: _DeleteBackground(),
          onDismissed: (_) => onDelete(item.id),
          child: GradientCard(
            onTap: () => context.push(AppRoutes.relPremiumResult, extra: item),
            borderColor: AppColors.purple.withValues(alpha: 0.3),
            gradientColors: [
              AppColors.purple.withValues(alpha: 0.06),
              AppColors.cardBackground,
            ],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _HistoryAvatar(icon: Icons.favorite, color: AppColors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(item.title, style: AppTextStyles.titleMedium),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Detaylı',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.purpleLight, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      Text(item.relationshipType,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.purpleLight)),
                      const SizedBox(height: 2),
                      Text(DateFormatter.formatRelative(item.createdAt),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Sil arka plan ───────────────────────────────────────────────────────────
class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
    );
  }
}
