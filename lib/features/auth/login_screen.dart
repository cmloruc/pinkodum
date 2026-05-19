import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      await AuthService(prefs).login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
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
                  Text('Giriş Yap', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text('Analizlerin bulutta senkronize edilsin.',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'E-posta',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Geçerli e-posta gir' : null,
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
                    label: _loading ? 'Giriş yapılıyor...' : 'Giriş Yap',
                    onPressed: _loading ? null : _submit,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'Hesabın yok mu? '),
                            TextSpan(
                              text: 'Kayıt Ol',
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

class AuthErrorBox extends StatelessWidget {
  final String message;
  const AuthErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
    );
  }
}
