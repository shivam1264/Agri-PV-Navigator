import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../services/pdf/report_pdf_service.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/design_provider.dart';
import '../../../providers/report_provider.dart';

class ProposalReportScreen extends StatefulWidget {
  const ProposalReportScreen({super.key});

  @override
  State<ProposalReportScreen> createState() => _ProposalReportScreenState();
}

class _ProposalReportScreenState extends State<ProposalReportScreen> {
  bool _isDownloading = false;
  String? _generatedFilePath;

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    try {
      final farm = context.read<FarmProvider>().currentOrDraftFarm;
      final design = context.read<DesignProvider>().activeDesign ??
          AgriPvCalculationService.generateDesign(
            id: 'default',
            name: '${farm.name} System',
            areaAcres: farm.areaAcres,
            crop: farm.crop,
          );

      final filePath = await ReportPdfService.generateProposalReport(
        farm: farm,
        design: design,
      );

      setState(() {
        _isDownloading = false;
        _generatedFilePath = filePath;
      });

      if (mounted) {
        if (filePath == 'web_download') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF downloaded successfully!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('PDF saved: ${filePath.split('/').last}')),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Share',
                textColor: Colors.white,
                onPressed: () => _shareFile(filePath),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareFile(String filePath) async {
    if (filePath == 'web_download') return;
    await Share.shareXFiles([XFile(filePath)], text: 'Agri-PV Proposal Report');
  }

  void _handleShare() async {
    if (_generatedFilePath != null && _generatedFilePath != 'web_download') {
      await _shareFile(_generatedFilePath!);
    } else {
      await _handleDownload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>().currentOrDraftFarm;
    final design = context.watch<DesignProvider>().activeDesign ??
        AgriPvCalculationService.generateDesign(
          id: 'default',
          name: '${farm.name} System',
          areaAcres: farm.areaAcres,
          crop: farm.crop,
        );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper (Step 5: Preview)
            ProgressStepper(
              currentStep: 5,
              onStepTapped: (step) {
                if (step == 1) context.go('/farm-location');
                if (step == 2) context.go('/farm-details');
                if (step == 3) context.go('/site-suitability');
                if (step == 4) context.go('/agri-pv-design');
              },
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Document Badge Illustration
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.primaryLight.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.description_rounded,
                            size: 44,
                            color: isDark ? AppColors.accent : AppColors.primary,
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Your Proposal is Ready!',
                      style: AppTypography.screenHeading.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Download or share your detailed report.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // Key Performance Indicators Card
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                farm.name.isNotEmpty ? farm.name : 'Farm Overview',
                                style: AppTypography.cardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary, width: 1),
                                ),
                                child: Text(
                                  'LER: ${design.landEquivalentRatio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricTile('Capacity', '${design.pvCapacityKw.toInt()} kW'),
                              _buildMetricTile('Energy', '${design.annualEnergyMwh.toInt()} MWh'),
                              _buildMetricTile('Ground DLI', '${design.dliMolM2Day.toStringAsFixed(1)} mol'),
                              _buildMetricTile('Water Saved', '${(design.waterSavedLiters / 1000).toStringAsFixed(0)} kL'),
                            ],
                          ),
                          Divider(height: 16, color: theme.dividerColor),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricTile('LCOE', '₹${design.lcoePerKwh.toStringAsFixed(2)}/u'),
                              _buildMetricTile('IRR', '${design.irrPercent.toStringAsFixed(1)}%'),
                              _buildMetricTile('Payback', '${design.paybackYears.toStringAsFixed(1)} yrs'),
                              _buildMetricTile('CO₂ Saved', '${design.co2SavedTons.toInt()} T/y'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Proposal Contents Checklist Card
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCheckItem('Technical Summary'),
                          _buildCheckItem('System Design & Configuration'),
                          _buildCheckItem('Energy & Financial Analysis'),
                          _buildCheckItem('Crop Yield Assessment'),
                          _buildCheckItem('Environmental Impact (CO₂)'),
                          _buildCheckItem('Implementation Plan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Download & Share Actions
                    AppButton(
                      text: _isDownloading ? 'Generating PDF...' : 'Download PDF',
                      icon: Icons.download_rounded,
                      onPressed: _handleDownload,
                      isLoading: _isDownloading,
                      variant: AppButtonVariant.primary,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Share Report',
                      icon: Icons.share_rounded,
                      onPressed: _handleShare,
                      variant: AppButtonVariant.outline,
                    ),
                    const SizedBox(height: 20),
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
                      onPressed: () => context.go('/techno-economic'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        final farm = context.read<FarmProvider>().currentOrDraftFarm;
                        final design = context.read<DesignProvider>().activeDesign;
                        context.read<ReportProvider>().generateReport(
                          farmId: farm.id,
                          designId: design?.id ?? 'default_design',
                          farmName: farm.name,
                          type: 'proposal',
                        );
                        context.go('/success');
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

  Widget _buildCheckItem(String text) {
    final isDark = AppTheme.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: isDark ? AppColors.accent : AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    final isDark = AppTheme.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
