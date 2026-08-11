import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/settings_tile.dart';

/// M-25 — Ilova haqida
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Ilova haqida', style: AppTextStyles.h4)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: Text('Miila', style: AppTextStyles.logo)),
            Center(child: Text('Versiya 1.0.0', style: AppTextStyles.caption)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'Miila — ayollar sog\'lig\'i uchun sikl kuzatuvi, shaxsiy tahlillar va '
                'ishonchli tibbiy ta\'lim ilovasi. Sog\'lig\'ingizni tushunish — '
                'o\'zingizni sevishning birinchi qadami. 🌸',
                style: AppTextStyles.body.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
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
                    icon: Icons.description_outlined,
                    title: 'Foydalanish shartlari',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Maxfiylik siyosati',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.star_outline_rounded,
                    iconColor: AppColors.gold,
                    title: 'Ilovani baholash',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text('Miila jamoasi tomonidan ❤ bilan yaratildi',
                  style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }
}
