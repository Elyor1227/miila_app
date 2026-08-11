import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// M-19 — Bildirishnoma sozlamalari (real PATCH /auth/notification-settings)
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _authService = AuthService();
  late Map<String, bool> _settings;

  static const _sections = [
    (
      'SIKL ESLATMALARI',
      [
        ('periodStart', 'Hayz boshlanishi', '2 kun oldin eslatamiz'),
        ('ovulation', 'Ovulyatsiya kuni', 'Eng fertil kunlar'),
        ('fertileWindow', 'Fertil davr', 'Davr boshlanishi'),
      ]
    ),
    (
      'SOG\'LIQ',
      [
        ('medicine', 'Dori va vitaminlar', 'Kunlik qabul'),
        ('water', 'Suv ichish', 'Kun davomida'),
        ('dailySymptom', 'Kunlik belgi kiritish', 'Har kuni eslatma'),
      ]
    ),
    (
      'KONTENT',
      [
        ('newLessons', 'Yangi darslar', 'Kurs yangiliklari'),
        ('dailyTip', 'Kunlik tibbiy maslahat', 'Har kuni 1 ta'),
      ]
    ),
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _settings = Map<String, bool>.from(user?.notificationSettings.toJson() ?? {});
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _settings[key] = value);
    try {
      final userJson = await _authService.updateNotificationSettings({key: value});
      if (!mounted) return;
      context.read<AuthProvider>().applyUser(userJson);
    } catch (e) {
      if (!mounted) return;
      setState(() => _settings[key] = !value);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Bildirishnomalar', style: AppTextStyles.h4)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            for (final (title, items) in _sections) ...[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 10),
                child: Text(title, style: AppTextStyles.label),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        value: _settings[items[i].$1] ?? false,
                        onChanged: (v) => _toggle(items[i].$1, v),
                        activeColor: AppColors.pink,
                        title: Text(items[i].$2, style: AppTextStyles.bodyMedium),
                        subtitle: Text(items[i].$3, style: AppTextStyles.caption),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
