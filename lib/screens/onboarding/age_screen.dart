import 'package:flutter/material.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// R-08 — Yoshingiz nechida?
class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int _selectedAge = 22;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: _selectedAge - 10);

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottom: PrimaryButton(
        label: 'Davom etish',
        onPressed: () {
          OnboardingData.instance.age = _selectedAge;
          Navigator.of(context).pushNamed('/last-period');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Yoshingiz nechida?', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Bu ma\'lumot sikl bashoratini aniqroq hisoblashga yordam beradi',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 56,
              perspective: 0.003,
              diameterRatio: 1.4,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (i) => setState(() => _selectedAge = i + 10),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 71,
                builder: (context, i) {
                  final age = i + 10;
                  final isSelected = age == _selectedAge;
                  return Center(
                    child: Text(
                      '$age',
                      style: isSelected
                          ? AppTextStyles.h1.copyWith(color: AppColors.pink)
                          : AppTextStyles.h3.copyWith(color: AppColors.muted.withOpacity(0.5)),
                    ),
                  );
                },
              ),
            ),
          ),
          Center(child: Text('yosh', style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
