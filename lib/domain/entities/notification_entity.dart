class NotificationEntity {
  final int id;
  final int userId;
  final String type; // 'activity', 'system', 'bot', 'shop', 'direct_message'
  final String title;
  final String message;
  final String avatarUrl;
  final bool isRead;
  final String timestampLabel;
  final String createdAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.avatarUrl,
    required this.isRead,
    required this.timestampLabel,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    String? avatarUrl,
    bool? isRead,
    String? timestampLabel,
    String? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isRead: isRead ?? this.isRead,
      timestampLabel: timestampLabel ?? this.timestampLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
