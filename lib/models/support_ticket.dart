class FaqItemModel {
  final String id;
  final String question;
  final String answer;
  final String category;

  const FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  factory FaqItemModel.fromJson(Map<String, dynamic> json) {
    return FaqItemModel(
      id: json['id'] ?? json['_id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'] ?? 'General',
    );
  }
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String message;
  final String category;
  final String status;
  final DateTime createdAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.category,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] ?? json['_id'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? 'General',
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
