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
}
