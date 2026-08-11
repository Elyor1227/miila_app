import '../models/course.dart';
import 'api_client.dart';

/// /courses endpointlari.
class CoursesService {
  final _api = ApiClient.instance;

  Future<List<Course>> getCourses() async {
    final data = await _api.get('/courses');
    return (data['courses'] as List? ?? [])
        .map((c) => Course.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Kurs + darslari. Javob: {course, lessons}
  Future<(Course, List<Lesson>)> getCourseById(String id) async {
    final data = await _api.get('/courses/$id');
    final course = Course.fromJson(data['course'] as Map<String, dynamic>);
    final lessons = (data['lessons'] as List? ?? [])
        .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
        .toList();
    return (course, lessons);
  }

  Future<void> completeLesson(String courseId, String lessonId) async {
    await _api.post('/courses/$courseId/lessons/$lessonId/complete');
  }
}
