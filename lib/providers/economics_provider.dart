import 'package:flutter/foundation.dart';
import '../models/economic_assessment.dart';
import '../repositories/economics_repository.dart';
import '../core/errors/app_exceptions.dart';

class EconomicsProvider extends ChangeNotifier {
  final EconomicsRepository _repo = EconomicsRepository();

  EconomicAssessment? _economics;
  bool _isLoading = false;
  String? _error;

  EconomicAssessment? get economics => _economics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEconomics(String designId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _economics = await _repo.getEconomics(designId);
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load economics assessment';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> calculateEconomics(
    String designId, {
    double? electricityTariff,
    double? projectCostPerWatt,
    double? debtEquityRatio,
    double? loanInterestRate,
    int? loanTenureYears,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _economics = await _repo.calculateEconomics(
        designId,
        electricityTariff: electricityTariff,
        projectCostPerWatt: projectCostPerWatt,
        debtEquityRatio: debtEquityRatio,
        loanInterestRate: loanInterestRate,
        loanTenureYears: loanTenureYears,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to calculate economics';
      _isLoading = false;
      notifyListeners();
    }
  }
}
