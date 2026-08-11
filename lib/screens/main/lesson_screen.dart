import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/course.dart';
import '../../services/api_client.dart';
import '../../services/courses_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import 'quiz_screen.dart';

/// M-05 — Video dars (real /courses/:id/lessons/:id'ga ulangan)
class LessonScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;
  final bool isLastLesson;

  const LessonScreen({
    super.key,
    required this.course,
    required this.lesson,
    this.isLastLesson = false,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _service = CoursesService();
  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _completing = false;
  late bool _completed = widget.lesson.isCompleted;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  String? get _videoUrl {
    final lesson = widget.lesson;
    if (lesson.videoUrl.isEmpty) return null;
    if (lesson.videoUrl.startsWith('http')) return lesson.videoUrl;
    // Nisbiy /api yo'li — token query orqali (protectVideo)
    final base = ApiClient.baseUrl.replaceFirst(RegExp(r'/api$'), '');
    final token = ApiClient.instance.token;
    return '$base${lesson.videoUrl}?token=$token';
  }

  Future<void> _initVideo() async {
    final url = _videoUrl;
    if (url == null) return;
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _video = controller;
        _videoReady = true;
      });
    } catch (_) {
      // Video yuklanmasa placeholder ko'rsatiladi
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    try {
      await _service.completeLesson(widget.course.id, widget.lesson.id);
      if (!mounted) return;
      setState(() => _completed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dars tugallandi! 🎉')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  /// Kontentdan "Asosiy nuqtalar"ni ajratadi: har bir yangi qatordagi gap
  List<String> get _keyPoints {
    final lines = widget.lesson.content
        .split(RegExp(r'[\n•]'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length <= 1) return const [];
    return lines.skip(1).take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SafeArea(
        child: Column(
          children: [
            // Video player qismi (Figma: to'q binafsha fon)
            Container(
              width: double.infinity,
              color: const Color(0xFF3D2E52),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(_completed),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('VIDEO DARS',
                            style: AppTextStyles.label.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _videoReady && _video != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_video!),
                              if (!_video!.value.isPlaying)
                                InkWell(
                                  onTap: () => setState(() => _video!.play()),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded,
                                        size: 36, color: Color(0xFF3D2E52)),
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () => setState(() => _video!.pause()),
                                  child: Container(color: Colors.transparent),
                                ),
                            ],
                          )
                        : Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  size: 36, color: Color(0xFF3D2E52)),
                            ),
                          ),
                  ),
                  if (_videoReady && _video != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: VideoProgressIndicator(
                        _video!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.pink,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
            // Dars mazmuni
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    widget.isLastLesson ? 'OXIRGI DARS' : 'DARS',
                    style: AppTextStyles.label.copyWith(color: AppColors.pink),
                  ),
                  const SizedBox(height: 6),
                  Text(lesson.title, style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  Text(
                    '⏱ ${lesson.duration} daqiqa  ·  ${widget.course.title}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 18),
                  if (lesson.content.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('QISQACHA MAZMUN',
                              style: AppTextStyles.label.copyWith(color: AppColors.pink)),
                          const SizedBox(height: 8),
                          Text(
                            lesson.content.split(RegExp(r'[\n•]')).first.trim(),
                            style: AppTextStyles.body.copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  if (_keyPoints.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Asosiy nuqtalar', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 10),
                          for (final point in _keyPoints)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_rounded,
                                      size: 16, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(point, style: AppTextStyles.body)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (_completed)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7EC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dars tugallangan!',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(color: AppColors.success)),
                                Text(
                                  widget.isLastLesson
                                      ? 'Endi bilimingizni sinab ko\'ring'
                                      : 'Keyingi darsga o\'tishingiz mumkin',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    PrimaryButton(
                      label: 'Darsni tugatdim',
                      showArrow: false,
                      isLoading: _completing,
                      onPressed: _complete,
                    ),
                  if (_completed && widget.isLastLesson) ...[
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Bilimingizni tekshiring',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(courseTitle: widget.course.title),
                        ),
                      ),
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
