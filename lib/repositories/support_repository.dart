import '../core/network/api_client.dart';
import '../models/support_ticket.dart';

class SupportRepository {
  final ApiClient _client = ApiClient();

  Future<List<FaqItemModel>> getFaqs({String? category}) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;

    final response = await _client.get('/api/support/faqs', queryParams: queryParams, requiresAuth: false);
    if (response is List) {
      return response.map((f) => FaqItemModel.fromJson(f as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<SupportTicketModel>> getTickets() async {
    final response = await _client.get('/api/support/tickets');
    if (response is List) {
      return response.map((t) => SupportTicketModel.fromJson(t as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<SupportTicketModel> createTicket({
    required String subject,
    required String message,
    String category = 'General',
  }) async {
    final response = await _client.post(
      '/api/support/tickets',
      body: {
        'subject': subject,
        'message': message,
        'category': category,
      },
    );
    return SupportTicketModel.fromJson(response);
  }
}
