import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/factor_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/painters/score_arc_painter.dart';
import 'package:provider/provider.dart';
import '../../../providers/suitability_provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../models/farm.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';

class SiteSuitabilityScreen extends StatefulWidget {
  final bool readOnly;

  const SiteSuitabilityScreen({super.key, this.readOnly = false});

  @override
  State<SiteSuitabilityScreen> createState() => _SiteSuitabilityScreenState();
}

class _SiteSuitabilityScreenState extends State<SiteSuitabilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farm = context.read<FarmProvider>().currentOrDraftFarm;
      context.read<SuitabilityProvider>().loadSuitability(farm.id, fallbackFarm: farm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farm = context.watch<FarmProvider>().currentOrDraftFarm;
    final suitProv = context.watch<SuitabilityProvider>();

    // Calculate real dynamic assessment for the exact farm location and parameters
    final assessment = suitProv.assessment ??
        AgriPvCalculationService.generateSiteAssessment(farm);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => context.go(widget.readOnly ? '/farm-detail' : '/farm-details'),
        ),
        title: Text(
          'Site Suitability',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          if (suitProv.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (!widget.readOnly)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              tooltip: 'Recalculate from server',
              onPressed: () => context
                  .read<SuitabilityProvider>()
                  .recalculateSuitability(farm.id, fallbackFarm: farm),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper (Step 3: Suitability)
            if (!widget.readOnly)
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

                    // Live Map Preview of the mapped parcel (read-only, pan/zoom)
                    Container(
                      height: 180,
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
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: _farmCenter(farm),
                                  initialZoom: 16.0,
                                  maxZoom: 19.0,
                                  minZoom: 4.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                    maxZoom: 19,
                                  ),
                                  if (_farmPolygon(farm.boundary).length >= 3)
                                    PolygonLayer(
                                      polygons: [
                                        Polygon(
                                          points: _farmPolygon(farm.boundary),
                                          holePointsList: const [],
                                          color: const Color(0xFF22C55E).withValues(alpha: 0.30),
                                          borderColor: const Color(0xFF15803D),
                                          borderStrokeWidth: 2.5,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: GestureDetector(
                                onTap: widget.readOnly ? null : () {
                                  context.read<FarmProvider>().loadFarmToDraft(farm);
                                  context.go('/farm-location');
                                },
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
                                        '${farm.name} (${farm.location})',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (!widget.readOnly)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<FarmProvider>().loadFarmToDraft(farm);
                                    context.go('/farm-location');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Edit boundary',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
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
                                    activeColor: isDark ? const Color(0xFF00E676) : AppColors.primary,
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
                                        color: isDark ? const Color(0xFF00E676) : AppColors.primaryDark,
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
                                    color: isDark ? const Color(0xFF123520) : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1B5E30) : AppColors.primaryLight.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: isDark ? const Color(0xFF00E676) : AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        assessment.suitabilityStatus,
                                        style: AppTypography.labelSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFFB9F6CA) : AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  assessment.summary,
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
                      weightPercent: _factorWeights[factor.id],
                    )),
                    const SizedBox(height: 16),

                    // Agronomic Recommendations
                    Text(
                      'Agronomic Recommendations',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: assessment.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.solar, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            if (!widget.readOnly)
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

const _factorWeights = {'f1': 25, 'f2': 15, 'f3': 15, 'f4': 15, 'f5': 20, 'f6': 10};

LatLng _farmCenter(Farm farm) {
  final poly = _farmPolygon(farm.boundary);
  if (poly.isNotEmpty) {
    var lat = 0.0, lng = 0.0;
    for (final p in poly) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / poly.length, lng / poly.length);
  }
  if (farm.latitude != null && farm.longitude != null) {
    return LatLng(farm.latitude!, farm.longitude!);
  }
  return const LatLng(25.4358, 81.8463);
}

List<LatLng> _farmPolygon(List<List<double>> boundary) {
  return [
    for (final p in boundary)
      if (p.length >= 2) LatLng(p[0], p[1]),
  ];
}
