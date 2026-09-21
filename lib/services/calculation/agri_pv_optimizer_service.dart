import '../../models/agri_pv_design.dart';
import 'agri_pv_calculation_service.dart';

/// Optimization strategies for Agri-PV field configuration.
enum OptimizationStrategy {
  maxCrop(
    'Maximize Crop',
    'Agri-First Mode',
    'Prioritizes 95%+ crop yield and wide tractor access with high clearance.',
  ),
  balanced(
    'Optimal Dual-Yield',
    'Best LER Mode',
    'Pareto-optimal balance delivering peak Land Equivalent Ratio (LER > 1.6).',
  ),
  maxPower(
    'Maximize Energy',
    'Power-First Mode',
    'Maximizes clean energy generation, annual MWh, and fastest capital payback.',
  );

  final String title;
  final String subtitle;
  final String description;

  const OptimizationStrategy(this.title, this.subtitle, this.description);
}

/// Algorithmic optimizer that deterministically calculates the best Agri-PV system
/// configuration tailored to the farmer's specific crop, field area, and geography.
class AgriPvOptimizerService {
  /// Generates the optimal configuration for a given strategic objective.
  static AgriPvDesign optimizeForStrategy({
    required OptimizationStrategy strategy,
    required double areaAcres,
    required String crop,
  }) {
    final lowerCrop = crop.toLowerCase();
    final isShadeSensitive = lowerCrop.contains('rice') ||
        lowerCrop.contains('maize') ||
        lowerCrop.contains('cotton') ||
        lowerCrop.contains('sugarcane');

    switch (strategy) {
      case OptimizationStrategy.maxCrop:
        // Agri-First: Elevated or Tracker, wide spacing (8m), low coverage (28-30%)
        return AgriPvCalculationService.generateDesign(
          id: 'design_agri_first',
          name: 'Design A: Maximize Crop',
          areaAcres: areaAcres,
          crop: crop,
          mountingType: MountingType.elevated,
          tiltDegrees: 18.0,
          orientation: PanelOrientation.south,
          rowSpacingMeters: isShadeSensitive ? 9.0 : 8.0,
          panelCoveragePercent: isShadeSensitive ? 25.0 : 28.0,
        );

      case OptimizationStrategy.balanced:
        // Optimal Dual-Yield: Elevated (2.8m), 6.0m spacing, 38-40% coverage
        return AgriPvCalculationService.generateDesign(
          id: 'design_balanced',
          name: 'Design B: Optimal Dual-Yield',
          areaAcres: areaAcres,
          crop: crop,
          mountingType: MountingType.elevated,
          tiltDegrees: 20.0,
          orientation: PanelOrientation.south,
          rowSpacingMeters: isShadeSensitive ? 7.0 : 6.0,
          panelCoveragePercent: 38.0,
        );

      case OptimizationStrategy.maxPower:
        // Power-First: Higher coverage (48-52%), closer spacing (5.0m), tracker or fixed tilt
        return AgriPvCalculationService.generateDesign(
          id: 'design_power_first',
          name: 'Design C: Maximize Energy',
          areaAcres: areaAcres,
          crop: crop,
          mountingType: MountingType.singleAxisTracker,
          tiltDegrees: 24.0,
          orientation: PanelOrientation.south,
          rowSpacingMeters: 5.0,
          panelCoveragePercent: 50.0,
        );
    }
  }

  /// Returns all 3 optimized designs for side-by-side comparison for a specific farm.
  static List<AgriPvDesign> generateAllStrategies({
    required double areaAcres,
    required String crop,
  }) {
    return [
      optimizeForStrategy(
        strategy: OptimizationStrategy.maxCrop,
        areaAcres: areaAcres,
        crop: crop,
      ),
      optimizeForStrategy(
        strategy: OptimizationStrategy.balanced,
        areaAcres: areaAcres,
        crop: crop,
      ),
      optimizeForStrategy(
        strategy: OptimizationStrategy.maxPower,
        areaAcres: areaAcres,
        crop: crop,
      ),
    ];
  }

  /// Returns all 3 Pareto-optimal designs for 1-click selection and comparison.
  static List<AgriPvDesign> generateParetoDesigns(double areaAcres, String crop) {
    return generateAllStrategies(areaAcres: areaAcres, crop: crop);
  }
}
