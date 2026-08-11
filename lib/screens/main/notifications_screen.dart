import 'package:flutter/material.dart';

import '../../services/notifications_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// M-15 — Bildirishnomalar (real /notifications'ga ulangan)
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationsService();
  List<AppNotification> _items = const [];
  bool _loading = true;
  String _filter = 'all';

  static const _filters = [
    ('all', 'Hammasi'),
    ('unread', 'O\'qilmagan'),
    ('reminder', 'Eslatmalar'),
    ('achievement', 'Yutuqlar'),
  ];

  List<AppNotification> get _filtered => switch (_filter) {
        'unread' => _items.where((n) => !n.isRead).toList(),
        'reminder' => _items.where((n) => n.type == 'reminder').toList(),
        'achievement' => _items.where((n) => n.type == 'achievement').toList(),
        _ => _items,
      };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final (items, _) = await _service.getNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'reminder':
        return Icons.alarm_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'reminder':
        return AppColors.deep;
      case 'achievement':
        return AppColors.gold;
      case 'warning':
        return Colors.orange;
      default:
        return AppColors.pink;
    }
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        title: Text('Bildirishnomalar', style: AppTextStyles.h4),
        actions: [
          TextButton(
            onPressed: () async {
              await _service.markAllAsRead().catchError((_) {});
              _load();
            },
            child: Text('Hammasini o\'qish',
                style: AppTextStyles.caption.copyWith(color: AppColors.pink)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
          : Column(
              children: [
                // Filtr chiplari (M-02)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: _filters.map((f) {
                      final selected = _filter == f.$1;
                      final unread = _items.where((n) => !n.isRead).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.pink : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: selected ? AppColors.pink : AppColors.cardBorder),
                            ),
                            child: Text(
                              f.$1 == 'unread' && unread > 0 ? '${f.$2} $unread' : f.$2,
                              style: AppTextStyles.caption.copyWith(
                                color: selected ? Colors.white : AppColors.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text('Hozircha bildirishnomalar yo\'q', style: AppTextStyles.body),
          ],
        ),
      );
    }
    return RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.pink,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = _filtered[i];
                      return InkWell(
                        onTap: () async {
                          if (!n.isRead) {
                            await _service.markAsRead(n.id).catchError((_) {});
                            _load();
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: n.isRead ? AppColors.cardBorder : AppColors.pink.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _color(n.type).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_icon(n.type), size: 18, color: _color(n.type)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: AppTextStyles.bodyMedium),
                                    const SizedBox(height: 2),
                                    Text(n.message, style: AppTextStyles.caption),
                                    const SizedBox(height: 4),
                                    Text(_timeAgo(n.createdAt),
                                        style: AppTextStyles.caption.copyWith(fontSize: 10)),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
  }
}
