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
}
