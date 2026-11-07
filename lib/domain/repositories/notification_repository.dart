import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(int userId);
  Future<void> markAsRead(int notificationId);
  Future<void> clearAll(int userId);
}
