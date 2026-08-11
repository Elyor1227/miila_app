import '../models/tracker.dart';
import 'api_client.dart';

/// /tracker endpointlari — sikl kuzatuvi.
class TrackerService {
  final _api = ApiClient.instance;

  Future<TrackerToday?> getToday() async {
    final data = await _api.get('/tracker/today');
    final today = data['data'];
    if (today == null) return null;
    return TrackerToday.fromJson(today as Map<String, dynamic>);
  }

  Future<List<Cycle>> getCycles() async {
    final data = await _api.get('/tracker/cycles');
    return (data['cycles'] as List? ?? [])
        .map((c) => Cycle.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCycle({
    required DateTime startDate,
    required int cycleLength,
    String? notes,
  }) async {
    await _api.post('/tracker/cycles', body: {
      'startDate': startDate.toIso8601String(),
      'cycleLength': cycleLength,
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> addSymptoms({
    required DateTime date,
    List<String> items = const [],
    String mood = '',
    int painLevel = 0,
    String flowLevel = 'none',
    List<String> bodyParts = const [],
    String notes = '',
  }) async {
    await _api.post('/tracker/symptoms', body: {
      'date': date.toIso8601String(),
      'items': items,
      'mood': mood,
      'painLevel': painLevel,
      'flowLevel': flowLevel,
      'bodyParts': bodyParts,
      'notes': notes,
    });
  }
}
