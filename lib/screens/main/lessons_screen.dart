import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../services/courses_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/course_icon.dart';
import 'course_detail_screen.dart';

/// M-03 — Darslar (qidiruv + davom etish + barcha kurslar)
class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final _coursesService = CoursesService();
  final _searchController = TextEditingController();
  List<Course> _courses = const [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final courses = await _coursesService.getCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Course> get _filtered => _query.isEmpty
      ? _courses
      : _courses.where((c) => c.title.toLowerCase().contains(_query)).toList();

  void _open(Course course) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.pink));
    }
    final first = _courses.isNotEmpty ? _courses.first : null;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.pink,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Darslar', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text('Bilimingizni oshiring, o\'zingizni asrang', style: AppTextStyles.caption),
            const SizedBox(height: 16),
            // Qidiruv (M-03)
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Dars yoki mavzu qidirish...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.muted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            // Davom etish kartasi (birinchi kurs)
            if (_query.isEmpty && first != null) ...[
              const SizedBox(height: 18),
              Text('DAVOM ETISH', style: AppTextStyles.label),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _open(first),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(first.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${first.lessonCount} ta dars',
                                style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BARCHA KURSLAR', style: AppTextStyles.label),
                Text('${_filtered.length} ta kurs', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 10),
            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text('Hech narsa topilmadi', style: AppTextStyles.body),
                ),
              )
            else
              ..._filtered.map((course) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: ListTile(
                      onTap: () => _open(course),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: course.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: CourseIcon(course.icon, size: 22)),
                      ),
                      title: Text(course.title, style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                        '${course.lessonCount} ta dars${course.isPro ? '  ·  Premium' : ''}',
                        style: AppTextStyles.caption,
                      ),
                      trailing: course.isLocked
                          ? const Icon(Icons.lock_outline_rounded,
                              size: 18, color: AppColors.gold)
                          : const Icon(Icons.chevron_right, color: AppColors.muted),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
