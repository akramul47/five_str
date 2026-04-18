/// Notification model.
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? icon;
  final String? color;
  final bool isRead;
  final String? readAt;
  final String timeAgo;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.icon,
    this.color,
    this.isRead = false,
    this.readAt,
    this.timeAgo = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      timeAgo: json['time_ago'] as String? ?? '',
    );
  }
}

class NotificationStats {
  final int totalCount;
  final int unreadCount;
  final int readCount;

  const NotificationStats({
    this.totalCount = 0,
    this.unreadCount = 0,
    this.readCount = 0,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalCount: json['total_count'] as int? ?? 0,
      unreadCount: json['unread_count'] as int? ?? 0,
      readCount: json['read_count'] as int? ?? 0,
    );
  }
}
