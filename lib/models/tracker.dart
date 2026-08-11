class TrackerToday {
  final int cycleDay;
  final int daysUntilNextPeriod;
  final int cycleLength;
  final DateTime? cycleStartDate;
  final SymptomEntry? todaySymptoms;

  const TrackerToday({
    required this.cycleDay,
    required this.daysUntilNextPeriod,
    required this.cycleLength,
    this.cycleStartDate,
    this.todaySymptoms,
  });

  /// Sikl fazasi kun raqamidan hisoblanadi (backend faza yubormaydi).
  String get phase {
    if (cycleDay <= 5) return 'Hayz davri';
    final ovulationDay = cycleLength - 14;
    if (cycleDay == ovulationDay) return 'Ovulyatsiya';
    if (cycleDay >= ovulationDay - 4 && cycleDay < ovulationDay) return 'Fertil oyna';
    if (cycleDay > ovulationDay) return 'Lyuteal faza';
    return 'Follikulyar faza';
  }

  factory TrackerToday.fromJson(Map<String, dynamic> json) => TrackerToday(
        cycleDay: (json['dayOfCycle'] as num?)?.toInt() ?? 1,
        daysUntilNextPeriod: (json['daysUntilNext'] as num?)?.toInt() ?? 0,
        cycleLength: (json['cycleLength'] as num?)?.toInt() ?? 28,
        cycleStartDate: json['cycleStartDate'] == null
            ? null
            : DateTime.tryParse(json['cycleStartDate'].toString()),
        todaySymptoms: json['todaySymptoms'] == null
            ? null
            : SymptomEntry.fromJson(json['todaySymptoms'] as Map<String, dynamic>),
      );
}

class SymptomEntry {
  final DateTime date;
  final List<String> items;
  final String mood;
  final int painLevel;
  final String flowLevel;
  final List<String> bodyParts;
  final String notes;

  const SymptomEntry({
    required this.date,
    this.items = const [],
    this.mood = '',
    this.painLevel = 0,
    this.flowLevel = 'none',
    this.bodyParts = const [],
    this.notes = '',
  });

  factory SymptomEntry.fromJson(Map<String, dynamic> json) => SymptomEntry(
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        items: (json['items'] as List?)?.cast<String>() ?? const [],
        mood: json['mood']?.toString() ?? '',
        painLevel: (json['painLevel'] as num?)?.toInt() ?? 0,
        flowLevel: json['flowLevel']?.toString() ?? 'none',
        bodyParts: (json['bodyParts'] as List?)?.cast<String>() ?? const [],
        notes: json['notes']?.toString() ?? '',
      );
}

class Cycle {
  final String id;
  final DateTime startDate;
  final int cycleLength;
  final List<SymptomEntry> symptoms;

  const Cycle({
    this.id = '',
    required this.startDate,
    required this.cycleLength,
    this.symptoms = const [],
  });

  factory Cycle.fromJson(Map<String, dynamic> json) => Cycle(
        id: json['_id']?.toString() ?? '',
        startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
        cycleLength: (json['cycleLength'] as num?)?.toInt() ?? 28,
        symptoms: (json['symptoms'] as List?)
                ?.map((s) => SymptomEntry.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
