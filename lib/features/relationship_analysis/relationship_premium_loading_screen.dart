import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/relationship_analysis.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/ai_analysis_service.dart';
import '../../data/services/api_key_service.dart';

class RelationshipPremiumLoadingScreen extends StatefulWidget {
  final RelationshipAnalysis analysis;
  const RelationshipPremiumLoadingScreen({super.key, required this.analysis});

  @override
  State<RelationshipPremiumLoadingScreen> createState() =>
      _RelationshipPremiumLoadingScreenState();
}

class _RelationshipPremiumLoadingScreenState
    extends State<RelationshipPremiumLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  int _messageIndex = 0;
  bool _started = false;

  static const _messages = [
    'İki enerji bir araya getiriliyor...',
    'Ortak pin kodu yorumlanıyor...',
    'Element uyumu analiz ediliyor...',
    'İletişim kalıpları inceleniyor...',
    'Büyüme fırsatları keşfediliyor...',
    'Yıl enerjisi hesaplanıyor...',
    'Derin ilişki haritanız çiziliyor...',
    'Raporunuz hazırlanıyor...',
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotateMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnalysis());
  }

  void _rotateMessages() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
        _rotateMessages();
      }
    });
  }

  Future<void> _startAnalysis() async {
    setState(() => _started = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final keyService = ApiKeyService(prefs);
      final a = widget.analysis;

      final aiService = AiAnalysisService(keyService: keyService);
      final premium = await aiService.analyzeRelationshipPremium(
        firstName: a.firstName,
        firstBirthDate: a.firstBirthDate,
        secondName: a.secondName,
        secondBirthDate: a.secondBirthDate,
        relationshipType: a.relationshipType,
      );

      final repo = await getRepository();
      await repo.saveRelationshipPremiumAnalysis(premium);
      await repo.deleteRelationshipAnalysis(widget.analysis.id);

      if (mounted) {
        context.pushReplacement(AppRoutes.relPremiumResult, extra: premium);
      }
    } catch (e) {
      debugPrint('Premium analysis error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF1A0A2E), Color(0xFF0A0E1A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _pulse,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.purpleGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite,
                          size: 52, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text('Detaylı İlişki Analizi',
                      style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.analysis.firstName} & ${widget.analysis.secondName}',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.purpleLight,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.purple.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: AppColors.purpleLight),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Detaylı analiz 1-2 dakika sürebilir. Lütfen uygulamayı kapatmayın ve ekrandan ayrılmayın.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.purple.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.purpleLight),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
