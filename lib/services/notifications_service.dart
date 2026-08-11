import 'api_client.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'info',
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        type: json['type']?.toString() ?? 'info',
        isRead: json['isRead'] == true,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

/// /notifications endpointlari (M-15).
class NotificationsService {
  final _api = ApiClient.instance;

  Future<(List<AppNotification>, int)> getNotifications() async {
    final data = await _api.get('/notifications');
    final list = (data['notifications'] as List? ?? [])
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
    final unread = (data['unreadCount'] as num?)?.toInt() ?? 0;
    return (list, unread);
  }

  Future<void> markAsRead(String id) async {
    await _api.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.patch('/notifications/read-all');
  }
}
