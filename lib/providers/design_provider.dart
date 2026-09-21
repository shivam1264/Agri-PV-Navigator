import 'package:flutter/foundation.dart';
import '../models/agri_pv_design.dart';
import '../repositories/design_repository.dart';
import '../core/errors/app_exceptions.dart';

class DesignProvider extends ChangeNotifier {
  final DesignRepository _repo = DesignRepository();

  List<AgriPvDesign> _designs = [];
  AgriPvDesign? _activeDesign;
  Map<String, dynamic>? _comparisonData;
  Map<String, dynamic>? _visualizationConfig;
  Map<String, dynamic>? _shadowSimulationData;
  bool _isLoading = false;
  bool _isCalculating = false;
  String? _error;

  List<AgriPvDesign> get designs => _designs;
  AgriPvDesign? get activeDesign => _activeDesign;
  Map<String, dynamic>? get comparisonData => _comparisonData;
  Map<String, dynamic>? get visualizationConfig => _visualizationConfig;
  Map<String, dynamic>? get shadowSimulationData => _shadowSimulationData;
  bool get isLoading => _isLoading;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  void selectDesign(AgriPvDesign design) {
    _activeDesign = design;
    notifyListeners();
  }

  void setActiveDesign(AgriPvDesign design) {
    _activeDesign = design;
    final idx = _designs.indexWhere((d) => d.id == design.id);
    if (idx >= 0) {
      _designs[idx] = design;
    } else {
      _designs.insert(0, design);
    }
    notifyListeners();
  }

  Future<void> loadDesignsForFarm(String farmId) async {
    final cleanId = farmId.trim();
    if (cleanId.isEmpty || cleanId == 'draft' || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cleanId)) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _designs = await _repo.getDesignsForFarm(cleanId);
      if (_designs.isNotEmpty) {
        // Retain current if same id, else pick first
        if (_activeDesign != null) {
          final match = _designs.where((d) => d.id == _activeDesign!.id).toList();
          _activeDesign = match.isNotEmpty ? match.first : _designs.first;
        } else {
          _activeDesign = _designs.first;
        }
      }
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load farm designs';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDesignLive({
    MountingType? mountingType,
    double? tiltDegrees,
    PanelOrientation? orientation,
    double? rowSpacingMeters,
    double? panelCoveragePercent,
    double? panelHeightMeters,
  }) async {
    if (_activeDesign == null) return;

    // Optimistically update local active design
    _activeDesign = _activeDesign!.copyWith(
      mountingType: mountingType,
      tiltDegrees: tiltDegrees,
      orientation: orientation,
      rowSpacingMeters: rowSpacingMeters,
      panelCoveragePercent: panelCoveragePercent,
      panelHeightMeters: panelHeightMeters,
    );
    notifyListeners();

    // Call calculation API
    _isCalculating = true;
    notifyListeners();

    try {
      final updated = await _repo.calculateMetrics(_activeDesign!.id, {
        'mountingType': ?mountingType?.name,
        'tiltDegrees': ?tiltDegrees,
        'orientation': ?orientation?.name,
        'rowSpacingMeters': ?rowSpacingMeters,
        'panelCoveragePercent': ?panelCoveragePercent,
        'panelHeightMeters': ?panelHeightMeters,
      });

      _activeDesign = updated;
      final idx = _designs.indexWhere((d) => d.id == updated.id);
      if (idx >= 0) {
        _designs[idx] = updated;
      }
    } catch (e) {
      debugPrint('[DesignProvider] Live calculation error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> saveActiveDesign() async {
    if (_activeDesign == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final saved = await _repo.updateDesign(_activeDesign!.id, _activeDesign!.toJson());
      _activeDesign = saved;
      final idx = _designs.indexWhere((d) => d.id == saved.id);
      if (idx >= 0) {
        _designs[idx] = saved;
      }
    } catch (e) {
      _error = 'Failed to save design';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadComparison(String designId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _comparisonData = await _repo.getComparison(designId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load design comparison';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVisualizationConfig(String designId) async {
    try {
      _visualizationConfig = await _repo.getVisualizationConfig(designId);
      notifyListeners();
    } catch (e) {
      debugPrint('[DesignProvider] Visualization config error: $e');
    }
  }

  Future<void> loadShadowSimulation(String designId, {String? month, int? day, int? hour}) async {
    try {
      _shadowSimulationData = await _repo.getShadowSimulation(
        designId,
        month: month,
        day: day,
        hour: hour,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[DesignProvider] Shadow simulation error: $e');
    }
  }
}
