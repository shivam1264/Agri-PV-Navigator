import '../core/network/api_client.dart';
import '../models/economic_assessment.dart';

class EconomicsRepository {
  final ApiClient _client = ApiClient();

  Future<EconomicAssessment> getEconomics(String designId) async {
    final response = await _client.get('/api/designs/$designId/economics');
    return EconomicAssessment.fromJson(response);
  }

  Future<EconomicAssessment> calculateEconomics(
    String designId, {
    double? electricityTariff,
    double? projectCostPerWatt,
    double? debtEquityRatio,
    double? loanInterestRate,
    int? loanTenureYears,
  }) async {
    final body = <String, dynamic>{};
    if (electricityTariff != null) body['electricityTariff'] = electricityTariff;
    if (projectCostPerWatt != null) body['projectCostPerWatt'] = projectCostPerWatt;
    if (debtEquityRatio != null) body['debtEquityRatio'] = debtEquityRatio;
    if (loanInterestRate != null) body['loanInterestRate'] = loanInterestRate;
    if (loanTenureYears != null) body['loanTenureYears'] = loanTenureYears;

    final response = await _client.post('/api/designs/$designId/economics/calculate', body: body);
    return EconomicAssessment.fromJson(response);
  }
}
