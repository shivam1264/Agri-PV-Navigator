import '../core/network/api_client.dart';
import '../models/agri_pv_design.dart';

class DesignRepository {
  final ApiClient _client = ApiClient();

  Future<List<AgriPvDesign>> getDesignsForFarm(String farmId) async {
    final cleanId = farmId.trim();
    if (cleanId.isEmpty || cleanId == 'draft' || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cleanId)) {
      return [];
    }
    final response = await _client.get('/api/farms/$cleanId/designs');
    List rawList = [];
    if (response is List) {
      rawList = response;
    } else if (response is Map && response['designs'] is List) {
      rawList = response['designs'] as List;
    }
    return rawList.map((d) => AgriPvDesign.fromJson(d as Map<String, dynamic>)).toList();
  }

  Future<AgriPvDesign> getDesignById(String id) async {
    final response = await _client.get('/api/designs/$id');
    final data = (response is Map && response['design'] is Map)
        ? response['design'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return AgriPvDesign.fromJson(data);
  }

  Future<AgriPvDesign> createDesign(String farmId, Map<String, dynamic> designData) async {
    final cleanId = farmId.trim();
    final response = await _client.post('/api/farms/$cleanId/designs', body: designData);
    final data = (response is Map && response['design'] is Map)
        ? response['design'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return AgriPvDesign.fromJson(data);
  }

  Future<AgriPvDesign> updateDesign(String id, Map<String, dynamic> updates) async {
    final response = await _client.patch('/api/designs/$id', body: updates);
    final data = (response is Map && response['design'] is Map)
        ? response['design'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return AgriPvDesign.fromJson(data);
  }

  Future<AgriPvDesign> calculateMetrics(String id, Map<String, dynamic> parameters) async {
    final response = await _client.post('/api/designs/$id/calculate', body: parameters);
    final data = (response is Map && response['design'] is Map)
        ? response['design'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return AgriPvDesign.fromJson(data);
  }

  Future<Map<String, dynamic>> getVisualizationConfig(String id) async {
    final response = await _client.get('/api/designs/$id/visualization-config');
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getShadowSimulation(
    String id, {
    String? month,
    int? day,
    int? hour,
  }) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (day != null) queryParams['day'] = day;
    if (hour != null) queryParams['hour'] = hour;

    final response = await _client.get(
      '/api/designs/$id/shadow-simulation',
      queryParams: queryParams,
    );
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getComparison(String id) async {
    final response = await _client.get('/api/designs/$id/comparison');
    return Map<String, dynamic>.from(response);
  }
}
