import 'suitability_factor.dart';

class SiteAssessment {
  final String farmId;
  final int overallScore;
  final String summary;
  final List<SuitabilityFactor> factors;
  final List<String> recommendations;

  const SiteAssessment({
    required this.farmId,
    required this.overallScore,
    required this.summary,
    required this.factors,
    required this.recommendations,
  });

  String get suitabilityStatus {
    if (overallScore >= 80) return 'Suitable';
    if (overallScore >= 60) return 'Moderately Suitable';
    return 'Low Suitability';
  }

  factory SiteAssessment.fromJson(Map<String, dynamic> json) {
    final data = (json['assessment'] is Map<String, dynamic>)
        ? json['assessment'] as Map<String, dynamic>
        : json;

    final rawFactors = data['factors'];
    List<SuitabilityFactor> factorsList = [];
    if (rawFactors is List) {
      factorsList = rawFactors
          .map((f) => SuitabilityFactor.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    final rawRecs = data['recommendations'];
    List<String> recsList = [];
    if (rawRecs is List) {
      recsList = rawRecs.map((r) => r.toString()).toList();
    }

    return SiteAssessment(
      farmId: (data['farmId'] ?? data['_id'] ?? '').toString(),
      overallScore: (data['overallScore'] is num) ? (data['overallScore'] as num).toInt() : 80,
      summary: data['summary'] ?? 'Your land is well-suited for Agri-PV with minimal constraints.',
      factors: factorsList,
      recommendations: recsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmId': farmId,
      'overallScore': overallScore,
      'summary': summary,
      'factors': factors.map((f) => f.toJson()).toList(),
      'recommendations': recommendations,
    };
  }
}
