import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Color _parseColor(String? hex, Color fallback) {
  if (hex == null || hex.isEmpty) return fallback;
  var h = hex.replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? fallback : Color(value);
}

class Course {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final int lessonCount;
  final bool isPro;
  final bool isLocked;

  const Course({
    required this.id,
    required this.title,
    this.description = '',
    required this.icon,
    required this.color,
    required this.lessonCount,
    this.isPro = false,
    this.isLocked = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        icon: json['icon']?.toString() ?? '📚',
        color: _parseColor(json['color']?.toString(), AppColors.pink),
        lessonCount: (json['lessonCount'] as num?)?.toInt() ?? 0,
        isPro: json['isPro'] == true,
        isLocked: json['isLocked'] == true,
      );
}

class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String videoUrl;
  final int duration;
  final bool isPro;
  final bool isCompleted;
  final bool isLocked;

  const Lesson({
    required this.id,
    this.courseId = '',
    required this.title,
    this.content = '',
    this.videoUrl = '',
    this.duration = 0,
    this.isPro = false,
    this.isCompleted = false,
    this.isLocked = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['_id']?.toString() ?? '',
        courseId: json['courseId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        videoUrl: json['videoUrl']?.toString() ?? '',
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        isPro: json['isPro'] == true,
        isCompleted: json['isCompleted'] == true,
        isLocked: json['isLocked'] == true,
      );
}
