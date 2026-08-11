import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/tracker_service.dart';
import '../../state/onboarding_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

/// R-13 — Hammasi tayyor! (sikl ma'lumotini /tracker/cycles'ga yuboradi)
class ReadyScreen extends StatefulWidget {
  const ReadyScreen({super.key});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  final _trackerService = TrackerService();
  bool _loading = false;
  String? _error;

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = OnboardingData.instance;
      await _trackerService.createCycle(
        startDate: data.lastPeriodDate,
        cycleLength: data.cycleLength,
        notes: 'Hayz davomiyligi: ${data.periodLength} kun',
      );
      // Yoshdan taxminiy tug'ilgan sana (R-08)
      await AuthService()
          .updateProfile(birthDate: DateTime(DateTime.now().year - data.age, 1, 1))
          .catchError((_) => <String, dynamic>{});
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showBack: false,
      bottom: PrimaryButton(label: 'Boshlash', isLoading: _loading, onPressed: _start),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 32),
          Text('Hammasi tayyor!', style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Sizning shaxsiy profilingiz tayyor.\nEndi Miila bilan sog\'lig\'ingizni kuzatishni boshlashingiz mumkin',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
