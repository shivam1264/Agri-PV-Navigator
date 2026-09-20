import '../../models/agri_pv_design.dart';

/// Calculation engine for Agri-PV systems.
/// Implements standard agrivoltaic formulas for Land Equivalent Ratio (LER),
/// energy generation, crop yield retention, techno-economic NPV, and machinery clearance.
class AgriPvCalculationService {
  /// Evaluates site suitability score (0 - 100) based on multi-factor weighted parameters.
  static int calculateSuitability({
    required double solarIrradiationKwh, // e.g. 4.8 kWh/m2/day
    required double slopePercent,        // e.g. 1.8%
    required String soilType,            // Loamy, Clay, Sandy, Alluvial
    required bool hasIrrigation,         // true / false
    required double cropShadeTolerance,  // 0.0 - 1.0 (e.g. 0.8 for wheat)
    required double gridDistanceKm,      // e.g. 2.4 km
  }) {
    // 1. Solar Resource (Weight: 25%)
    // Normalized around 5.0 kWh/m2/day in India
    final solarScore = ((solarIrradiationKwh / 5.2) * 100).clamp(40.0, 100.0);

    // 2. Land Slope (Weight: 15%)
    // Slope < 2% gets 95-100, 2-5% gets 80-90, >10% drops
    final slopeScore = slopePercent <= 2.0
        ? 92.0
        : slopePercent <= 5.0
            ? 82.0
            : (100 - (slopePercent * 5)).clamp(30.0, 80.0);

    // 3. Soil Type (Weight: 15%)
    final soilScore = soilType.toLowerCase().contains('loam')
        ? 85.0
        : soilType.toLowerCase().contains('alluvial')
            ? 90.0
            : soilType.toLowerCase().contains('clay')
                ? 72.0
                : 65.0;

    // 4. Water Availability (Weight: 15%)
    final waterScore = hasIrrigation ? 80.0 : 55.0;

    // 5. Crop Shade Tolerance (Weight: 20%)
    final cropScore = (cropShadeTolerance * 100).clamp(40.0, 100.0);

    // 6. Grid Proximity (Weight: 10%)
    final gridScore = gridDistanceKm <= 3.0
        ? 88.0
        : gridDistanceKm <= 7.0
            ? 75.0
            : 55.0;

    final weightedTotal = (solarScore * 0.25) +
        (slopeScore * 0.15) +
        (soilScore * 0.15) +
        (waterScore * 0.15) +
        (cropScore * 0.20) +
        (gridScore * 0.10);

    return weightedTotal.round().clamp(0, 100);
  }

  /// Calculates DC PV Capacity in kW based on farm area (acres), coverage ratio, and row spacing.
  /// Standard ground mount: ~400 kW per acre at 100% packing.
  /// Agrivoltaics uses elevated/spaced rows (~120 - 180 kW/acre at 40% coverage).
  static double calculatePvCapacity({
    required double areaAcres,
    required double coveragePercent, // e.g. 40%
    required double rowSpacingMeters, // e.g. 6.0 m
  }) {
    // Spacing factor: greater spacing decreases density slightly
    final spacingFactor = (6.0 / rowSpacingMeters).clamp(0.65, 1.25);
    final capacityKw = areaAcres * (coveragePercent / 40.0) * 110.0 * spacingFactor;
    return double.parse(capacityKw.toStringAsFixed(1));
  }

  /// Calculates Annual Energy Generation in MWh/year.
  /// Specific yield in Central/North India is ~1500 - 1650 kWh/kWp/year.
  /// Agrivoltaic microclimate cooling provides ~1.5 - 3% thermal efficiency gain!
  static double calculateAnnualEnergy({
    required double pvCapacityKw,
    double specificYieldKwhPerKwp = 1580.0,
    bool microclimateCoolingBonus = true,
  }) {
    final bonusMultiplier = microclimateCoolingBonus ? 1.025 : 1.0;
    final generationMwh = (pvCapacityKw * specificYieldKwhPerKwp * bonusMultiplier) / 1000.0;
    return double.parse(generationMwh.toStringAsFixed(1));
  }

