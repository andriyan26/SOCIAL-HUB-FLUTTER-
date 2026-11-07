import 'package:flutter/material.dart';
import 'package:social_hub/domain/entities/notification_entity.dart';
import 'package:social_hub/domain/repositories/notification_repository.dart';

class InboxProvider extends ChangeNotifier {
  final NotificationRepository notificationRepository;

  InboxProvider({required this.notificationRepository});

  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await notificationRepository.getNotifications(userId);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await notificationRepository.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}

