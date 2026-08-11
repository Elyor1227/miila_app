import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/analytics_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/settings_tile.dart';

/// M-13 — Profil (real /auth/me va /analytics'ga ulangan)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _analyticsService = AnalyticsService();
  AnalyticsSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final summary = await _analyticsService.getSummary(range: 'month');
      if (mounted) setState(() => _summary = summary);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 22),
            _buildStats(context),
            const SizedBox(height: 18),
            _buildPremiumCard(context),
            const SizedBox(height: 18),
            _buildStreakCard(),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  SettingsTile(icon: Icons.language_rounded, title: 'Til', subtitle: 'O\'zbek', onTap: () {}),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Bildirishnomalar',
                    onTap: () => Navigator.of(context).pushNamed('/notification-settings'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Maxfiylik va xavfsizlik',
                    onTap: () => Navigator.of(context).pushNamed('/privacy'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.pin_outlined,
                    title: 'PIN-kod bilan himoya',
                    onTap: () => Navigator.of(context).pushNamed('/pin-code'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.card_membership_outlined,
                    title: 'Obuna boshqaruvi',
                    onTap: () => Navigator.of(context).pushNamed('/subscription'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Ma\'lumotlarni o\'chirish',
                    onTap: () => Navigator.of(context).pushNamed('/delete-data'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Yordam va aloqa',
                    onTap: () => Navigator.of(context).pushNamed('/help'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Ilova haqida',
                    onTap: () => Navigator.of(context).pushNamed('/about'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: Colors.redAccent,
              title: 'Chiqish',
              titleColor: Colors.redAccent,
              trailing: const SizedBox.shrink(),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user != null && user.name.isNotEmpty ? user.name : 'Foydalanuvchi';
    final subtitle = user?.email.isNotEmpty == true ? user!.email : (user?.phone ?? '');
    final initial = user?.initial ?? '?';
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initial, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ),
            if (user?.isPro == true)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.h4),
              if (subtitle.isNotEmpty) Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed('/profile/edit'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.ink),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final stats = [
      {'value': '${_summary?.streak ?? 0}', 'label': 'Kun faollik'},
      {'value': '${_summary?.completedLessons ?? 0}', 'label': 'Tugallangan dars'},
      {'value': '${_summary?.points ?? 0}', 'label': 'Ball'},
    ];
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/analytics'),
      child: Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: s == stats.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text(s['value']!, style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(s['label']!, style: AppTextStyles.caption, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE0B458), AppColors.gold]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Miila Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'Barcha kurslar, maslahatlar va tahlillarga ega bo\'ling',
                  style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.gold,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Sotib olish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    const days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final streak = _summary?.streak ?? 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.pink, size: 22),
              const SizedBox(width: 8),
              Text('Faollik seriyasi', style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            streak > 0
                ? '$streak kun ketma-ket · Ajoyib! Shunday davom eting'
                : 'Bugun belgi kiritib seriyani boshlang',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = i < (streak > 7 ? 7 : streak);
              return Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: active ? AppColors.pink : AppColors.blush,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: active ? Colors.white : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(days[i], style: AppTextStyles.caption),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
