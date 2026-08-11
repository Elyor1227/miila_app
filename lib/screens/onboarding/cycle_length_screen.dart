import 'package:flutter/material.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

/// R-10 — Sikl va hayz davomiyligi
class CycleLengthScreen extends StatefulWidget {
  const CycleLengthScreen({super.key});

  @override
  State<CycleLengthScreen> createState() => _CycleLengthScreenState();
}

class _CycleLengthScreenState extends State<CycleLengthScreen> {
  int _cycleLength = 28;
  int _periodLength = 5;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottom: PrimaryButton(
        label: 'Davom etish',
        onPressed: () {
          OnboardingData.instance.cycleLength = _cycleLength;
          OnboardingData.instance.periodLength = _periodLength;
          Navigator.of(context).pushNamed('/ready');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Sikl va hayz davomiyligi', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'O\'rtacha davomiylikni bilmasangiz, standart qiymatni qoldiring',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 28),
          StepperField(
            label: 'Sikl uzunligi',
            valueLabel: '$_cycleLength kun',
            onIncrement: () => setState(() => _cycleLength = (_cycleLength + 1).clamp(21, 45)),
            onDecrement: () => setState(() => _cycleLength = (_cycleLength - 1).clamp(21, 45)),
          ),
          const SizedBox(height: 16),
          StepperField(
            label: 'Hayz davomiyligi',
            valueLabel: '$_periodLength kun',
            onIncrement: () => setState(() => _periodLength = (_periodLength + 1).clamp(2, 10)),
            onDecrement: () => setState(() => _periodLength = (_periodLength - 1).clamp(2, 10)),
          ),
        ],
      ),
    );
  }
}
