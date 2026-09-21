import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../services/pdf/report_pdf_service.dart';
import '../../../services/storage/local_db_service.dart';
import '../../../models/proposal_report.dart';
import '../../../providers/farm_provider.dart';

class ProposalReportScreen extends ConsumerStatefulWidget {
  const ProposalReportScreen({super.key});

  @override
  ConsumerState<ProposalReportScreen> createState() => _ProposalReportScreenState();
}

class _ProposalReportScreenState extends ConsumerState<ProposalReportScreen> {
  bool _isDownloading = false;
  String? _generatedFilePath;

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    try {
      final draft = ref.read(draftFarmProvider);
      final farm = draft.toFarm();
      final design = draft.design ?? draft.generateDesign();

      final file = await ReportPdfService.generateProposalReport(
        farm: farm,
        design: design,
      );

      // Save report record to SQLite
      final report = ProposalReport(
        id: const Uuid().v4(),
        title: 'Agri-PV Proposal — ${farm.name}',
        farmName: farm.name,
        date: DateTime.now(),
        type: ReportType.proposal,
        fileSize: '${(file.lengthSync() / 1024).toStringAsFixed(0)} KB',
        downloadUrl: file.path,
      );
      await LocalDbService().insertReport(report);
      // Refresh reports list
      ref.invalidate(reportsProvider);

      setState(() {
        _isDownloading = false;
        _generatedFilePath = file.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('PDF saved: ${file.path.split('/').last}')),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => _shareFile(file.path),
            ),
          ),
        );
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
    await Share.shareXFiles([XFile(filePath)], text: 'Agri-PV Proposal Report');
  }

  void _handleShare() async {
    if (_generatedFilePath != null) {
      await _shareFile(_generatedFilePath!);
    } else {
      await _handleDownload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.description_rounded,
                            size: 44,
                            color: AppColors.primary,
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
                    const SizedBox(height: 24),

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
                      onPressed: () => context.go('/success'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
