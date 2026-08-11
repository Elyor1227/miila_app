class DailyTip {
  final String content;
  final String emoji;
  final String category;

  const DailyTip({required this.content, required this.emoji, this.category = ''});

  factory DailyTip.fromJson(Map<String, dynamic> json) => DailyTip(
        content: json['content']?.toString() ?? '',
        emoji: json['emoji']?.toString() ?? '💡',
        category: json['category']?.toString() ?? '',
      );
}
