import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// R-06 — Hisob yaratish (to'g'ridan-to'g'ri /auth/register, SMS kodsiz).
/// TODO(sms-otp): keyinroq SMS tasdiqlash yoqilsa — sendOtp + /sms-verify
/// oqimiga qaytariladi (R-07 ekrani va backend /auth/otp/* tayyor turibdi).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // L-02/L-03 dan kelganda oldindan to'ldirilgan bo'lishi mumkin
    final data = OnboardingData.instance;
    _nameController.text = data.name;
    _emailController.text = data.email;
    _phoneController.text = data.phone;
    _passwordController.text = data.password;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() => _error = 'Barcha maydonlarni to\'ldiring');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Parol kamida 6 ta belgi bo\'lishi kerak');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().register(
            name: name,
            email: email,
            password: password,
            phone: phone,
          );
      if (!mounted) return;
      OnboardingData.instance.reset();
      Navigator.of(context).pushNamed('/age');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Hisob yarating', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('Ma\'lumotlaringizni kiriting', style: AppTextStyles.body),
          const SizedBox(height: 28),
          AppTextField(label: 'Ism', hint: 'Ismingiz', controller: _nameController),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Email',
            hint: 'email@misol.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Telefon raqami',
            hint: '+998 90 123 45 67',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Parol',
            hint: 'Kamida 6 ta belgi',
            controller: _passwordController,
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(label: 'Ro\'yxatdan o\'tish', isLoading: _loading, onPressed: _submit),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/login'),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                  children: [
                    TextSpan(text: 'Hisobingiz bormi? '),
                    TextSpan(
                      text: 'Kirish',
                      style: TextStyle(color: AppColors.pink, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
