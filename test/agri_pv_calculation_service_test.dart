import 'package:flutter_test/flutter_test.dart';
import 'package:agri_pv_navigator/services/calculation/agri_pv_calculation_service.dart';
import 'package:agri_pv_navigator/services/calculation/agri_pv_optimizer_service.dart';
import 'package:agri_pv_navigator/models/agri_pv_design.dart';

void main() {
  group('AgriPvCalculationService Tests', () {
    test('calculateSuitability returns high score for flat land and high solar', () {
      final score = AgriPvCalculationService.calculateSuitability(
        solarIrradiationKwh: 4.8,
        slopePercent: 1.8,
        soilType: 'Loamy',
        hasIrrigation: true,
        cropShadeTolerance: 0.8,
        gridDistanceKm: 2.4,
      );

      expect(score, greaterThanOrEqualTo(80));
      expect(score, lessThanOrEqualTo(100));
    });

    test('calculatePvCapacity computes reasonable kW for 2.35 acres', () {
      final capacity = AgriPvCalculationService.calculatePvCapacity(
        areaAcres: 2.35,
        coveragePercent: 40.0,
        rowSpacingMeters: 6.0,
      );

      // ~258.5 kW expected
      expect(capacity, inInclusiveRange(200.0, 300.0));
    });

    test('calculateMachineryClearance approves elevated structures >= 2.9m', () {
      final clearance = AgriPvCalculationService.calculateMachineryClearance(
        panelHeightMeters: 2.8,
        rowSpacingMeters: 6.0,
      );

      expect(clearance.isCompatible, isTrue);
      expect(clearance.message, contains('Compatible'));
    });

    test('calculateLER produces greater than 1.0 for dual production', () {
      final ler = AgriPvCalculationService.calculateLER(
        cropYieldPercent: 94.0,
        coveragePercent: 40.0,
      );

      expect(ler, greaterThan(1.3));
      expect(ler, lessThan(2.0));
    });

    test('calculateDLI computes realistic ground Photosynthetically Active Radiation', () {
      final dli = AgriPvCalculationService.calculateDLI(
        coveragePercent: 40.0,
        panelHeightMeters: 2.8,
        ambientGhiKwh: 5.5,
      );

      // Baseline unshaded is ~40 mol/m2/day. With 40% coverage and 2.8m stilt, light should be ~20-35 mol/m2/day
      expect(dli, inInclusiveRange(20.0, 38.0));
    });

    test('calculateWaterSaved computes annual liters saved from evapotranspiration reduction', () {
      final waterSaved = AgriPvCalculationService.calculateWaterSaved(
        areaAcres: 2.35,
        coveragePercent: 40.0,
        crop: 'Wheat',
      );

      // 2.35 acres with 40% shade saving water should save tens of thousands of liters
      expect(waterSaved, greaterThan(10000.0));
      expect(waterSaved, lessThan(2000000.0));
    });

    test('calculateLCOE produces realistic utility-scale cost per kWh (₹2.00 - ₹5.00/kWh)', () {
      final lcoe = AgriPvCalculationService.calculateLCOE(
        projectCostCr: 1.2, // 1.2 Crore for ~250 kW
        annualEnergyMwh: 375.0,
        discountRate: 0.08,
        lifetimeYears: 25,
      );

      expect(lcoe, inInclusiveRange(2.0, 5.0));
    });

    test('calculateIRR converges to a viable internal rate of return', () {
      final irr = AgriPvCalculationService.calculateIRR(
        projectCostCr: 1.2,
        annualRevenueLakhs: 18.0,
        lifetimeYears: 25,
      );

      // Should be between 8% and 22% for healthy agrivoltaics
      expect(irr, inInclusiveRange(8.0, 22.0));
    });

    test('generateDesign populates new institutional-grade fields', () {
      final design = AgriPvCalculationService.generateDesign(
        id: 'test_design_v2',
        name: 'Test Design V2',
        areaAcres: 2.35,
        crop: 'Wheat',
        mountingType: MountingType.elevated,
      );

      expect(design.dliMolM2Day, greaterThan(10.0));
      expect(design.waterSavedLiters, greaterThan(1000.0));
      expect(design.lcoePerKwh, inInclusiveRange(2.0, 6.0));
      expect(design.irrPercent, inInclusiveRange(5.0, 25.0));
    });
  });

  group('AgriPvOptimizerService Tests', () {
    test('generateParetoDesigns produces 3 distinct presets with LER >= 1.0', () {
      final presets = AgriPvOptimizerService.generateParetoDesigns(2.35, 'Wheat');

      expect(presets.length, equals(3));
      final agriFirst = presets[0];
      final balanced = presets[1];
      final powerFirst = presets[2];

      // Agri-first should preserve highest crop yield
      expect(agriFirst.cropYieldPercent, greaterThanOrEqualTo(balanced.cropYieldPercent));
      // Power-first should have highest PV capacity
      expect(powerFirst.pvCapacityKw, greaterThanOrEqualTo(balanced.pvCapacityKw));
      // All presets must beat single-use land (LER >= 1.0)
      for (final p in presets) {
        expect(p.landEquivalentRatio, greaterThan(1.0));
        expect(p.lcoePerKwh, greaterThan(0.0));
        expect(p.waterSavedLiters, greaterThan(0.0));
      }
    });
  });
}
