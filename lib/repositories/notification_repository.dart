import '../core/network/api_client.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  final ApiClient _client = ApiClient();

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _client.get('/api/notifications');
    if (response is List) {
      return response.map((n) => NotificationItem.fromJson(n as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('/api/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.patch('/api/notifications/read-all');
  }
}
