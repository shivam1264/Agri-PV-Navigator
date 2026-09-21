import '../core/network/api_client.dart';
import '../models/support_ticket.dart';
import '../features/support/data/faq_knowledge_base.dart';

class SupportRepository {
  final ApiClient _client = ApiClient();

  Future<List<FaqItemModel>> getFaqs({String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;

      final response = await _client.get('/api/support/faqs', queryParams: queryParams, requiresAuth: false);

      List rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['faqs'] is List) {
        rawList = response['faqs'] as List;
      }

      if (rawList.isNotEmpty) {
        return rawList.map((f) => FaqItemModel.fromJson(f as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback seamlessly to local offline institutional knowledge
    }

    // Default institutional knowledge base fallback
    var localItems = FaqKnowledgeBase.items;
    if (category != null && category.isNotEmpty && category != 'All') {
      localItems = FaqKnowledgeBase.getByCategory(category);
    }

    return localItems
        .map(
          (item) => FaqItemModel(
            id: item.id,
            question: item.questionEn,
            answer: item.answerEn,
            category: item.category,
          ),
        )
        .toList();
  }

  Future<List<SupportTicketModel>> getTickets() async {
    final response = await _client.get('/api/support/tickets');
    if (response is List) {
      return response.map((t) => SupportTicketModel.fromJson(t as Map<String, dynamic>)).toList();
    } else if (response is Map && response['tickets'] is List) {
      return (response['tickets'] as List).map((t) => SupportTicketModel.fromJson(t as Map<String, dynamic>)).toList();
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
    final data = (response is Map && response['ticket'] is Map)
        ? response['ticket'] as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : <String, dynamic>{});

    return SupportTicketModel.fromJson(data);
  }
}
