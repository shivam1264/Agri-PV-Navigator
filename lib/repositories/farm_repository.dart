import '../core/network/api_client.dart';
import '../models/farm.dart';

class FarmRepository {
  final ApiClient _client = ApiClient();

  Future<List<Farm>> getFarms({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _client.get('/api/farms', queryParams: queryParams);
    List rawList = [];
    if (response is List) {
      rawList = response;
    } else if (response is Map && response['farms'] is List) {
      rawList = response['farms'] as List;
    }
    return rawList.map((f) => Farm.fromJson(f as Map<String, dynamic>)).toList();
  }

  Future<Farm> getFarmById(String id) async {
    final response = await _client.get('/api/farms/$id');
    final data = (response is Map && response['farm'] is Map)
        ? response['farm'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return Farm.fromJson(data);
  }

  Future<Farm> createFarm({
    required String name,
    required String state,
    required String district,
    required double areaAcres,
    required String cropType,
    required double latitude,
    required double longitude,
    String? soilType,
    String? slope,
    String? irrigation,
    double? gridProximityKm,
    String? irrigationSource,
    double? electricityTariff,
    String? surveyNumber,
  }) async {
    final body = {
      'name': name,
      'locationName': district,
      'state': state,
      'district': district,
      'areaAcres': areaAcres,
      'cropType': cropType,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'latitude': latitude,
      'longitude': longitude,
      'soilType': ?soilType,
      'slope': ?slope,
      'irrigation': ?irrigation,
      'gridProximityKm': ?gridProximityKm,
      'irrigationSource': ?irrigationSource,
      'electricityTariff': ?electricityTariff,
      'surveyNumber': ?surveyNumber,
    };

    final response = await _client.post('/api/farms', body: body);
    final data = (response is Map && response['farm'] is Map)
        ? response['farm'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return Farm.fromJson(data);
  }

  Future<Farm> updateFarm(String id, Map<String, dynamic> updates) async {
    final response = await _client.patch('/api/farms/$id', body: updates);
    final data = (response is Map && response['farm'] is Map)
        ? response['farm'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return Farm.fromJson(data);
  }

  Future<void> deleteFarm(String id) async {
    await _client.delete('/api/farms/$id');
  }
}
