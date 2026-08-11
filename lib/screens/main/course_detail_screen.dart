import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../services/api_client.dart';
import '../../services/courses_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/course_icon.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

/// M-04 — Kurs detali / M-17 — Premium kurs (qulflangan variant)
class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _service = CoursesService();
  List<Lesson> _lessons = const [];
  bool _loading = true;
  bool _proLocked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final (_, lessons) = await _service.getCourseById(widget.course.id);
      if (!mounted) return;
      setState(() {
        _lessons = lessons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _proLocked = e is ApiException && e.statusCode == 403;
        _loading = false;
      });
    }
  }

  Future<void> _openLesson(Lesson lesson, int index) async {
    if (lesson.isLocked) {
      Navigator.of(context).pushNamed('/payment');
      return;
    }
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          course: widget.course,
          lesson: lesson,
          isLastLesson: index == _lessons.length - 1,
        ),
      ),
    );
    if (changed == true) _load();
  }

  int get _completedCount => _lessons.where((l) => l.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    // M-17: Pro kurs va foydalanuvchi Premium emas
    final premiumView = _proLocked || (widget.course.isLocked && _lessons.isEmpty && !_loading);

    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text(widget.course.title, style: AppTextStyles.h4)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
            : premiumView
                ? _buildPremiumLocked()
                : _buildNormal(),
      ),
    );
  }

  // ── M-04: ochiq kurs ──

  Widget _buildNormal() {
    final course = widget.course;
    final total = _lessons.length;
    final progress = total > 0 ? _completedCount / total : 0.0;
    final allDone = total > 0 && _completedCount == total;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: course.color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: CourseIcon(course.icon, size: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('$total ta dars',
                            style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kurs progressi',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                  Text('$_completedCount / $total dars',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (widget.course.description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(widget.course.description, style: AppTextStyles.body),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('DARSLAR', style: AppTextStyles.label),
            Text('$_completedCount/$total tugatildi', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 10),
        if (_lessons.isEmpty)
          Text('Darslar tez orada qo\'shiladi', style: AppTextStyles.caption)
        else
          ...List.generate(_lessons.length, (i) {
            final lesson = _lessons[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: lesson.isCompleted ? AppColors.success.withOpacity(0.4) : AppColors.cardBorder,
                ),
              ),
              child: ListTile(
                onTap: () => _openLesson(lesson, i),
                leading: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: lesson.isCompleted
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: lesson.isCompleted
                      ? const Icon(Icons.check_rounded, size: 18, color: AppColors.success)
                      : lesson.isLocked
                          ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.gold)
                          : const Icon(Icons.play_arrow_rounded, size: 20, color: AppColors.pink),
                ),
                title: Text('${i + 1}. ${lesson.title}', style: AppTextStyles.bodyMedium),
                subtitle: Text(
                  '⏱ ${lesson.duration} daqiqa'
                  '${lesson.isCompleted ? '  ·  Tugatildi' : lesson.isPro ? '  ·  Premium' : ''}',
                  style: AppTextStyles.caption,
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
              ),
            );
          }),
        // Yakuniy test (M-04 pastki kartasi)
        if (_lessons.isNotEmpty) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: allDone
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(courseTitle: widget.course.title),
                      ),
                    )
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: allDone
                      ? AppColors.primaryGradient
                      : [AppColors.muted.withOpacity(0.5), AppColors.muted.withOpacity(0.4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yakuniy test',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(
                          allDone
                              ? '5 savol · barcha darslardan'
                              : 'Avval barcha darslarni tugating',
                          style: AppTextStyles.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── M-17: Premium qulflangan kurs ──

  Widget _buildPremiumLocked() {
    final course = widget.course;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF2A93B), Color(0xFFE8832A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(child: CourseIcon(course.icon, size: 30)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          size: 13, color: Color(0xFFE8832A)),
                      const SizedBox(width: 4),
                      Text('PREMIUM',
                          style: AppTextStyles.label
                              .copyWith(color: const Color(0xFFE8832A), fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('PREMIUM KURS', style: AppTextStyles.label.copyWith(color: const Color(0xFFE8832A))),
        const SizedBox(height: 6),
        Text(course.title, style: AppTextStyles.h2),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _chip(Icons.menu_book_rounded, '${course.lessonCount} dars'),
            _chip(Icons.schedule_rounded, '${course.lessonCount * 6} daqiqa'),
            _chip(Icons.lock_outline_rounded, 'Premium'),
          ],
        ),
        if (course.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(course.description, style: AppTextStyles.body.copyWith(height: 1.5)),
        ],
        const SizedBox(height: 20),
        Text('DARSLAR · QULFLANGAN', style: AppTextStyles.label),
        const SizedBox(height: 10),
        for (var i = 0; i < (course.lessonCount > 0 ? course.lessonCount : 4); i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2A93B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFE8832A)),
              ),
              title: Text('${i + 1}-dars', style: AppTextStyles.bodyMedium),
              subtitle: Text('⏱ 6 daqiqa  ·  Premium', style: AppTextStyles.caption),
              trailing: const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.muted),
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/payment'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Premiumga o\'ting', style: AppTextStyles.button),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
