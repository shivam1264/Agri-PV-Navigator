import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../repositories/farm_repository.dart';

class FarmProvider extends ChangeNotifier {
  final FarmRepository _repo = FarmRepository();

  List<Farm> _farms = [];
  Farm? _selectedFarm;
  bool _isLoading = false;
  String? _error;

  // Draft farm state for multi-step creation
  final Map<String, dynamic> _draftFarm = {
    'latitude': 22.9734,
    'longitude': 78.6561,
    'state': 'India',
    'district': '',
    'areaAcres': 5.0,
    'name': '',
    'cropType': 'Wheat',
    'soilType': 'Loamy',
    'irrigationSource': 'Borewell',
    'electricityTariff': 6.5,
    'surveyNumber': '',
  };

  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get draftFarm => _draftFarm;

  Farm get currentOrDraftFarm {
    if (_selectedFarm != null) return _selectedFarm!;
    final name = (_draftFarm['name'] as String? ?? '').trim();
    final district = _draftFarm['district'] as String? ?? 'Location';
    return Farm(
      id: 'draft',
      name: name.isNotEmpty ? name : 'Farm at $district',
      areaAcres: (_draftFarm['areaAcres'] as num?)?.toDouble() ?? 2.35,
      crop: _draftFarm['cropType'] as String? ?? 'Wheat',
      location: district,
      state: _draftFarm['state'] as String? ?? 'India',
      suitabilityScore: 85,
      soilType: _draftFarm['soilType'] as String? ?? 'Loamy',
      slope: _draftFarm['slope'] as String? ?? '< 2% (Almost flat)',
      irrigation: _draftFarm['irrigation'] as String? ?? 'Available',
      gridProximityKm: (_draftFarm['gridProximityKm'] as num?)?.toDouble() ?? 2.4,
      latitude: (_draftFarm['latitude'] as num?)?.toDouble() ?? 25.4358,
      longitude: (_draftFarm['longitude'] as num?)?.toDouble() ?? 81.8463,
      boundary: _draftBoundary,
    );
  }

