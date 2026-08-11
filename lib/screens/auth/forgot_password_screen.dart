import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// L-04 — Parolni unutdingizmi? Email'ga tiklash havolasi yuboriladi.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Email manzilingizni to\'g\'ri kiriting');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.forgotPassword(email);
      if (!mounted) return;
      Navigator.of(context).pushNamed('/email-sent', arguments: email);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottom: PrimaryButton(
        label: 'Havola yuborish',
        showArrow: false,
        isLoading: _loading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.blush,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.lock_reset_rounded, color: AppColors.pink, size: 28),
          ),
          const SizedBox(height: 20),
          Text('Parolni unutdingizmi?', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Email manzilingizni kiriting — parolni tiklash havolasini yuboramiz',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'Email',
            hint: 'email@misol.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
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
