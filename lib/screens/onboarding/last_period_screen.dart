import 'package:flutter/material.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// R-09 — Oxirgi hayz qachon boshlandi?
class LastPeriodScreen extends StatefulWidget {
  const LastPeriodScreen({super.key});

  @override
  State<LastPeriodScreen> createState() => _LastPeriodScreenState();
}

class _LastPeriodScreenState extends State<LastPeriodScreen> {
  int _selectedDay = DateTime.now().day;
  final DateTime _month = DateTime.now();

  static const _weekLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday; // 1=Mon
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final monthNames = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];

    return OnboardingScaffold(
      bottom: PrimaryButton(
        label: 'Davom etish',
        onPressed: () {
          OnboardingData.instance.lastPeriodDate = DateTime(_month.year, _month.month, _selectedDay);
          Navigator.of(context).pushNamed('/cycle-length');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Oxirgi hayz qachon\nboshlandi?', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('Oxirgi hayzingiz boshlangan kunni belgilang', style: AppTextStyles.body),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text('${monthNames[_month.month - 1]} ${_month.year}', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _weekLabels
                      .map((d) => SizedBox(
                            width: 32,
                            child: Text(d, textAlign: TextAlign.center, style: AppTextStyles.caption),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daysInMonth + (firstWeekday - 1),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final dayNum = index - (firstWeekday - 2);
                    if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();
                    final isSelected = dayNum == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = dayNum),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.period : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$dayNum',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
