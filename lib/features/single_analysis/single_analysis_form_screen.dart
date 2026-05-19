import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/date_picker_row.dart';
import '../../data/services/ai_analysis_service.dart';
import '../../data/services/api_key_service.dart';

class SingleAnalysisFormScreen extends StatefulWidget {
  const SingleAnalysisFormScreen({super.key});

  @override
  State<SingleAnalysisFormScreen> createState() =>
      _SingleAnalysisFormScreenState();
}

class _SingleAnalysisFormScreenState extends State<SingleAnalysisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  bool _loading = false;
  AiAnalysisService? _service;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();
    final keyService = ApiKeyService(prefs);
    setState(() {
      _service = AiAnalysisService(keyService: keyService);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _showError(AppStrings.validationDateRequired);
      return;
    }
    setState(() => _loading = true);
    try {
      final service = _service;
      if (service == null) {
        throw Exception('Analiz servisi hazırlanamadı.');
      }
      final analysis = await service.analyzePersone(
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
      );
      if (mounted) {
        context.push(AppRoutes.singleResult, extra: analysis);
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(title: AppStrings.homeSingleAnalysis),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dekoratif başlık
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withOpacity(0.1),
                                  border: Border.all(
                                    color: AppColors.gold.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_search_outlined,
                                  size: 28,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Pin Kodunu Hesapla',
                                style: AppTextStyles.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'İsmin ve doğum tarihinle numerolojik pin kodunu keşfet',
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(AppStrings.labelName,
                            style: AppTextStyles.labelMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: AppTextStyles.bodyLarge,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Adını gir',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.textMuted),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? AppStrings.validationNameRequired
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(AppStrings.labelBirthDate,
                            style: AppTextStyles.labelMedium),
                        const SizedBox(height: 8),
                        DatePickerRow(
                          initialDate: _birthDate,
                          onChanged: (d) => setState(() => _birthDate = d),
                        ),
                        const SizedBox(height: 40),
                        GoldButton(
                          label: AppStrings.btnCalculate,
                          loading: _loading,
                          onPressed: _submit,
                          icon: Icons.auto_awesome,
                        ),
                      ],
                    ),
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

class _AppBar extends StatelessWidget {
  final String title;
  const _AppBar({required this.title});

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
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