  List<List<double>> get _draftBoundary {
    final raw = _draftFarm['boundaryPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<List>()
        .map((e) => e.whereType<num>().map((n) => n.toDouble()).toList())
        .toList();
  }

  void selectFarm(Farm farm) {
    _selectedFarm = farm;
    notifyListeners();
  }

  void selectFarmById(String id) {
    try {
      _selectedFarm = _farms.firstWhere((f) => f.id == id);
      notifyListeners();
    } catch (_) {}
  }

  void updateDraftLocation({
    required double latitude,
    required double longitude,
    String? state,
    String? district,
    double? areaAcres,
    List<List<double>>? boundaryPoints,
  }) {
    _draftFarm['latitude'] = latitude;
    _draftFarm['longitude'] = longitude;
    if (state != null) _draftFarm['state'] = state;
    if (district != null) _draftFarm['district'] = district;
    if (areaAcres != null) _draftFarm['areaAcres'] = areaAcres;
    if (boundaryPoints != null) {
      _draftFarm['boundaryPoints'] = boundaryPoints;
      _draftFarm['areaFromMapping'] = true;
    }
    notifyListeners();
  }

  void updateDraftDetails({
    String? name,
    String? cropType,
    String? soilType,
    String? slope,
    String? irrigation,
    double? gridProximityKm,
    String? irrigationSource,
    double? electricityTariff,
    String? surveyNumber,
    double? areaAcres,
  }) {
    if (name != null) _draftFarm['name'] = name;
    if (cropType != null) _draftFarm['cropType'] = cropType;
    if (soilType != null) _draftFarm['soilType'] = soilType;
    if (slope != null) _draftFarm['slope'] = slope;
    if (irrigation != null) _draftFarm['irrigation'] = irrigation;
    if (gridProximityKm != null) _draftFarm['gridProximityKm'] = gridProximityKm;
    if (irrigationSource != null) _draftFarm['irrigationSource'] = irrigationSource;
    if (electricityTariff != null) _draftFarm['electricityTariff'] = electricityTariff;
    if (surveyNumber != null) _draftFarm['surveyNumber'] = surveyNumber;
    if (areaAcres != null) _draftFarm['areaAcres'] = areaAcres;
    notifyListeners();
  }

  Future<void> loadFarms({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final serverFarms = await _repo.getFarms(search: search);
      // Merge server farms with any newly created local farms
      for (final sf in serverFarms) {
        _farms.removeWhere((f) => f.id == sf.id);
        _farms.add(sf);
      }
      if (_farms.isEmpty && serverFarms.isNotEmpty) {
        _farms = serverFarms;
      }
      if (_selectedFarm == null && _farms.isNotEmpty) {
        _selectedFarm = _farms.first;
      } else if (_selectedFarm != null) {
        final updated = _farms.where((f) => f.id == _selectedFarm!.id).toList();
        if (updated.isNotEmpty) {
          _selectedFarm = updated.first;
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Keep existing local farms so user never loses created farms
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Farm?> submitDraftFarm() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final name = _draftFarm['name'] as String? ?? '';
    final finalName = name.trim().isEmpty ? 'Farm at ${_draftFarm['district'] ?? 'Location'}' : name.trim();
    final areaVal = (_draftFarm['areaAcres'] as num?)?.toDouble() ?? 2.35;
    final cropVal = _draftFarm['cropType'] as String? ?? 'Wheat';
    final districtVal = _draftFarm['district'] as String? ?? 'Prayagraj';
    final stateVal = _draftFarm['state'] as String? ?? 'Uttar Pradesh, India';
    final latVal = (_draftFarm['latitude'] as num?)?.toDouble() ?? 25.4358;
    final lonVal = (_draftFarm['longitude'] as num?)?.toDouble() ?? 81.8463;
    final soilVal = _draftFarm['soilType'] as String? ?? 'Loamy';
    final slopeVal = _draftFarm['slope'] as String? ?? '< 2% (Almost flat)';
    final irrVal = _draftFarm['irrigation'] as String? ?? 'Available';
    final gridVal = (_draftFarm['gridProximityKm'] as num?)?.toDouble() ?? 2.4;

    // Build real Farm instance immediately
    Farm farmResult = Farm(
      id: 'farm_${DateTime.now().millisecondsSinceEpoch}',
      name: finalName,
      state: stateVal,
      location: districtVal,
      areaAcres: areaVal,
      crop: cropVal,
      latitude: latVal,
      longitude: lonVal,
      soilType: soilVal,
      slope: slopeVal,
      irrigation: irrVal,
      gridProximityKm: gridVal,
      suitabilityScore: 85,
      boundary: _draftBoundary,
    );

    try {
      final serverFarm = await _repo.createFarm(
        name: finalName,
        state: stateVal,
        district: districtVal,
        areaAcres: areaVal,
        cropType: cropVal,
        latitude: latVal,
        longitude: lonVal,
        soilType: soilVal,
        slope: slopeVal,
        irrigation: irrVal,
        gridProximityKm: gridVal,
        irrigationSource: _draftFarm['irrigationSource'],
        electricityTariff: (_draftFarm['electricityTariff'] as num?)?.toDouble(),
        surveyNumber: _draftFarm['surveyNumber'],
        boundary: _draftBoundary,
      );
      farmResult = serverFarm;
    } catch (e) {
      debugPrint('Notice: Farm persisted in active state (offline fallback): $e');
    }

    _farms.removeWhere((f) => f.id == farmResult.id);
    _farms.insert(0, farmResult);
    _selectedFarm = farmResult;
    _isLoading = false;
    notifyListeners();
    return farmResult;
  }

  Future<bool> deleteFarm(String id) async {
    try {
      await _repo.deleteFarm(id);
      _farms.removeWhere((f) => f.id == id);
      if (_selectedFarm?.id == id) {
        _selectedFarm = _farms.isNotEmpty ? _farms.first : null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete farm';
      notifyListeners();
      return false;
    }
  }
}
