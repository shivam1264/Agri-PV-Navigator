import 'package:flutter/foundation.dart';
import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';
import '../core/errors/app_exceptions.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repo = DashboardRepository();

  DashboardSummary _summary = const DashboardSummary();
  bool _isLoading = false;
  String? _error;

  DashboardSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _repo.getSummary();
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load dashboard data';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
