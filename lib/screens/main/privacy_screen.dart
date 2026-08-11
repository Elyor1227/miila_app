import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/settings_tile.dart';

/// M-20 — Maxfiylik va xavfsizlik (real API'larga ulangan)
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _authService = AuthService();
  int _sessionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _authService.getSessions();
      if (mounted) setState(() => _sessionCount = sessions.length);
    } catch (_) {}
  }

  Future<void> _togglePrivacy({bool? anonymousMode, bool? shareAnalytics}) async {
    try {
      final userJson = await _authService.updatePrivacySettings(
        anonymousMode: anonymousMode,
        shareAnalytics: shareAnalytics,
      );
      if (!mounted) return;
      context.read<AuthProvider>().applyUser(userJson);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await _authService.exportData();
      if (!mounted) return;
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.blush,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ma\'lumotlaringiz (JSON)', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(jsonStr, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: jsonStr));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nusxalandi')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Nusxalash'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showSessions() async {
    try {
      final sessions = await _authService.getSessions();
      if (!mounted) return;
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
              Text('Faol sessiyalar', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              if (sessions.isEmpty)
                Text('Faol sessiyalar topilmadi', style: AppTextStyles.body)
              else
                ...sessions.take(6).map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.devices_rounded, size: 18, color: AppColors.pink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s['deviceInfo']?.toString() ?? 'Qurilma',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                            onPressed: () async {
                              await _authService.revokeSession(s['_id'].toString()).catchError((_) {});
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                              _loadSessions();
                            },
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final privacy = user?.privacySettings;

    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Maxfiylik va xavfsizlik', style: AppTextStyles.h4)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('MAXFIYLIK', style: AppTextStyles.label),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: privacy?.anonymousMode ?? false,
                    onChanged: (v) => _togglePrivacy(anonymousMode: v),
                    activeColor: AppColors.pink,
                    title: Text('Anonim rejim', style: AppTextStyles.bodyMedium),
                    subtitle: Text('Profilingiz boshqalarga ko\'rinmaydi', style: AppTextStyles.caption),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    value: privacy?.shareAnalytics ?? false,
                    onChanged: (v) => _togglePrivacy(shareAnalytics: v),
                    activeColor: AppColors.pink,
                    title: Text('Ma\'lumotlar bilan bo\'lishish', style: AppTextStyles.bodyMedium),
                    subtitle: Text('Tahlil uchun anonim tarzda', style: AppTextStyles.caption),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('XAVFSIZLIK', style: AppTextStyles.label),
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
                    icon: Icons.pin_outlined,
                    title: 'PIN-kod bilan himoya',
                    subtitle: (user?.pinEnabled ?? false) ? 'Yoqilgan' : 'O\'chirilgan',
                    onTap: () => Navigator.of(context).pushNamed('/pin-code'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Parolni o\'zgartirish',
                    subtitle: 'Profil tahriridan',
                    onTap: () => Navigator.of(context).pushNamed('/profile/edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('MA\'LUMOTLAR', style: AppTextStyles.label),
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
                    icon: Icons.devices_rounded,
                    title: 'Faol sessiyalar',
                    subtitle: '$_sessionCount qurilma',
                    onTap: _showSessions,
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Ma\'lumotlarimni yuklab olish',
                    onTap: _exportData,
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
