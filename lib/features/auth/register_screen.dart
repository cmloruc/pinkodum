import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/date_picker_row.dart';
import '../../data/services/auth_service.dart';
import 'login_screen.dart' show AuthErrorBox;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      setState(() => _error = 'Doğum tarihini seç.');
      return;
    }
    if (_birthDate!.isAfter(DateTime.now())) {
      setState(() => _error = 'Doğum tarihi gelecekte olamaz.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await AuthService(prefs).register(
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        birthDate: _birthDate!,
        password: _passCtrl.text,
      );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 18, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 32),
                  Text('Hesap Oluştur', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text('Analizlerin tüm cihazlarında senkronize edilsin.',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _nameCtrl,
                    label: 'Ad Soyad',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'İsim gir' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'E-posta',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Geçerli e-posta gir'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Doğum Tarihi', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  DatePickerRow(
                    initialDate: _birthDate,
                    onChanged: (d) => setState(() => _birthDate = d),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passCtrl,
                    label: 'Şifre',
                    obscure: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'En az 6 karakter' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    AuthErrorBox(message: _error!),
                  ],
                  const SizedBox(height: 32),
                  GoldButton(
                    label: _loading ? 'Hesap oluşturuluyor...' : 'Kayıt Ol',
                    onPressed: _loading ? null : _submit,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'Hesabın var mı? '),
                            TextSpan(
                              text: 'Giriş Yap',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textGold),
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
        ),
      ),
    );
  }
}
