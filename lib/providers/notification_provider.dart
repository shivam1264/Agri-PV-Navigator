import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repo.getNotifications();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to load: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markAsRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        final current = _notifications[idx];
        _notifications[idx] = NotificationItem(
          id: current.id,
          title: current.title,
          message: current.message,
          type: current.type,
          read: true,
          createdAt: current.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to mark read: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllAsRead();
      _notifications = _notifications.map((n) => NotificationItem(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        read: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to mark all read: $e');
    }
  }
}
