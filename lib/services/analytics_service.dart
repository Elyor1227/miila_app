import 'api_client.dart';

class SymptomFrequency {
  final String name;
  final int days;
  const SymptomFrequency({required this.name, required this.days});
}

class MoodPoint {
  final DateTime date;
  final String mood;
  final int painLevel;
  const MoodPoint({required this.date, required this.mood, required this.painLevel});
}

class AnalyticsSummary {
  final String range;
  final int streak;
  final int activeDaysInRange;
  final int completedLessons;
  final int points;
  final List<SymptomFrequency> symptomFrequency;
  final List<MoodPoint> moodTrend;

  const AnalyticsSummary({
    required this.range,
    required this.streak,
    required this.activeDaysInRange,
    required this.completedLessons,
    required this.points,
    required this.symptomFrequency,
    required this.moodTrend,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) => AnalyticsSummary(
        range: json['range']?.toString() ?? 'week',
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        activeDaysInRange: (json['activeDaysInRange'] as num?)?.toInt() ?? 0,
        completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
        points: (json['points'] as num?)?.toInt() ?? 0,
        symptomFrequency: (json['symptomFrequency'] as List? ?? [])
            .map((s) => SymptomFrequency(
                  name: s['name']?.toString() ?? '',
                  days: (s['days'] as num?)?.toInt() ?? 0,
                ))
            .toList(),
        moodTrend: (json['moodTrend'] as List? ?? [])
            .map((m) => MoodPoint(
                  date: DateTime.tryParse(m['date']?.toString() ?? '') ?? DateTime.now(),
                  mood: m['mood']?.toString() ?? '',
                  painLevel: (m['painLevel'] as num?)?.toInt() ?? 0,
                ))
            .toList(),
      );
}

/// /analytics endpointi (M-12, M-13 statistika).
class AnalyticsService {
  final _api = ApiClient.instance;

  Future<AnalyticsSummary> getSummary({String range = 'week'}) async {
    final data = await _api.get('/analytics/summary?range=$range');
    return AnalyticsSummary.fromJson(data['data'] as Map<String, dynamic>);
  }
}
