import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// L-03 — Telefon raqamingiz. OTP yuboriladi va R-07 ga o'tiladi.
class PhoneFormScreen extends StatefulWidget {
  const PhoneFormScreen({super.key});

  @override
  State<PhoneFormScreen> createState() => _PhoneFormScreenState();
}

class _PhoneFormScreenState extends State<PhoneFormScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      setState(() => _error = 'Telefon raqamni to\'liq kiriting');
      return;
    }
    final phone = '+998${digits.length > 9 ? digits.substring(digits.length - 9) : digits}';

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      OnboardingData.instance.phone = phone;
      await _authService.sendOtp(phone);
      if (!mounted) return;
      Navigator.of(context).pushNamed('/sms-verify');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottom: PrimaryButton(label: 'Kod yuborish', isLoading: _loading, onPressed: _submit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Telefon raqamingiz', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('Sizga tasdiqlash kodi yuboriladi', style: AppTextStyles.body),
          const SizedBox(height: 28),
          Text('Telefon raqami', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('🇺🇿  +998', style: AppTextStyles.bodyLarge.copyWith(fontSize: 15)),
                const SizedBox(width: 10),
                Container(width: 1, height: 24, color: AppColors.cardBorder),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: '90 123 45 67',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
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
