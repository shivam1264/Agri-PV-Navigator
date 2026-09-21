import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../models/site_assessment.dart';
import '../repositories/suitability_repository.dart';
import '../services/calculation/agri_pv_calculation_service.dart';
import '../core/errors/app_exceptions.dart';

class SuitabilityProvider extends ChangeNotifier {
  final SuitabilityRepository _repo = SuitabilityRepository();

  SiteAssessment? _assessment;
  bool _isLoading = false;
  String? _error;

  SiteAssessment? get assessment => _assessment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void evaluateLocally(Farm farm) {
    _assessment = AgriPvCalculationService.generateSiteAssessment(farm);
    notifyListeners();
  }

  Future<void> loadSuitability(String farmId, {Farm? fallbackFarm}) async {
    _isLoading = true;
    _error = null;
    if (fallbackFarm != null) {
      _assessment = AgriPvCalculationService.generateSiteAssessment(fallbackFarm);
    }
    notifyListeners();

    final cleanId = farmId.trim();
    if (cleanId.isEmpty || cleanId == 'draft' || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cleanId)) {
      // Offline / Draft: dynamic calculation already set from fallbackFarm
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _assessment = await _repo.getSuitability(cleanId);
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      if (fallbackFarm != null) {
        _assessment = AgriPvCalculationService.generateSiteAssessment(fallbackFarm);
      }
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (fallbackFarm != null) {
        _assessment = AgriPvCalculationService.generateSiteAssessment(fallbackFarm);
      }
      _error = 'Failed to load suitability assessment';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recalculateSuitability(String farmId, {Farm? fallbackFarm}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cleanId = farmId.trim();
    if (cleanId.isEmpty || cleanId == 'draft' || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cleanId)) {
      if (fallbackFarm != null) {
        _assessment = AgriPvCalculationService.generateSiteAssessment(fallbackFarm);
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _assessment = await _repo.recalculateSuitability(cleanId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (fallbackFarm != null) {
        _assessment = AgriPvCalculationService.generateSiteAssessment(fallbackFarm);
      }
      _error = 'Failed to recalculate suitability';
      _isLoading = false;
      notifyListeners();
    }
  }
}
