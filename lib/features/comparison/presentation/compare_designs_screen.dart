import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/design_provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../models/agri_pv_design.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';

class CompareDesignsScreen extends StatefulWidget {
  const CompareDesignsScreen({super.key});

  @override
  State<CompareDesignsScreen> createState() => _CompareDesignsScreenState();
}

class _CompareDesignsScreenState extends State<CompareDesignsScreen> {
  int _selectedDesignIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farm = context.read<FarmProvider>().selectedFarm;
      if (farm != null) {
        context.read<DesignProvider>().loadDesignsForFarm(farm.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final designProv = context.watch<DesignProvider>();
    final farm = context.watch<FarmProvider>().selectedFarm;
    final area = farm?.areaAcres ?? 2.35;
    final crop = farm?.crop ?? 'Wheat';

    final List<AgriPvDesign> designs = designProv.designs.length >= 2
        ? designProv.designs
        : [
            AgriPvCalculationService.generateDesign(
              id: 'variant_elevated',
              name: 'Elevated Stilt System',
              areaAcres: area,
              crop: crop,
              mountingType: MountingType.elevated,
              tiltDegrees: 20.0,
              orientation: PanelOrientation.south,
              rowSpacingMeters: 6.0,
              panelCoveragePercent: 40.0,
            ),
            AgriPvCalculationService.generateDesign(
              id: 'variant_tracker',
              name: 'Single-Axis Tracker',
              areaAcres: area,
              crop: crop,
              mountingType: MountingType.singleAxisTracker,
              tiltDegrees: 25.0,
              orientation: PanelOrientation.south,
              rowSpacingMeters: 7.5,
              panelCoveragePercent: 35.0,
            ),
            AgriPvCalculationService.generateDesign(
              id: 'variant_high_clearance',
              name: 'High Clearance Agro-PV',
              areaAcres: area,
              crop: crop,
              mountingType: MountingType.elevated,
              tiltDegrees: 18.0,
              orientation: PanelOrientation.south,
              rowSpacingMeters: 8.0,
              panelCoveragePercent: 32.0,
            ),
          ];
    final selectedIdx = _selectedDesignIndex < designs.length ? _selectedDesignIndex : 0;
    final selectedDesign = designs[selectedIdx];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Compare Up to 3 Designs',
          style: AppTypography.screenHeading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/agri-pv-design'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compare System Configurations',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Evaluate trade-offs between solar density, crop preservation, and economic returns.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // 3 Tab Cards (Design A, Design B, Design C)
                    Row(
                      children: List.generate(designs.length, (index) {
                        final d = designs[index];
                        final isSelected = _selectedDesignIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDesignIndex = index),
                            child: Container(
                              margin: EdgeInsets.only(
                                left: index == 0 ? 0 : 4,
                                right: index == designs.length - 1 ? 0 : 4,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primarySurface : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Miniature preview photo of solar farm
                                  Container(
                                    height: 44,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.asset(
                                        index == 0
                                            ? 'assets/images/design_a_elevated.jpg'
                                            : index == 1
                                                ? 'assets/images/design_b_tracker.jpg'
                                                : 'assets/images/design_c_greenhouse.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    d.name,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${d.pvCapacityKw.toInt()} kW',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Side-by-side comparison table card
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTableRow('PV Capacity', '150 kW', '250 kW', '300 kW', isHeader: false),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow('Cultivable Area', '85%', '78%', '70%'),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow('Annual Energy', '210 MWh', '350 MWh', '420 MWh'),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow('Crop Yield', '96%', '94%', '88%'),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Land Use (LER)',
                            '1.42',
                            '1.61',
                            '1.48',
                            highlightMiddle: true,
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow('Project Cost', '₹0.78 Cr', '₹1.25 Cr', '₹1.58 Cr'),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow('Payback Period', '6.8 yrs', '6.0 yrs', '5.6 yrs'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Selected Recommendation Badge (Matching Screen 13: "Design B / Best Overall Balance")
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              selectedDesign.name,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDesignIndex == 1
                                  ? 'Best Overall Balance'
                                  : _selectedDesignIndex == 0
                                      ? 'Lowest Initial Capex'
                                      : 'Maximum PV Capacity',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // "View Detailed Comparison" Button (Exact wording from Screen 13)
                    AppButton(
                      text: 'View Detailed Comparison',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/techno-economic'),
                      height: 44,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/shadow-simulation'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        context.read<DesignProvider>().selectDesign(selectedDesign);
                        context.go('/techno-economic');
                      },
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

  Widget _buildTableRow(
    String metric,
    String valA,
    String valB,
    String valC, {
    bool isHeader = false,
    bool highlightMiddle = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            metric,
            style: AppTypography.label.copyWith(
              fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            valA,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: _selectedDesignIndex == 0 ? FontWeight.w700 : FontWeight.w400,
              color: _selectedDesignIndex == 0 ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: _selectedDesignIndex == 1 ? AppColors.primarySurface : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              valB,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _selectedDesignIndex == 1 ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            valC,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: _selectedDesignIndex == 2 ? FontWeight.w700 : FontWeight.w400,
              color: _selectedDesignIndex == 2 ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
