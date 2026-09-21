import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../providers/farm_provider.dart';
import '../../../services/calculation/agri_pv_optimizer_service.dart';

class CompareDesignsScreen extends ConsumerStatefulWidget {
  const CompareDesignsScreen({super.key});

  @override
  ConsumerState<CompareDesignsScreen> createState() => _CompareDesignsScreenState();
}

class _CompareDesignsScreenState extends ConsumerState<CompareDesignsScreen> {
  int _selectedDesignIndex = 1; // Default is Design B (Best overall balance)

  @override
  Widget build(BuildContext context) {
    final draftFarm = ref.watch(draftFarmProvider);
    final designs = AgriPvOptimizerService.generateAllStrategies(
      areaAcres: draftFarm.areaAcres > 0 ? draftFarm.areaAcres : 2.35,
      crop: draftFarm.crop.isNotEmpty ? draftFarm.crop : 'Wheat',
    );
    final selectedDesign = designs[_selectedDesignIndex];

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
                          _buildTableRow(
                            'PV Capacity',
                            '${designs[0].pvCapacityKw.toStringAsFixed(0)} kW',
                            '${designs[1].pvCapacityKw.toStringAsFixed(0)} kW',
                            '${designs[2].pvCapacityKw.toStringAsFixed(0)} kW',
                            isHeader: false,
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Cultivable Area',
                            '${designs[0].cultivableAreaPercent.toStringAsFixed(0)}%',
                            '${designs[1].cultivableAreaPercent.toStringAsFixed(0)}%',
                            '${designs[2].cultivableAreaPercent.toStringAsFixed(0)}%',
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Annual Energy',
                            '${designs[0].annualEnergyMwh.toStringAsFixed(0)} MWh',
                            '${designs[1].annualEnergyMwh.toStringAsFixed(0)} MWh',
                            '${designs[2].annualEnergyMwh.toStringAsFixed(0)} MWh',
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Crop Yield',
                            '${designs[0].cropYieldPercent.toStringAsFixed(0)}%',
                            '${designs[1].cropYieldPercent.toStringAsFixed(0)}%',
                            '${designs[2].cropYieldPercent.toStringAsFixed(0)}%',
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Land Use (LER)',
                            designs[0].landEquivalentRatio.toStringAsFixed(2),
                            designs[1].landEquivalentRatio.toStringAsFixed(2),
                            designs[2].landEquivalentRatio.toStringAsFixed(2),
                            highlightMiddle: true,
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'LCOE (Cost/kWh)',
                            '₹${designs[0].lcoePerKwh.toStringAsFixed(2)}',
                            '₹${designs[1].lcoePerKwh.toStringAsFixed(2)}',
                            '₹${designs[2].lcoePerKwh.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Water Conserved',
                            '${(designs[0].waterSavedLiters / 1000).toStringAsFixed(0)} kL/y',
                            '${(designs[1].waterSavedLiters / 1000).toStringAsFixed(0)} kL/y',
                            '${(designs[2].waterSavedLiters / 1000).toStringAsFixed(0)} kL/y',
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Project Cost',
                            '₹${designs[0].projectCostCr.toStringAsFixed(2)} Cr',
                            '₹${designs[1].projectCostCr.toStringAsFixed(2)} Cr',
                            '₹${designs[2].projectCostCr.toStringAsFixed(2)} Cr',
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildTableRow(
                            'Payback Period',
                            '${designs[0].paybackYears.toStringAsFixed(1)} yrs',
                            '${designs[1].paybackYears.toStringAsFixed(1)} yrs',
                            '${designs[2].paybackYears.toStringAsFixed(1)} yrs',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Selected Recommendation Badge
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
                                  ? 'Best Overall Balance (Peak LER ${selectedDesign.landEquivalentRatio})'
                                  : _selectedDesignIndex == 0
                                      ? 'Lowest Crop Stress (96%+ Yield)'
                                      : 'Maximum PV Power (${selectedDesign.pvCapacityKw.toStringAsFixed(0)} kW)',
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

                    // "View Detailed Comparison" Button
                    AppButton(
                      text: 'View Detailed Comparison',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        ref.read(draftFarmProvider.notifier).setDesign(selectedDesign);
                        context.go('/techno-economic');
                      },
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
                        ref.read(draftFarmProvider.notifier).setDesign(selectedDesign);
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
