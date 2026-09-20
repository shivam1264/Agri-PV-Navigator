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
}
