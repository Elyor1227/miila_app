import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/auth_provider.dart';
import 'screens/splash_screen.dart';

import 'screens/onboarding/language_screen.dart';
import 'screens/onboarding/onboarding_carousel_screen.dart';
import 'screens/onboarding/register_screen.dart';
import 'screens/onboarding/sms_verify_screen.dart';
import 'screens/onboarding/age_screen.dart';
import 'screens/onboarding/last_period_screen.dart';
import 'screens/onboarding/cycle_length_screen.dart';
import 'screens/onboarding/ready_screen.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/email_form_screen.dart';
import 'screens/auth/phone_form_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/email_sent_screen.dart';

import 'screens/main/main_shell.dart';
import 'screens/main/edit_profile_screen.dart';
import 'screens/main/payment_screen.dart';
import 'screens/main/notifications_screen.dart';
import 'screens/main/notification_settings_screen.dart';
import 'screens/main/privacy_screen.dart';
import 'screens/main/pin_code_screen.dart';
import 'screens/main/subscription_screen.dart';
import 'screens/main/delete_data_screen.dart';
import 'screens/main/help_screen.dart';
import 'screens/main/about_screen.dart';
import 'screens/main/analytics_screen.dart';
import 'screens/main/symptom_entry_screen.dart';
import 'screens/main/qna_screen.dart';

void main() {
  runApp(const MiilaApp());
}

class MiilaApp extends StatelessWidget {
  const MiilaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Miila',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/language': (context) => const LanguageScreen(),
          '/onboarding': (context) => const OnboardingCarouselScreen(),
          '/register': (context) => const RegisterScreen(),
          '/sms-verify': (context) => const SmsVerifyScreen(),
          '/age': (context) => const AgeScreen(),
          '/last-period': (context) => const LastPeriodScreen(),
          '/cycle-length': (context) => const CycleLengthScreen(),
          '/ready': (context) => const ReadyScreen(),
          '/login': (context) => const LoginScreen(),
          '/email-form': (context) => const EmailFormScreen(),
          '/phone-form': (context) => const PhoneFormScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/email-sent': (context) => const EmailSentScreen(),
          '/home': (context) => const MainShell(),
          '/profile/edit': (context) => const EditProfileScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/notification-settings': (context) => const NotificationSettingsScreen(),
          '/privacy': (context) => const PrivacyScreen(),
          '/pin-code': (context) => const PinCodeScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
          '/delete-data': (context) => const DeleteDataScreen(),
          '/help': (context) => const HelpScreen(),
          '/about': (context) => const AboutScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/symptom-entry': (context) => const SymptomEntryScreen(),
          '/qna': (context) => const QnaScreen(),
        },
      ),
    );
  }
}
