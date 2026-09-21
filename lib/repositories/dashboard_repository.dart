import '../core/network/api_client.dart';
import '../models/dashboard_summary.dart';

class DashboardRepository {
  final ApiClient _client = ApiClient();

  Future<DashboardSummary> getSummary() async {
    final response = await _client.get('/api/dashboard/summary');
    final data = (response is Map && response['summary'] is Map)
        ? response['summary'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});
    return DashboardSummary.fromJson(data);
  }
}
