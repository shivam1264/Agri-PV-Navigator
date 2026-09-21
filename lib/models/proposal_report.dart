enum ReportType {
  proposal('Agri-PV Proposal', 'Proposal'),
  technical('Technical Report', 'Designs'),
  financial('Financial Analysis', 'Financial'),
  environmental('Impact Assessment', 'Impact');

  final String title;
  final String category;
  const ReportType(this.title, this.category);
}

class ProposalReport {
  final String id;
  final String title;
  final String farmName;
  final DateTime date;
  final ReportType type;
  final String fileSize;
  final String downloadUrl;

  const ProposalReport({
    required this.id,
    required this.title,
    required this.farmName,
    required this.date,
    required this.type,
    required this.fileSize,
    required this.downloadUrl,
  });

  factory ProposalReport.fromJson(Map<String, dynamic> json) {
    final data = (json['report'] is Map<String, dynamic>)
        ? json['report'] as Map<String, dynamic>
        : json;

    ReportType parseType(String? typeStr) {
      if (typeStr == null) return ReportType.proposal;
      return ReportType.values.firstWhere(
        (t) => t.name.toLowerCase() == typeStr.toLowerCase() || t.category.toLowerCase() == typeStr.toLowerCase(),
        orElse: () => ReportType.proposal,
      );
    }

    final rawType = data['reportType'] ?? data['type'];

    return ProposalReport(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      title: data['title'] ?? 'Agri-PV Report',
      farmName: data['farmName'] ?? 'Farm',
      date: data['date'] != null
          ? DateTime.tryParse(data['date']) ?? DateTime.now()
          : (data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
              : DateTime.now()),
      type: parseType(rawType?.toString()),
      fileSize: data['fileSize'] ?? '1.2 MB',
      downloadUrl: data['downloadUrl'] ?? data['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'farmName': farmName,
      'date': date.toIso8601String(),
      'type': type.name,
      'fileSize': fileSize,
      'downloadUrl': downloadUrl,
    };
  }
}
