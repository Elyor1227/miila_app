import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/auth_provider.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// R-07 — Raqamni tasdiqlang (SMS kod). Kod tasdiqlangach, R-06 da yig'ilgan
/// ma'lumotlar bilan haqiqiy register chaqiriladi va /age ga o'tiladi.
class SmsVerifyScreen extends StatefulWidget {
  const SmsVerifyScreen({super.key});

  @override
  State<SmsVerifyScreen> createState() => _SmsVerifyScreenState();
}

class _SmsVerifyScreenState extends State<SmsVerifyScreen> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final data = OnboardingData.instance;
    if (_code.length < 4) {
      setState(() => _error = '4 xonali kodni to\'liq kiriting');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _authService.verifyOtp(data.phone, _code);

      if (data.password.isNotEmpty) {
        // Ro'yxatdan o'tish oqimi (R-06 → R-07)
        await context.read<AuthProvider>().register(
              name: data.name,
              email: data.email,
              password: data.password,
              phone: data.phone,
              phoneVerifyToken: token,
            );
        if (!mounted) return;
        Navigator.of(context).pushNamed('/age');
      } else {
        // Faqat telefon tasdiqlash oqimi — register sahifasiga qaytamiz
        if (!mounted) return;
        Navigator.of(context).pushNamed('/register');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final data = OnboardingData.instance;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await _authService.sendOtp(data.phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kod qayta yuborildi')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = OnboardingData.instance.phone;
    return OnboardingScaffold(
      bottom: PrimaryButton(label: 'Tasdiqlash', isLoading: _loading, onPressed: _verify),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Raqamni tasdiqlang', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            '$phone raqamiga yuborilgan 4 xonali kodni kiriting',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 36),
          PinCodeBoxes(controllers: _controllers, focusNodes: _focusNodes),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Center(
              child: Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
            ),
          ],
          const SizedBox(height: 28),
          Center(
            child: GestureDetector(
              onTap: _resending ? null : _resend,
              child: Text(
                _resending ? 'Yuborilmoqda...' : 'Kodni qayta yuborish',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.pink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
