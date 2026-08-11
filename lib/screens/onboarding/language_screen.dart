import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'uz';

  final _languages = const [
    {'code': 'uz', 'flag': '🇺🇿', 'name': 'O\'zbek', 'native': 'Ona tili'},
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'Русский', 'native': 'Русский язык'},
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English', 'native': 'English'},
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showBack: false,
      bottom: PrimaryButton(
        label: 'Davom etish',
        onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Tilni tanlang', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Ilova tilini tanlang, keyinchalik buni sozlamalardan o\'zgartirishingiz mumkin',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 28),
          ..._languages.map((lang) {
            final isSelected = _selected == lang['code'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _selected = lang['code']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.pink : AppColors.cardBorder,
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang['name']!, style: AppTextStyles.bodyMedium),
                            Text(lang['native']!, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.pink : AppColors.cardBorder,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.pink : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
