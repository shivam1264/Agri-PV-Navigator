import 'package:flutter/foundation.dart';
import '../models/support_ticket.dart';
import '../repositories/support_repository.dart';
import '../core/errors/app_exceptions.dart';

class SupportProvider extends ChangeNotifier {
  final SupportRepository _repo = SupportRepository();

  List<FaqItemModel> _faqs = [];
  List<SupportTicketModel> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<FaqItemModel> get faqs => _faqs;
  List<SupportTicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFaqs({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _faqs = await _repo.getFaqs(category: category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load FAQs';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTickets() async {
    try {
      _tickets = await _repo.getTickets();
      notifyListeners();
    } catch (e) {
      debugPrint('[SupportProvider] Failed to load tickets: $e');
    }
  }

  Future<bool> createTicket({
    required String subject,
    required String message,
    String category = 'General',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ticket = await _repo.createTicket(
        subject: subject,
        message: message,
        category: category,
      );
      _tickets.insert(0, ticket);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to submit ticket';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
