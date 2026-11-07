import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    required super.avatarUrl,
    required super.isRead,
    required super.timestampLabel,
    required super.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 1,
      userId: map['user_id'] is int ? map['user_id'] : int.tryParse(map['user_id'].toString()) ?? 1,
      type: map['type'] ?? 'system',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      isRead: (map['is_read'] == 1 || map['is_read'] == true),
      timestampLabel: map['timestamp_label'] ?? 'Baru saja',
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'avatar_url': avatarUrl,
      'is_read': isRead ? 1 : 0,
      'timestamp_label': timestampLabel,
      'created_at': createdAt,
    };
  }
}

