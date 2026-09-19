import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO(ijtimoiy-kirish): Google/Apple keyinroq yoqiladi — pastdagi kommentlarni oching
// import '../../services/google_auth_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

/// L-01 — Kirish (real /auth/login API'ga ulangan)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  // TODO(ijtimoiy-kirish): Google kirish keyinroq yoqiladi — kommentni oching
  // (backend /auth/google va google_auth_service.dart tayyor turibdi)
  //
  // bool _googleLoading = false;
  // final _googleAuth = GoogleAuthService();
  //
  // Future<void> _googleSubmit() async {
  //   setState(() {
  //     _googleLoading = true;
  //     _error = null;
  //   });
  //   try {
  //     final creds = await _googleAuth.signIn(context);
  //     if (creds == null || creds.isEmpty) return; // foydalanuvchi bekor qildi
  //     if (!mounted) return;
  //     await context.read<AuthProvider>().loginWithGoogle(
  //           idToken: creds.idToken,
  //           accessToken: creds.accessToken,
  //         );
  //     if (!mounted) return;
  //     Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
  //   } catch (e) {
  //     if (mounted) setState(() => _error = e.toString());
  //   } finally {
  //     if (mounted) setState(() => _googleLoading = false);
  //   }
  // }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    if (login.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email/telefon va parolni kiriting');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(login: login, password: password);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Kirish', showArrow: false, isLoading: _loading, onPressed: _submit),
          // TODO(ijtimoiy-kirish): Google/Apple tugmalari keyinroq yoqiladi — kommentni oching
          //
          // const SizedBox(height: 14),
          // Row(
          //   children: [
          //     const Expanded(child: Divider(color: AppColors.cardBorder)),
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 12),
          //       child: Text('yoki', style: AppTextStyles.caption),
          //     ),
          //     const Expanded(child: Divider(color: AppColors.cardBorder)),
          //   ],
          // ),
          // const SizedBox(height: 14),
          // SecondaryButton(
          //   label: _googleLoading ? 'Kutilmoqda...' : 'Google bilan davom etish',
          //   icon: _googleLoading
          //       ? const SizedBox(
          //           width: 18,
          //           height: 18,
          //           child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4)),
          //         )
          //       : const Icon(Icons.g_mobiledata_rounded, size: 26, color: Color(0xFF4285F4)),
          //   onPressed: _googleLoading ? null : _googleSubmit,
          // ),
          // const SizedBox(height: 10),
          // SecondaryButton(
          //   label: 'Apple bilan davom etish',
          //   icon: const Icon(Icons.apple_rounded, size: 22, color: AppColors.ink),
          //   onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(content: Text('Apple orqali kirish tez orada qo\'shiladi')),
          //   ),
          // ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/register'),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: AppColors.muted, fontSize: 14),
                children: [
                  TextSpan(text: 'Hisobingiz yo\'qmi? '),
                  TextSpan(text: 'Ro\'yxatdan o\'tish', style: TextStyle(color: AppColors.pink, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Xush kelibsiz!', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('Hisobingizga kirish uchun ma\'lumotlarni kiriting', style: AppTextStyles.body),
          const SizedBox(height: 28),
          AppTextField(label: 'Email yoki telefon', hint: 'email@misol.com', controller: _loginController),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Parol',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
