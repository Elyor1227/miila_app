import 'package:flutter/material.dart';

import '../../models/tracker.dart';
import '../../services/tracker_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'symptom_entry_screen.dart';

/// M-10 — Kun tafsiloti (sikldagi belgilangan ma'lumotlarni ko'rsatadi)
class DayDetailScreen extends StatefulWidget {
  final DateTime date;
  const DayDetailScreen({super.key, required this.date});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final _trackerService = TrackerService();
  SymptomEntry? _entry;
  int? _cycleDay;
  bool _loading = true;

  static const _monthNames = [
    'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
    'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
  ];
  static const _weekdays = [
    'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba',
  ];
  static const _moodLabels = {
    'happy': 'Yaxshi',
    'neutral': 'O\'rtacha',
    'sad': 'Yomon',
    'anxious': 'Xavotir',
    'angry': 'Jahldor',
    'tired': 'Charchoq',
  };
  static const _flowLabels = {
    'none': 'Yo\'q',
    'light': 'Kam',
    'medium': 'O\'rta',
    'heavy': 'Ko\'p',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cycles = await _trackerService.getCycles();
      SymptomEntry? found;
      int? cycleDay;
      final target = _dayOnly(widget.date);

      for (final cycle in cycles) {
        for (final s in cycle.symptoms) {
          if (_dayOnly(s.date) == target) {
            found = s;
            break;
          }
        }
        final start = _dayOnly(cycle.startDate);
        final diff = target.difference(start).inDays;
        if (diff >= 0 && diff < cycle.cycleLength) {
          cycleDay = diff + 1;
        }
      }

      if (!mounted) return;
      setState(() {
        _entry = found;
        _cycleDay = cycleDay;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _phase {
    if (_cycleDay == null) return '';
    if (_cycleDay! <= 5) return 'Hayz davri';
    return 'Folikulyar faza';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.date;
    final title = '${d.day}-${_monthNames[d.month - 1]}, ${_weekdays[d.weekday - 1]}';

    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        title: Text('Kun tafsiloti', style: AppTextStyles.h4),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.pink),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SymptomEntryScreen()))
                .then((_) => _load()),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Sana kartasi
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
                        Text(title, style: AppTextStyles.h3),
                        if (_cycleDay != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7EC),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '● Sikl · $_cycleDay-kun · $_phase',
                              style: AppTextStyles.caption.copyWith(color: AppColors.success),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_entry == null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.event_note_outlined, size: 40, color: AppColors.muted),
                          const SizedBox(height: 10),
                          Text('Bu kun uchun belgi kiritilmagan', style: AppTextStyles.body),
                        ],
                      ),
                    )
                  else
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
                          Text('BELGILANGAN', style: AppTextStyles.label),
                          const SizedBox(height: 14),
                          _row(
                            Icons.water_drop_outlined,
                            const Color(0xFF58B7D6),
                            'Oqim',
                            _flowLabels[_entry!.flowLevel] ?? '—',
                          ),
                          const Divider(height: 22),
                          _row(
                            Icons.mood_rounded,
                            AppColors.gold,
                            'Kayfiyat',
                            _moodLabels[_entry!.mood] ?? '—',
                          ),
                          if (_entry!.painLevel > 0) ...[
                            const Divider(height: 22),
                            _row(
                              Icons.bolt_rounded,
                              AppColors.period,
                              'Og\'riq darajasi',
                              '${_entry!.painLevel}/10',
                            ),
                          ],
                          if (_entry!.bodyParts.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text('Og\'rigan joylar', style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _entry!.bodyParts
                                  .map((p) => _tag(p, AppColors.period))
                                  .toList(),
                            ),
                          ],
                          if (_entry!.items.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text('Boshqa belgilar', style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _entry!.items.map((s) => _tag(s, AppColors.deep)).toList(),
                            ),
                          ],
                          if (_entry!.notes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text('Izoh', style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 6),
                            Text(_entry!.notes, style: AppTextStyles.body),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const SymptomEntryScreen()))
                        .then((_) => _load()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pink,
                      side: const BorderSide(color: AppColors.pink),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(_entry == null ? 'Belgi kiritish' : 'Yozuvni tahrirlash'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _row(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.blush,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(value, style: AppTextStyles.caption.copyWith(color: AppColors.deep)),
        ),
      ],
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
