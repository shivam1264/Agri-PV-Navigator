import 'package:flutter/material.dart';
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
import '../../../services/storage/mock_data_service.dart';

class SiteSuitabilityScreen extends StatelessWidget {
  const SiteSuitabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final assessment = mockService.defaultSiteAssessment;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                if (step == 5) context.go('/proposal-report');
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
                                child: const Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.white, size: 13),
                                    SizedBox(width: 4),
                                    Text(
                                      'Your Farm (Phulpur)',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
                                    score: assessment.overallScore.toDouble(),
                                    activeColor: AppColors.primary,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${assessment.overallScore}',
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
                                        assessment.suitabilityStatus,
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
                                  'High solar resource and favorable slope make this land optimal for elevated PV.',
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

                    ...assessment.factors.map((factor) => FactorCard(
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                      onPressed: () => context.go('/suitability-details'),
                      height: 46,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
