import 'package:flutter_test/flutter_test.dart';
import 'package:agri_pv_navigator/services/calculation/agri_pv_calculation_service.dart';
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

    test('generateDesign generates consistent and complete configuration', () {
      final design = AgriPvCalculationService.generateDesign(
        id: 'test_design',
        name: 'Test Design',
        areaAcres: 2.35,
        crop: 'Wheat',
        mountingType: MountingType.elevated,
      );

      expect(design.pvCapacityKw, greaterThan(0));
      expect(design.annualEnergyMwh, greaterThan(0));
      expect(design.cultivableAreaPercent, greaterThan(50));
      expect(design.cropYieldPercent, greaterThan(80));
      expect(design.projectCostCr, greaterThan(0.5));
      expect(design.paybackYears, inInclusiveRange(4.0, 10.0));
    });
  });
}
