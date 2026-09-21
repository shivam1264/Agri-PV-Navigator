import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/factor_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/painters/score_arc_painter.dart';
import '../../../shared/painters/farm_boundary_painter.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';
import '../../../services/calculation/solar_lookup_service.dart';
import '../../../models/suitability_factor.dart';
import '../../../providers/farm_provider.dart';

class SiteSuitabilityScreen extends ConsumerWidget {
  const SiteSuitabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftFarmProvider);

    // Calculate real suitability from user inputs
    final irradiation = SolarLookupService.getIrradiation(draft.location.isEmpty ? 'Uttar Pradesh' : draft.location);
    final slopePercent = SolarLookupService.getSlopePercent(draft.slope);
    final cropTolerance = SolarLookupService.getCropShadeTolerance(draft.crop);
    final hasIrrigation = draft.irrigation != 'Rainfed';

    final score = AgriPvCalculationService.calculateSuitability(
      solarIrradiationKwh: irradiation,
      slopePercent: slopePercent,
      soilType: draft.soilType,
      hasIrrigation: hasIrrigation,
      cropShadeTolerance: cropTolerance,
      gridDistanceKm: draft.gridProximityKm,
    );

    // Save score back to draft
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(draftFarmProvider.notifier).setSuitabilityScore(score);
    });

    // Build real factor list from computed inputs
    final factors = [
      SuitabilityFactor(
        id: 'f1', name: 'Solar Resource',
        score: ((irradiation / 6.5) * 100).round().clamp(40, 100),
        metricValue: '${irradiation.toStringAsFixed(1)} kWh/m²/day',
        shortReason: SolarLookupService.getSolarZoneLabel(irradiation),
        fullAssessment: 'Solar irradiation of ${irradiation.toStringAsFixed(1)} kWh/m²/day supports strong PV output.',
        impact: irradiation >= 5.0 ? 'Positive: High capacity utilization factor expected.' : 'Moderate: Adequate for viable PV generation.',
        icon: Icons.wb_sunny_rounded, accentColor: AppColors.solar,
      ),
      SuitabilityFactor(
        id: 'f2', name: 'Land Slope',
        score: slopePercent <= 2 ? 92 : slopePercent <= 5 ? 80 : 55,
        metricValue: '${slopePercent.toStringAsFixed(1)}% slope',
        shortReason: slopePercent <= 2 ? 'Ideal flat land.' : slopePercent <= 5 ? 'Gentle slope, manageable.' : 'Moderate slope, needs civil work.',
        fullAssessment: 'Slope of ${slopePercent.toStringAsFixed(1)}% determines civil foundation requirements.',
        impact: slopePercent <= 2 ? 'Positive: Minimal civil terracing needed.' : 'Moderate: Some levelling may be required.',
        icon: Icons.landscape_rounded, accentColor: AppColors.slope,
      ),
      SuitabilityFactor(
        id: 'f3', name: 'Soil Type',
        score: draft.soilType.toLowerCase().contains('loam') ? 85 : draft.soilType.toLowerCase().contains('alluvial') ? 90 : 70,
        metricValue: draft.soilType,
        shortReason: '${draft.soilType} supports dual cultivation.',
        fullAssessment: '${draft.soilType} provides good load-bearing capacity and agricultural fertility.',
        impact: 'Positive: Suitable for anchor piling and healthy root growth.',
        icon: Icons.grass_rounded, accentColor: AppColors.soil,
      ),
      SuitabilityFactor(
        id: 'f4', name: 'Water Availability',
        score: hasIrrigation ? (draft.irrigation == 'Available' ? 80 : 65) : 50,
        metricValue: draft.irrigation,
        shortReason: hasIrrigation ? 'Irrigation supports panel washing & crop hydration.' : 'Rainfed only — limits module cleaning.',
        fullAssessment: 'Regular irrigation enables periodic module dust cleaning and crop hydration.',
        impact: hasIrrigation ? 'Positive: Scheduled module washing feasible.' : 'Moderate: Rainfed may reduce panel efficiency.',
        icon: Icons.water_drop_rounded, accentColor: AppColors.water,
      ),
      SuitabilityFactor(
        id: 'f5', name: 'Crop Shade Tolerance',
        score: (cropTolerance * 100).round(),
        metricValue: draft.crop,
        shortReason: '${draft.crop} can tolerate partial shading.',
        fullAssessment: '${draft.crop} has shade tolerance of ${(cropTolerance * 100).toInt()}%, suitable for Agri-PV.',
        impact: cropTolerance >= 0.75 ? 'Positive: Microclimate benefit expected.' : 'Moderate: Monitor shading impact on yield.',
        icon: Icons.eco_rounded, accentColor: AppColors.primary,
      ),
      SuitabilityFactor(
        id: 'f6', name: 'Grid Proximity',
        score: draft.gridProximityKm <= 3 ? 88 : draft.gridProximityKm <= 7 ? 75 : 55,
        metricValue: '${draft.gridProximityKm.toStringAsFixed(1)} km to substation',
        shortReason: draft.gridProximityKm <= 3 ? 'Short interconnection reduces costs.' : 'Feasible grid distance.',
        fullAssessment: 'Grid distance of ${draft.gridProximityKm.toStringAsFixed(1)} km determines evacuation infrastructure cost.',
        impact: draft.gridProximityKm <= 3 ? 'Positive: Low interconnection CAPEX.' : 'Moderate: Longer line adds cost.',
        icon: Icons.electric_bolt_rounded, accentColor: AppColors.solar,
      ),
    ];

    final locationLabel = draft.location.isEmpty ? 'Your Farm' : draft.location.split(',').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => context.go('/farm-details'),
        ),
        title: const Text(
          'Site Suitability',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper (Step 3: Suitability)
            ProgressStepper(
              currentStep: 3,
              onStepTapped: (step) {
                if (step == 1) context.go('/farm-location');
                if (step == 2) context.go('/farm-details');
                if (step == 4) context.go('/agri-pv-design');
              },
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Site Suitability Analysis',
                      style: AppTypography.screenHeading.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 12),

                    // Farm Map Preview Banner with "Your Farm" tag
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/satellite_map.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: FarmBoundaryPainter(
                                  areaAcres: 2.35,
                                  showPins: false,
                                  drawBackground: false,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      locationLabel,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Overall Suitability Score Card with circular gauge
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          // Circular Arc Gauge
                          SizedBox(
                            width: 86,
                            height: 86,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(86, 86),
                                  painter: ScoreArcPainter(
                                    score: score.toDouble(),
                                    activeColor: AppColors.primary,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$score',
                                      style: AppTypography.metricNumber.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      '/ 100',
                                      style: AppTypography.labelSmall.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),

                          // Text Summary & Status Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Suitability',
                                  style: AppTypography.label.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        score >= 80
                                            ? 'Highly Suitable'
                                            : score >= 60
                                                ? 'Moderately Suitable'
                                                : 'Low Suitability',
                                        style: AppTypography.labelSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  score >= 80
                                      ? 'High solar resource and favorable slope make this land optimal for elevated PV.'
                                      : score >= 60
                                          ? 'Moderate suitability — some factors may need attention before installation.'
                                          : 'Marginal suitability — consult an expert for custom assessment.',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Factor Cards List
                    Text(
                      'Suitability Factors',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    ...factors.map((factor) => FactorCard(
                      factor: factor,
                      onTap: () => context.go('/suitability-details'),
                    )),
                    const SizedBox(height: 12),

                    // "View Detailed Analysis" Outline Button
                    AppButton(
                      text: 'View Detailed Analysis',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/suitability-details'),
                      height: 44,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/farm-details'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/agri-pv-design'),
                      height: 46,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/farms');
          if (index == 2) context.go('/farm-location');
          if (index == 3) context.go('/reports');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }
}
