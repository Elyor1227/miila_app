import 'package:flutter/material.dart';

import '../../state/onboarding_data.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// L-02 — Email forma (ro'yxatdan o'tish). Ma'lumotlar saqlanadi va
/// telefon raqam so'raladigan L-03 ga o'tiladi.
class EmailFormScreen extends StatefulWidget {
  const EmailFormScreen({super.key});

  @override
  State<EmailFormScreen> createState() => _EmailFormScreenState();
}

class _EmailFormScreenState extends State<EmailFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Barcha maydonlarni to\'ldiring');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Parol kamida 6 ta belgi bo\'lishi kerak');
      return;
    }

    final data = OnboardingData.instance;
    data.name = name;
    data.email = email;
    data.password = password;
    Navigator.of(context).pushNamed('/phone-form');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottom: PrimaryButton(label: 'Davom etish', onPressed: _submit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Ro\'yxatdan o\'tish', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('Hisobingizni yaratish uchun ma\'lumotlarni to\'ldiring', style: AppTextStyles.body),
          const SizedBox(height: 28),
          AppTextField(label: 'Ism va familiya', hint: 'Komila Karimova', controller: _nameController),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Email',
            hint: 'email@misol.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Parol',
            hint: 'Kamida 6 ta belgi',
            controller: _passwordController,
            obscureText: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
