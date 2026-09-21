class EconomicAssessment {
  final double pvCapacityKw;
  final double annualEnergyMwh;
  final double projectCostCr;
  final double annualRevenueLakhs;
  final double paybackPeriodYears;
  final double netPresentValueLakhs;
  final double co2SavedTons;
  final double internalRateOfReturn; // e.g. 14.5%
  final double levelizedCostOfEnergy; // e.g. 2.85 ₹/kWh
  final Map<String, double> costBreakdown;
  final Map<String, double> revenueBreakdown;

  const EconomicAssessment({
    required this.pvCapacityKw,
    required this.annualEnergyMwh,
    required this.projectCostCr,
    required this.annualRevenueLakhs,
    required this.paybackPeriodYears,
    required this.netPresentValueLakhs,
    required this.co2SavedTons,
    this.internalRateOfReturn = 15.2,
    this.levelizedCostOfEnergy = 2.92,
    this.costBreakdown = const {
      'PV Modules': 45.0,
      'Mounting Structure': 25.0,
      'Inverters & Electrical': 15.0,
      'Installation & Balance': 15.0,
    },
    this.revenueBreakdown = const {
      'Solar Export Tariffs': 75.0,
      'Crop Yield Sales': 25.0,
    },
  });

  factory EconomicAssessment.fromJson(Map<String, dynamic> json) {
    Map<String, double> parseMap(dynamic map) {
      if (map is Map) {
        return map.map((key, value) => MapEntry(key.toString(), (value as num).toDouble()));
      }
      return {};
    }

    return EconomicAssessment(
      pvCapacityKw: (json['pvCapacityKw'] as num?)?.toDouble() ?? 0.0,
      annualEnergyMwh: (json['annualEnergyMwh'] as num?)?.toDouble() ?? 0.0,
      projectCostCr: (json['projectCostCr'] as num?)?.toDouble() ?? 0.0,
      annualRevenueLakhs: (json['annualRevenueLakhs'] as num?)?.toDouble() ?? 0.0,
      paybackPeriodYears: (json['paybackPeriodYears'] as num?)?.toDouble() ?? 0.0,
      netPresentValueLakhs: (json['netPresentValueLakhs'] as num?)?.toDouble() ?? 0.0,
      co2SavedTons: (json['co2SavedTons'] as num?)?.toDouble() ?? 0.0,
      internalRateOfReturn: (json['internalRateOfReturn'] as num?)?.toDouble() ?? 15.2,
      levelizedCostOfEnergy: (json['levelizedCostOfEnergy'] as num?)?.toDouble() ?? 2.92,
      costBreakdown: json['costBreakdown'] != null
          ? parseMap(json['costBreakdown'])
          : const {
              'PV Modules': 45.0,
              'Mounting Structure': 25.0,
              'Inverters & Electrical': 15.0,
              'Installation & Balance': 15.0,
            },
      revenueBreakdown: json['revenueBreakdown'] != null
          ? parseMap(json['revenueBreakdown'])
          : const {
              'Solar Export Tariffs': 75.0,
              'Crop Yield Sales': 25.0,
            },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pvCapacityKw': pvCapacityKw,
      'annualEnergyMwh': annualEnergyMwh,
      'projectCostCr': projectCostCr,
      'annualRevenueLakhs': annualRevenueLakhs,
      'paybackPeriodYears': paybackPeriodYears,
      'netPresentValueLakhs': netPresentValueLakhs,
      'co2SavedTons': co2SavedTons,
      'internalRateOfReturn': internalRateOfReturn,
      'levelizedCostOfEnergy': levelizedCostOfEnergy,
      'costBreakdown': costBreakdown,
      'revenueBreakdown': revenueBreakdown,
    };
  }
}
