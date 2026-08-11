import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/settings_tile.dart';

/// M-24 — Yordam va aloqa
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faq = [
    (
      'Sikl qanday hisoblanadi?',
      'Oxirgi hayz boshlangan sanadan boshlab sikl uzunligi bo\'yicha hisoblanadi. Kalendar bo\'limida bashoratlarni ko\'rishingiz mumkin.'
    ),
    (
      'Premium obunani qanday bekor qilaman?',
      'Profil → Obuna boshqaruvi → "Obunani bekor qilish". Premium joriy davr oxirigacha ishlayveradi.'
    ),
    (
      'Ma\'lumotlarim xavfsizmi?',
      'Barcha ma\'lumotlar shifrlangan aloqa orqali uzatiladi. Maxfiylik bo\'limida anonim rejimni ham yoqishingiz mumkin.'
    ),
    (
      'Eslatmalarni qanday sozlayman?',
      'Profil → Bildirishnomalar bo\'limida har bir eslatma turini alohida yoqish/o\'chirish mumkin.'
    ),
    (
      'Belgilarni qanday kiritaman?',
      'Bosh sahifadagi "Batafsil belgilash" yoki Kalendar → "Belgi qo\'shish" tugmasi orqali kunlik belgi, kayfiyat va og\'riq darajasini kiriting.'
    ),
  ];

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Yordam va aloqa', style: AppTextStyles.h4)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('TEZ-TEZ BERILADIGAN SAVOLLAR', style: AppTextStyles.label),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _faq.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(_faq[i].$1, style: AppTextStyles.bodyMedium),
                        iconColor: AppColors.pink,
                        collapsedIconColor: AppColors.muted,
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_faq[i].$2, style: AppTextStyles.body),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('BIZ BILAN BOG\'LANING', style: AppTextStyles.label),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.telegram,
                    iconColor: const Color(0xFF2AABEE),
                    title: 'Telegram',
                    subtitle: '@miila_support',
                    onTap: () => _open('https://t.me/miila_support'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'support@miila.uz',
                    onTap: () => _open('mailto:support@miila.uz'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: AppColors.success,
                    title: 'Savol yuborish',
                    subtitle: 'Mutaxassisga savol bering',
                    onTap: () => Navigator.of(context).pushNamed('/qna'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
