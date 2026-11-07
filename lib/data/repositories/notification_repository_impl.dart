import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final LocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications(int userId) async {
    return await localDataSource.getNotifications(userId);
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await localDataSource.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> clearAll(int userId) async {
    // Clear or mark all read
  }
}

