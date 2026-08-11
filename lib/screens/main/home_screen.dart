import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/tip.dart';
import '../../models/tracker.dart';
import '../../services/courses_service.dart';
import '../../services/tips_service.dart';
import '../../services/tracker_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/course_icon.dart';
import '../../widgets/settings_tile.dart';
import 'course_detail_screen.dart';
import 'lessons_screen.dart';
import 'notifications_screen.dart';
import 'symptom_entry_screen.dart';

/// M-01 — Bosh sahifa
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _moodIndex = 1;

  final _moods = const [
    {'emoji': '😍', 'label': 'Zo\'r'},
    {'emoji': '🙂', 'label': 'Yaxshi'},
    {'emoji': '😐', 'label': 'O\'rtacha'},
    {'emoji': '😔', 'label': 'Charchoq'},
    {'emoji': '😣', 'label': 'Yomon'},
  ];

  final _trackerService = TrackerService();
  final _tipsService = TipsService();
  final _coursesService = CoursesService();

  TrackerToday? _today;
  DailyTip? _tip;
  List<Course> _courses = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _trackerService.getToday().catchError((_) => null),
      _tipsService.getToday().catchError((_) => null),
      _coursesService.getCourses().catchError((_) => <Course>[]),
    ]);
    if (!mounted) return;
    setState(() {
      _today = results[0] as TrackerToday?;
      _tip = results[1] as DailyTip?;
      _courses = (results[2] as List<Course>).take(2).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCycleCard(),
              const SizedBox(height: 16),
              _buildTipCard(),
              const SizedBox(height: 16),
              _buildMoodCard(),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'So\'nggi darslar',
                actionLabel: 'Barchasi',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: AppColors.blush,
                      appBar: AppBar(title: Text('Darslar', style: AppTextStyles.h4)),
                      body: const LessonsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildLessons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().user;
    final name = user != null && user.name.isNotEmpty ? user.name : 'Foydalanuvchi';
    final initial = user?.initial ?? 'M';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xayrli kun', style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text('Salom, $name!', style: AppTextStyles.h2),
          ],
        ),
        Row(
          children: [
            _iconCircle(
              Icons.notifications_none_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initial, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconCircle(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }

  Widget _buildCycleCard() {
    final cycleDay = _today?.cycleDay ?? 1;
    final phase = _today?.phase ?? 'Follikulyar faza';
    final daysLeft = _today?.daysUntilNextPeriod ?? 0;
    final cycleLength = _today?.cycleLength ?? 28;
    final progress = cycleLength > 0 ? (cycleDay / cycleLength).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pink, AppColors.deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('JORIY SIKL', style: AppTextStyles.label.copyWith(color: Colors.white70)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        phase,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('$cycleDay', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
                Text('Joriy kun', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
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
                    Text('$daysLeft', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
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

  Widget _buildTipCard() {
    final tipText = _tip?.content ?? 'Hayz davrida gigiyenaga e\'tibor bering';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            child: Text(_tip?.emoji ?? '💡', style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KUNLIK TIBBIY MASLAHAT', style: AppTextStyles.label.copyWith(color: AppColors.gold)),
                const SizedBox(height: 4),
                Text(tipText, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard() {
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
          Text('Bugun o\'zingni qanday his qilyapsan?', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_moods.length, (i) {
              final selected = i == _moodIndex;
              return GestureDetector(
                onTap: () => setState(() => _moodIndex = i),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.pink.withOpacity(0.12) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: AppColors.pink, width: 1.6) : null,
                      ),
                      child: Text(_moods[i]['emoji']!, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: 6),
                    Text(_moods[i]['label']!, style: AppTextStyles.caption),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SymptomEntryScreen()),
            ),
            child: Row(
              children: [
                Text('Batafsil belgilash', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.pink)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 14, color: AppColors.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessons(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: AppColors.pink)),
      );
    }
    if (_courses.isEmpty) {
      return Text('Hozircha darslar mavjud emas', style: AppTextStyles.caption);
    }
    return Row(
      children: _courses.map((course) {
        return Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
            ),
            child: Container(
              margin: EdgeInsets.only(right: course == _courses.first ? 12 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: course.color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                    child: Center(child: CourseIcon(course.icon, size: 17)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${course.lessonCount} ta dars',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