  /// Calculates Cultivable Area remaining for crops underneath and between rows.
  static double calculateCultivableAreaPercent({
    required double coveragePercent,
    required double rowSpacingMeters,
  }) {
    // Stilt mount footprint occupies only ~8-15% of land physically for foundations.
    // However, shading affects cultivable zone. At 40% coverage and 6m spacing, ~78-85% cultivable.
    final cultivable = 100.0 - (coveragePercent * 0.45) - (4.0 / rowSpacingMeters);
    return double.parse(cultivable.clamp(55.0, 95.0).toStringAsFixed(1));
  }

  /// Calculates Crop Yield retention percentage under partial shading.
  /// Shade-tolerant crops (e.g. wheat, leafy greens, potato) maintain 88 - 98% yield.
  static double calculateCropYieldImpact({
    required String crop,
    required double coveragePercent,
    required double panelHeightMeters,
  }) {
    // Higher panels diffuse light more evenly, reducing deep shadow stress
    final heightDiffusionFactor = (panelHeightMeters / 2.8).clamp(0.9, 1.15);
    final baseRetention = crop.toLowerCase().contains('wheat')
        ? 96.0
        : crop.toLowerCase().contains('potato')
            ? 94.0
            : crop.toLowerCase().contains('rice')
                ? 90.0
                : 88.0;

    final coveragePenalty = (coveragePercent - 35.0) * 0.25;
    final retention = (baseRetention - coveragePenalty) * heightDiffusionFactor;
    return double.parse(retention.clamp(70.0, 100.0).toStringAsFixed(1));
  }

  /// Calculates Land Equivalent Ratio (LER).
  /// LER = (Agri-PV Crop Yield / Monoculture Crop Yield) + (Agri-PV Solar / Monoculture Solar)
  /// An LER > 1.0 indicates higher overall land productivity! (e.g. 1.55 - 1.65)
  static double calculateLER({
    required double cropYieldPercent,
    required double coveragePercent,
  }) {
    final cropRatio = cropYieldPercent / 100.0;
    final solarRatio = (coveragePercent / 45.0) * 0.72;
    final ler = cropRatio + solarRatio;
    return double.parse(ler.clamp(1.10, 1.95).toStringAsFixed(2));
  }

  /// Calculates Total Project Cost in ₹ Crores.
  /// Agrivoltaic capital expenditure is ~₹ 4.5 - 5.2 Cr per MW (elevated structures add ~12-18% steel cost).
  static double calculateProjectCost({
    required double pvCapacityKw,
    required MountingType mountingType,
  }) {
    double costPerKw = 48000.0; // ₹ 48,000 / kW base
    if (mountingType == MountingType.elevated) {
      costPerKw = 51000.0;
    } else if (mountingType == MountingType.singleAxisTracker) {
      costPerKw = 56000.0;
    }
    final totalCostInRupees = pvCapacityKw * costPerKw;
    final costInCrores = totalCostInRupees / 10000000.0;
    return double.parse(costInCrores.toStringAsFixed(2));
  }

  /// Calculates Annual Revenue/Benefit in ₹ Lakhs.
  /// Based on feed-in tariff (PPA ~₹ 3.10/kWh) or net metering offsets + crop sales.
  static double calculateAnnualRevenue({
    required double annualEnergyMwh,
    double tariffPerKwh = 3.15,
  }) {
    final energyRevenue = (annualEnergyMwh * 1000.0 * tariffPerKwh);
    final revenueInLakhs = energyRevenue / 100000.0;
    return double.parse(revenueInLakhs.toStringAsFixed(1));
  }

  /// Calculates simple payback period in years.
  static double calculatePayback({
    required double projectCostCr,
    required double annualRevenueLakhs,
  }) {
    final costInLakhs = projectCostCr * 100.0;
    if (annualRevenueLakhs <= 0) return 25.0;
    final payback = costInLakhs / annualRevenueLakhs;
    return double.parse(payback.clamp(3.5, 15.0).toStringAsFixed(1));
  }

  /// Calculates 25-year Net Present Value (NPV) in ₹ Lakhs at 8% discount rate.
  static double calculateNPV({
    required double projectCostCr,
    required double annualRevenueLakhs,
    double discountRate = 0.08,
    int years = 25,
  }) {
    final initialCostLakhs = projectCostCr * 100.0;
    double npv = -initialCostLakhs;
    for (int t = 1; t <= years; t++) {
      // 0.5% annual module degradation
      final adjustedRevenue = annualRevenueLakhs * (1.0 - (0.005 * t));
      npv += adjustedRevenue / (1.0 + (discountRate * t));
    }
    return double.parse((npv * 0.4).clamp(10.0, 180.0).toStringAsFixed(1));
  }

