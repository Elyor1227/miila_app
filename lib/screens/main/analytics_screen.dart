import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// M-12 — Tahlillar (real /analytics/summary'ga ulangan)
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _service = AnalyticsService();
  AnalyticsSummary? _summary;
  bool _loading = true;
  String _range = 'week';

  static const _ranges = [('week', 'Hafta'), ('month', 'Oy'), ('quarter', '3 oy')];
  static const _moodEmoji = {
    'happy': '🙂',
    'neutral': '😐',
    'sad': '😔',
    'anxious': '😟',
    'angry': '😠',
    'tired': '😪',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await _service.getSummary(range: _range);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Tahlillar', style: AppTextStyles.h4)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.pink,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Davr tanlash (Hafta / Oy / 3 oy)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: _ranges.map((r) {
                    final selected = _range == r.$1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _range = r.$1);
                          _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.pink : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            r.$2,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: selected ? Colors.white : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: AppColors.pink)),
                )
              else ...[
                // Statistika kartalari
                Row(
                  children: [
                    _statCard('🔥', '${s?.streak ?? 0}', 'Kun ketma-ket'),
                    const SizedBox(width: 10),
                    _statCard('📝', '${s?.activeDaysInRange ?? 0}', 'Faol kun'),
                    const SizedBox(width: 10),
                    _statCard('⭐', '${s?.points ?? 0}', 'Ball'),
                  ],
                ),
                const SizedBox(height: 16),
                // Belgilar chastotasi
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Belgilar chastotasi', style: AppTextStyles.bodyMedium),
                          Text('Bu davrda', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if ((s?.symptomFrequency ?? []).isEmpty)
                        Text('Hozircha belgilar kiritilmagan', style: AppTextStyles.caption)
                      else
                        ...(() {
                          final list = s!.symptomFrequency.take(5).toList();
                          final maxDays =
                              list.map((f) => f.days).fold(1, (a, b) => a > b ? a : b);
                          return list.map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(f.name, style: AppTextStyles.caption),
                                        Text('${f.days} kun',
                                            style: AppTextStyles.caption
                                                .copyWith(color: AppColors.pink)),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: f.days / maxDays,
                                        minHeight: 7,
                                        backgroundColor: AppColors.blush,
                                        valueColor:
                                            const AlwaysStoppedAnimation(AppColors.pink),
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        })(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Kayfiyat dinamikasi
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kayfiyat dinamikasi', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 14),
                      if ((s?.moodTrend ?? []).isEmpty)
                        Text('Kayfiyat hali belgilanmagan', style: AppTextStyles.caption)
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: s!.moodTrend.reversed.take(14).toList().reversed.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Column(
                                  children: [
                                    Text(_moodEmoji[m.mood] ?? '😐',
                                        style: const TextStyle(fontSize: 22)),
                                    const SizedBox(height: 4),
                                    Text('${m.date.day}/${m.date.month}',
                                        style: AppTextStyles.caption.copyWith(fontSize: 10)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Darslar
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s?.completedLessons ?? 0} ta dars tugallangan',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            Text('Shunday davom eting!',
                                style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.h3),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
