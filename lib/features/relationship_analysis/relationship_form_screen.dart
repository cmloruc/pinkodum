import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/date_picker_row.dart';
import '../../data/services/ai_analysis_service.dart';
import '../../data/services/api_key_service.dart';

class RelationshipFormScreen extends StatefulWidget {
  const RelationshipFormScreen({super.key});

  @override
  State<RelationshipFormScreen> createState() => _RelationshipFormScreenState();
}

class _RelationshipFormScreenState extends State<RelationshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name1 = TextEditingController();
  final _name2 = TextEditingController();
  DateTime? _date1;
  DateTime? _date2;
  String? _relType;
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
    _name1.dispose();
    _name2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date1 == null || _date2 == null) {
      _showSnack(AppStrings.validationDateRequired);
      return;
    }
    if (_relType == null) {
      _showSnack(AppStrings.validationRelationshipRequired);
      return;
    }
    setState(() => _loading = true);
    try {
      final service = _service;
      if (service == null) {
        throw Exception('Analiz servisi hazırlanamadı.');
      }
      final analysis = await service.analyzeRelationship(
        firstName: _name1.text.trim(),
        firstBirthDate: _date1!,
        secondName: _name2.text.trim(),
        secondBirthDate: _date2!,
        relationshipType: _relType!,
      );
      if (mounted) {
        context.push(AppRoutes.relationshipResult, extra: analysis);
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _RelAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.purple.withOpacity(0.1),
                                  border: Border.all(
                                      color: AppColors.purple.withOpacity(0.4),
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.favorite_outline,
                                    size: 28, color: AppColors.purple),
                              ),
                              const SizedBox(height: 16),
                              Text('İlişki Analizini Başlat',
                                  style: AppTextStyles.headlineMedium),
                              const SizedBox(height: 8),
                              Text(
                                'İki kişinin enerji uyumunu keşfet',
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionLabel('1. Kişi'),
                        const SizedBox(height: 12),
                        _NameField(controller: _name1, hint: '1. kişinin adı'),
                        const SizedBox(height: 12),
                        DatePickerRow(
                          initialDate: _date1,
                          onChanged: (d) => setState(() => _date1 = d),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel('2. Kişi'),
                        const SizedBox(height: 12),
                        _NameField(controller: _name2, hint: '2. kişinin adı'),
                        const SizedBox(height: 12),
                        DatePickerRow(
                          initialDate: _date2,
                          onChanged: (d) => setState(() => _date2 = d),
                        ),
                        const SizedBox(height: 24),
                        Text(AppStrings.labelRelationshipType,
                            style: AppTextStyles.labelMedium),
                        const SizedBox(height: 8),
                        _RelationshipDropdown(
                          value: _relType,
                          onChanged: (v) => setState(() => _relType = v),
                        ),
                        const SizedBox(height: 40),
                        GoldButton(
                          label: AppStrings.btnCalculateRelationship,
                          loading: _loading,
                          onPressed: _submit,
                          icon: Icons.favorite,
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.purpleLight)),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _NameField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyLarge,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            const Icon(Icons.person_outline, color: AppColors.textMuted),
      ),
      validator: (v) => (v == null || v.trim().isEmpty)
          ? AppStrings.validationNameRequired
          : null,
    );
  }
}

class _RelationshipDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _RelationshipDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surfaceLight,
      style: AppTextStyles.bodyLarge,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.link_outlined, color: AppColors.textMuted),
      ),
      hint: Text('İlişki türü seç', style: AppTextStyles.bodyMedium),
      items: AppStrings.relationshipTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: onChanged,
      validator: (v) =>
          v == null ? AppStrings.validationRelationshipRequired : null,
    );
  }
}

class _RelAppBar extends StatelessWidget {
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
            child: Text(
              AppStrings.homeRelationshipAnalysis,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
