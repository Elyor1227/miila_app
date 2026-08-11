import 'package:flutter/material.dart';

import '../../models/tracker.dart';
import '../../services/tracker_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import 'day_detail_screen.dart';
import 'symptom_entry_screen.dart';

enum _DayType { none, period, fertile, ovulation }

/// M-09 — Kalendar (real /tracker/cycles va /tracker/today'ga ulangan)
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  static const _monthNames = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];
  static const _weekLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
  static const _assumedPeriodLength = 5;

  final _trackerService = TrackerService();
  List<Cycle> _cycles = const [];
  TrackerToday? _today;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _trackerService.getCycles(),
        _trackerService.getToday(),
      ]);
      if (!mounted) return;
      setState(() {
        _cycles = results[0] as List<Cycle>;
        _today = results[1] as TrackerToday?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Cycle? get _latestCycle {
    if (_cycles.isEmpty) return null;
    final sorted = [..._cycles]..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted.first;
  }

  _DayType _dayType(DateTime date) {
    for (final cycle in _cycles) {
      final start = DateTime(cycle.startDate.year, cycle.startDate.month, cycle.startDate.day);
      final dayDiff = date.difference(start).inDays;
      if (dayDiff < 0) continue;
      if (dayDiff < _assumedPeriodLength) return _DayType.period;
      final ovulationDay = cycle.cycleLength - 14;
      if (dayDiff == ovulationDay) return _DayType.ovulation;
      if (dayDiff >= ovulationDay - 4 && dayDiff <= ovulationDay) return _DayType.fertile;
    }
    return _DayType.none;
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final now = DateTime.now();
    final today = (now.year == _month.year && now.month == _month.month) ? now.day : -1;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.pink,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kalendar', style: AppTextStyles.h2),
                  _iconCircle(Icons.settings_outlined),
                ],
              ),
              const SizedBox(height: 20),
              _buildPhaseCard(),
              const SizedBox(height: 20),
              _buildMonthCard(firstWeekday, daysInMonth, today),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 24),
              Text('Bashorat', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              _buildForecast(),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Belgi qo\'shish',
                showArrow: false,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SymptomEntryScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: AppColors.ink),
    );
  }

  Widget _buildPhaseCard() {
    final phase = _today?.phase ?? 'Ma\'lumot yo\'q';
    final daysLeft = _today?.daysUntilNextPeriod ?? 0;
    final progress = _today != null && _today!.cycleLength > 0
        ? (_today!.cycleDay / _today!.cycleLength).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.luteal, Color(0xFF9B7EDE)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.toUpperCase(), style: AppTextStyles.label.copyWith(color: Colors.white70)),
                const SizedBox(height: 10),
                const Text(
                  'Keyingi menstruatsiyaga',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Tana harorati va kayfiyat o\'zgarishi mumkin',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$daysLeft', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    const Text('kun', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(int firstWeekday, int daysInMonth, int today) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.muted),
                onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
              ),
              Text('${_monthNames[_month.month - 1]} ${_month.year}', style: AppTextStyles.bodyMedium),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.muted),
                onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekLabels
                .map((d) => SizedBox(width: 32, child: Text(d, textAlign: TextAlign.center, style: AppTextStyles.caption)))
                .toList(),
          ),
          const SizedBox(height: 6),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: AppColors.pink)),
            )
          else
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
                final date = DateTime(_month.year, _month.month, dayNum);
                final type = _dayType(date);
                final isToday = dayNum == today;
                Color? bg;
                switch (type) {
                  case _DayType.period:
                    bg = AppColors.period;
                    break;
                  case _DayType.fertile:
                    bg = AppColors.follicular;
                    break;
                  case _DayType.ovulation:
                    bg = AppColors.ovulation;
                    break;
                  case _DayType.none:
                    bg = null;
                }
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DayDetailScreen(date: date)),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: AppColors.deep, width: 1.6) : null,
                    ),
                    child: Text(
                      '$dayNum',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: bg != null ? Colors.white : AppColors.ink,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    Widget dot(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption),
        ],
      );
    }

    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        dot(AppColors.period, 'Hayz'),
        dot(AppColors.follicular, 'Fertillik'),
        dot(AppColors.ovulation, 'Ovulyatsiya'),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${_monthNames[date.month - 1].substring(0, 3)}';
  }

  Widget _buildForecast() {
    final cycle = _latestCycle;
    final cycleLength = _today?.cycleLength ?? cycle?.cycleLength ?? 28;

    String nextPeriodLabel = 'Ma\'lumot yo\'q';
    String ovulationLabel = 'Ma\'lumot yo\'q';
    if (cycle != null) {
      final nextPeriod = cycle.startDate.add(Duration(days: cycleLength));
      final ovulation = cycle.startDate.add(Duration(days: cycleLength - 14));
      nextPeriodLabel = _formatDate(nextPeriod);
      ovulationLabel = _formatDate(ovulation);
    }

    final items = [
      {'title': 'Keyingi hayz', 'value': nextPeriodLabel, 'icon': Icons.water_drop_outlined, 'color': AppColors.period},
      {'title': 'Sikl uzunligi', 'value': '$cycleLength kun', 'icon': Icons.autorenew_rounded, 'color': AppColors.deep},
      {'title': 'Ovulyatsiya', 'value': ovulationLabel, 'icon': Icons.star_outline_rounded, 'color': AppColors.gold},
    ];
    return Row(
      children: items.map((item) {
        final isLast = item == items.last;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                const SizedBox(height: 8),
                Text(item['value'] as String, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(item['title'] as String, style: AppTextStyles.caption, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
