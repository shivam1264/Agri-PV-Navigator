import '../core/errors/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/site_assessment.dart';

class SuitabilityRepository {
  final ApiClient _client = ApiClient();

  Future<SiteAssessment> getSuitability(String farmId) async {
    final cleanId = farmId.trim();
    if (cleanId.isEmpty || cleanId == 'draft' || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cleanId)) {
      throw ValidationException('Valid farm ID required for server suitability check.');
    }
    final response = await _client.get('/api/farms/$cleanId/suitability');
    final data = (response is Map && response['assessment'] is Map)
        ? response['assessment'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return SiteAssessment.fromJson(data);
  }

  Future<SiteAssessment> recalculateSuitability(String farmId) async {
    final cleanId = farmId.trim();
    if (cleanId.isEmpty || cleanId == 'draft' || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cleanId)) {
      throw ValidationException('Valid farm ID required for recalculating suitability.');
    }
    final response = await _client.post('/api/farms/$cleanId/suitability');
    final data = (response is Map && response['assessment'] is Map)
        ? response['assessment'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return SiteAssessment.fromJson(data);
  }
}
