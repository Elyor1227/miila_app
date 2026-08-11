import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// L-05 — Emailingizni tekshiring
class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showBack: false,
      bottom: PrimaryButton(
        label: 'Kirishga qaytish',
        showArrow: false,
        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: AppColors.blush, shape: BoxShape.circle, border: Border.all(color: AppColors.cardBorder)),
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.pink, size: 40),
          ),
          const SizedBox(height: 28),
          Text('Emailingizni tekshiring', style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Parolni tiklash havolasini email manzilingizga yubordik. Pochta qutingizni tekshiring',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
