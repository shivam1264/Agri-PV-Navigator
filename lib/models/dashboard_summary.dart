import 'farm.dart';
import 'proposal_report.dart';

class DashboardSummary {
  final int totalFarms;
  final double totalAreaAcres;
  final int designsCreated;
  final List<Farm> recentFarms;
  final List<ProposalReport> recentReports;
  final int unreadNotifications;

  const DashboardSummary({
    this.totalFarms = 0,
    this.totalAreaAcres = 0.0,
    this.designsCreated = 0,
    this.recentFarms = const [],
    this.recentReports = const [],
    this.unreadNotifications = 0,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final data = (json['summary'] is Map<String, dynamic>)
        ? json['summary'] as Map<String, dynamic>
        : json;

    return DashboardSummary(
      totalFarms: data['totalFarms'] ?? 0,
      totalAreaAcres: (data['totalAreaAcres'] as num?)?.toDouble() ?? 0.0,
      designsCreated: data['designsCreated'] ?? 0,
      recentFarms: (data['recentFarms'] as List?)
              ?.map((f) => Farm.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      recentReports: (data['recentReports'] as List?)
              ?.map((r) => ProposalReport.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      unreadNotifications: data['unreadNotifications'] ?? 0,
    );
  }
}
