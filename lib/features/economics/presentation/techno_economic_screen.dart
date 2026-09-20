import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../services/storage/mock_data_service.dart';

class TechnoEconomicScreen extends StatelessWidget {
  const TechnoEconomicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final econ = MockDataService().defaultEconomicAssessment;

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
                      'Estimated 25-year lifetime metrics for 250 kW elevated stilt Agri-PV installation.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Primary Metrics Card (7 key metrics)
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildMetricRow(
                            icon: Icons.solar_power_rounded,
                            color: AppColors.solar,
                            label: 'PV Capacity',
                            value: '${econ.pvCapacityKw.toInt()} kW',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.bolt_rounded,
                            color: AppColors.primary,
                            label: 'Annual Energy',
                            value: '${econ.annualEnergyMwh.toInt()} MWh/year',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.currency_rupee_rounded,
                            color: AppColors.primaryLight,
                            label: 'Project Cost',
                            value: '₹ ${econ.projectCostCr.toStringAsFixed(2)} Crore',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.trending_up_rounded,
                            color: AppColors.primary,
                            label: 'Annual Revenue',
                            value: '₹ ${econ.annualRevenueLakhs.toStringAsFixed(1)} Lakh/year',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.timelapse_rounded,
                            color: AppColors.water,
                            label: 'Payback Period',
                            value: '${econ.paybackPeriodYears.toStringAsFixed(1)} years',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.soil,
                            label: 'Net Present Value (NPV)',
                            value: '₹ ${econ.netPresentValueLakhs.toStringAsFixed(1)} Lakh',
                            subtitle: '@ 8% discount rate',
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          _buildMetricRow(
                            icon: Icons.forest_rounded,
                            color: AppColors.primaryDark,
                            label: 'CO₂ Saved',
                            value: '~${econ.co2SavedTons.toInt()} tons/year',
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