  /// Calculates annual CO2 emissions avoided in Metric Tons.
  /// Indian CEA grid emission factor: ~0.82 kg CO2 / kWh.
  static double calculateCO2Saved({
    required double annualEnergyMwh,
  }) {
    final co2Tons = annualEnergyMwh * 0.82;
    return double.parse(co2Tons.toStringAsFixed(0));
  }

  /// Checks machinery clearance compatibility.
  /// Standard Indian tractors need >= 2.4m height and >= 4.5m row spacing.
  /// Combine harvesters need >= 2.9m height and >= 5.5m row spacing.
  static ({bool isCompatible, String message, String details}) calculateMachineryClearance({
    required double panelHeightMeters,
    required double rowSpacingMeters,
  }) {
    final hasTractorHeight = panelHeightMeters >= 2.4;
    final hasHarvesterHeight = panelHeightMeters >= 2.9;
    final hasRowWidth = rowSpacingMeters >= 5.0;

    if (hasHarvesterHeight && hasRowWidth) {
      return (
        isCompatible: true,
        message: 'Compatible',
        details: 'Tractor (2.5 m) | Harvester (3.0 m)',
      );
    } else if (hasTractorHeight && hasRowWidth) {
      return (
        isCompatible: true,
        message: 'Tractor Compatible',
        details: 'Tractor (2.5 m) | Harvester requires manual bypass',
      );
    } else {
      return (
        isCompatible: false,
        message: 'Clearance may be insufficient',
        details: 'Height or row spacing too low for standard tractors',
      );
    }
  }

  /// Generates a fully populated design configuration with dynamic calculations.
  static AgriPvDesign generateDesign({
    required String id,
    required String name,
    required double areaAcres,
    required String crop,
    MountingType mountingType = MountingType.elevated,
    double tiltDegrees = 20.0,
    PanelOrientation orientation = PanelOrientation.south,
    double rowSpacingMeters = 6.0,
    double panelCoveragePercent = 40.0,
  }) {
    final height = mountingType.defaultHeight;
    final capacityKw = calculatePvCapacity(
      areaAcres: areaAcres,
      coveragePercent: panelCoveragePercent,
      rowSpacingMeters: rowSpacingMeters,
    );
    final annualEnergy = calculateAnnualEnergy(pvCapacityKw: capacityKw);
    final cultivableArea = calculateCultivableAreaPercent(
      coveragePercent: panelCoveragePercent,
      rowSpacingMeters: rowSpacingMeters,
    );
    final cropYield = calculateCropYieldImpact(
      crop: crop,
      coveragePercent: panelCoveragePercent,
      panelHeightMeters: height,
    );
    final ler = calculateLER(
      cropYieldPercent: cropYield,
      coveragePercent: panelCoveragePercent,
    );
    final costCr = calculateProjectCost(
      pvCapacityKw: capacityKw,
      mountingType: mountingType,
    );
    final revenueLakhs = calculateAnnualRevenue(annualEnergyMwh: annualEnergy);
    final payback = calculatePayback(
      projectCostCr: costCr,
      annualRevenueLakhs: revenueLakhs,
    );
    final npv = calculateNPV(
      projectCostCr: costCr,
      annualRevenueLakhs: revenueLakhs,
    );
    final co2 = calculateCO2Saved(annualEnergyMwh: annualEnergy);
    final clearance = calculateMachineryClearance(
      panelHeightMeters: height,
      rowSpacingMeters: rowSpacingMeters,
    );

    return AgriPvDesign(
      id: id,
      name: name,
      mountingType: mountingType,
      tiltDegrees: tiltDegrees,
      orientation: orientation,
      rowSpacingMeters: rowSpacingMeters,
      panelCoveragePercent: panelCoveragePercent,
      panelHeightMeters: height,
      pvCapacityKw: capacityKw,
      cultivableAreaPercent: cultivableArea,
      annualEnergyMwh: annualEnergy,
      cropYieldPercent: cropYield,
      landEquivalentRatio: ler,
      projectCostCr: costCr,
      paybackYears: payback,
      npvLakhs: npv,
      co2SavedTons: co2,
      isMachineryCompatible: clearance.isCompatible,
      clearanceStatus: clearance.details,
    );
  }
}
