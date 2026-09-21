import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../providers/economics_provider.dart';
import '../../../providers/design_provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../models/agri_pv_design.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';

class TechnoEconomicScreen extends StatefulWidget {
  const TechnoEconomicScreen({super.key});

  @override
  State<TechnoEconomicScreen> createState() => _TechnoEconomicScreenState();
}

class _TechnoEconomicScreenState extends State<TechnoEconomicScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeDesign = context.read<DesignProvider>().activeDesign;
      if (activeDesign != null) {
        context.read<EconomicsProvider>().loadEconomics(activeDesign.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final econProv = context.watch<EconomicsProvider>();
    final activeDesign = context.watch<DesignProvider>().activeDesign;
    final farm = context.watch<FarmProvider>().selectedFarm;
    final farmArea = farm?.areaAcres ?? 2.35;
    final farmCrop = farm?.crop ?? 'Wheat';

    final design = activeDesign ??
        AgriPvCalculationService.generateDesign(
          id: 'default',
          name: '${farm?.name ?? "My Farm"} System',
          areaAcres: farmArea,
          crop: farmCrop,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Techno-Economic Analysis',
          style: AppTypography.screenHeading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/compare-designs'),
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
                      'Financial & Energy Projections',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated 25-year lifetime metrics for ${design.name} (${design.pvCapacityKw.toInt()} kW ${design.mountingType.label}).',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Primary Metrics Card (Live Calculated Metrics)
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildMetricRow(
                            icon: Icons.solar_power_rounded,
                            color: AppColors.solar,
                            label: 'PV Capacity',
                            value: '${design.pvCapacityKw.toInt()} kW',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.bolt_rounded,
                            color: AppColors.primary,
                            label: 'Annual Energy',
                            value: '${design.annualEnergyMwh.toInt()} MWh/year',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.currency_rupee_rounded,
                            color: AppColors.primaryLight,
                            label: 'Project Cost',
                            value: '₹ ${design.projectCostCr.toStringAsFixed(2)} Crore',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.trending_up_rounded,
                            color: AppColors.primary,
                            label: 'Annual Revenue',
                            value: '₹ ${(design.pvCapacityKw * 0.05).toStringAsFixed(1)} Lakh/year',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.timelapse_rounded,
                            color: AppColors.water,
                            label: 'Payback Period',
                            value: '${design.paybackYears.toStringAsFixed(1)} years',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.soil,
                            label: 'Net Present Value (NPV)',
                            value: '₹ ${design.npvLakhs.toStringAsFixed(1)} Lakh',
                            subtitle: '@ 8% discount rate',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.percent_rounded,
                            color: const Color(0xFF16A34A),
                            label: 'Internal Rate of Return (IRR)',
                            value: '${design.irrPercent.toStringAsFixed(1)}%',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.price_check_rounded,
                            color: AppColors.accent,
                            label: 'Levelized Cost of Energy (LCOE)',
                            value: '₹ ${design.lcoePerKwh.toStringAsFixed(2)} / kWh',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.water_drop_rounded,
                            color: const Color(0xFF0284C7),
                            label: 'Agricultural Water Saved',
                            value: '${(design.waterSavedLiters / 1000).toStringAsFixed(0)} kL/year',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.forest_rounded,
                            color: AppColors.primaryDark,
                            label: 'CO₂ Saved',
                            value: '~${design.co2SavedTons.toInt()} tons/year',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // "View Financial Details" Button (Screen 14 specification)
                    AppButton(
                      text: 'View Financial Details',
                      variant: AppButtonVariant.primary,
                      onPressed: () {},
                      height: 46,
                    ),
                    const SizedBox(height: 16),

                    // Capex Cost Breakdown
                    Text(
                      'Capex Cost Breakdown',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Segmented bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 14,
                              child: Row(
                                children: [
                                  Expanded(flex: 45, child: Container(color: AppColors.primary)),
                                  Expanded(flex: 26, child: Container(color: AppColors.solar)),
                                  Expanded(flex: 14, child: Container(color: AppColors.water)),
                                  Expanded(flex: 15, child: Container(color: AppColors.soil)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLegendItem('PV Modules (Tier 1 Bifacial)', '45%', AppColors.primary),
                          const SizedBox(height: 6),
                          _buildLegendItem('Elevated Steel Mounting (2.8m)', '26%', AppColors.solar),
                          const SizedBox(height: 6),
                          _buildLegendItem('Inverters & Transformers', '14%', AppColors.water),
                          const SizedBox(height: 6),
                          _buildLegendItem('Installation & Grid Line', '15%', AppColors.soil),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disclaimer Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Preliminary estimate. Actual project values require detailed site survey and vendor quotations.',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      onPressed: () => context.go('/compare-designs'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/proposal-report'),
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

  Widget _buildMetricRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.cardTitle.copyWith(fontSize: 14),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodySmall.copyWith(fontSize: 12),
          ),
        ),
        Text(
          percent,
          style: AppTypography.cardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
