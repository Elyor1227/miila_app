import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/settings_tile.dart';

/// M-22 — PIN-kod himoyasi (real /auth/pin API'larga ulangan)
class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _authService = AuthService();

  Future<void> _togglePin(bool enable) async {
    if (enable) {
      _showSetPinSheet();
    } else {
      try {
        final userJson = await _authService.disablePin();
        if (!mounted) return;
        context.read<AuthProvider>().applyUser(userJson);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showSetPinSheet() {
    final controllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());
    bool loading = false;
    String? error;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blush,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yangi PIN-kod kiriting', style: AppTextStyles.h4),
              const SizedBox(height: 20),
              PinCodeBoxes(controllers: controllers, focusNodes: focusNodes),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Saqlash',
                showArrow: false,
                isLoading: loading,
                onPressed: () async {
                  final pin = controllers.map((c) => c.text).join();
                  if (pin.length < 4) {
                    setSheetState(() => error = '4 xonali PIN kiriting');
                    return;
                  }
                  setSheetState(() {
                    loading = true;
                    error = null;
                  });
                  try {
                    final userJson = await _authService.setPin(pin);
                    if (!context.mounted) return;
                    this.context.read<AuthProvider>().applyUser(userJson);
                    Navigator.of(sheetContext).pop();
                  } catch (e) {
                    setSheetState(() {
                      error = e.toString();
                      loading = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    try {
      final userJson = await _authService.updateSecuritySettings(biometricEnabled: value);
      if (!mounted) return;
      context.read<AuthProvider>().applyUser(userJson);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showAutoLockPicker() {
    const options = [1, 5, 15, 30];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blush,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avtomatik qulflash', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            for (final m in options)
              ListTile(
                title: Text('$m daqiqa', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  try {
                    final userJson = await _authService.updateSecuritySettings(autoLockMinutes: m);
                    if (!mounted) return;
                    context.read<AuthProvider>().applyUser(userJson);
                  } catch (_) {}
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final pinEnabled = user?.pinEnabled ?? false;

    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('PIN-kod', style: AppTextStyles.h4)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 18),
            Center(child: Text('PIN-kod himoyasi', style: AppTextStyles.h3)),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Ilovani 4 xonali PIN-kod bilan himoyalang',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: pinEnabled,
                    onChanged: _togglePin,
                    activeColor: AppColors.pink,
                    title: Text('PIN-kod himoyasi', style: AppTextStyles.bodyMedium),
                    subtitle: Text(pinEnabled ? 'Yoqilgan' : 'O\'chirilgan', style: AppTextStyles.caption),
                  ),
                  if (pinEnabled) ...[
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.pin_outlined,
                      title: 'PIN-kodni o\'zgartirish',
                      onTap: _showSetPinSheet,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: user?.biometricEnabled ?? false,
                      onChanged: _toggleBiometric,
                      activeColor: AppColors.pink,
                      title: Text('Face ID bilan ochish', style: AppTextStyles.bodyMedium),
                      subtitle: Text('Biometrik', style: AppTextStyles.caption),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.timer_outlined,
                      title: 'Avtomatik qulflash',
                      subtitle: '${user?.autoLockMinutes ?? 1} daqiqa',
                      onTap: _showAutoLockPicker,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
