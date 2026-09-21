import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/agri_pv_design.dart';
import '../../../models/farm.dart';
import '../../../models/proposal_report.dart';
import '../../../providers/design_provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';
import '../../../services/pdf/report_pdf_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final ProposalReport? report;

  const ReportDetailScreen({super.key, this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDownloading = false;
  Uint8List? _pdfBytes;
  bool _isLoadingPdf = true;
  String? _pdfError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdf();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Farm _resolveFarm(BuildContext context) {
    final farmProv = context.read<FarmProvider>();
    if (widget.report != null) {
      final matched = farmProv.farms.where(
        (f) => f.name.toLowerCase() == widget.report!.farmName.toLowerCase() ||
               widget.report!.id.contains(f.id),
      );
      if (matched.isNotEmpty) return matched.first;
    }
    final base = farmProv.selectedFarm ??
        (farmProv.farms.isNotEmpty ? farmProv.farms.first : farmProv.currentOrDraftFarm);
    if (widget.report != null && widget.report!.farmName.isNotEmpty) {
      return base.copyWith(name: widget.report!.farmName);
    }
    return base;
  }

  AgriPvDesign _resolveDesign(BuildContext context, Farm farm) {
    final designProv = context.read<DesignProvider>();
    if (designProv.activeDesign != null) return designProv.activeDesign!;
    return AgriPvCalculationService.generateDesign(
      id: 'design_${farm.id}',
      name: '${farm.name} Agri-PV System',
      areaAcres: farm.areaAcres > 0 ? farm.areaAcres : 2.5,
      crop: farm.crop.isNotEmpty ? farm.crop : 'Wheat',
    );
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoadingPdf = true;
      _pdfError = null;
    });

    try {
      final farm = _resolveFarm(context);
      final design = _resolveDesign(context, farm);
      final bytes = await ReportPdfService.buildProposalPdfBytes(farm: farm, design: design);
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoadingPdf = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pdfError = e.toString();
          _isLoadingPdf = false;
        });
      }
    }
  }

  Future<void> _downloadReport() async {
    if (_pdfBytes == null) return;
    setState(() => _isDownloading = true);

    try {
      final farm = _resolveFarm(context);
      final sanitizedName = farm.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final filename = 'AgriPV_Report_$sanitizedName.pdf';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(_pdfBytes!);

      if (mounted) {
        setState(() => _isDownloading = false);
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saved: $filename',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareReport() async {
    if (_pdfBytes == null) return;
    final farm = _resolveFarm(context);
    final sanitizedName = farm.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filename = 'AgriPV_Report_$sanitizedName.pdf';

    try {
      await Printing.sharePdf(bytes: _pdfBytes!, filename: filename);
    } catch (e) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$filename');
        if (!await file.exists()) {
          await file.writeAsBytes(_pdfBytes!);
        }
        await Share.shareXFiles([XFile(file.path)], text: 'Agri-PV Report — ${farm.name}');
      } catch (_) {}
    }
  }

  Future<void> _confirmDeleteReport() async {
    final farm = _resolveFarm(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report?'),
        content: Text('Are you sure you want to delete this report for "${farm.name}"? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repId = widget.report?.id ?? 'rep_prop_${farm.id}';
      await context.read<ReportProvider>().deleteReport(repId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Report for "${farm.name}" deleted.')),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/reports');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farm = _resolveFarm(context);
    final design = _resolveDesign(context, farm);
    final reportTitle = widget.report?.title ?? '${farm.name} Agri-PV Proposal';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/reports');
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF141B17) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/reports');
              }
            },
          ),
          title: Text(
            reportTitle,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.screenHeading.copyWith(fontSize: 15, height: 1.2),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              tooltip: 'Share',
              onPressed: _pdfBytes != null ? _shareReport : null,
            ),
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.download_rounded, size: 22),
              tooltip: 'Download PDF',
              onPressed: _pdfBytes != null && !_isDownloading ? _downloadReport : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
              tooltip: 'Delete Report',
              onPressed: _confirmDeleteReport,
            ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            indicatorWeight: 2.5,
            tabs: const [
              Tab(
                icon: Icon(Icons.picture_as_pdf_rounded, size: 18),
                text: 'PDF Preview',
              ),
              Tab(
                icon: Icon(Icons.analytics_outlined, size: 18),
                text: 'Summary',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Interactive PDF Document Viewer ──
            _buildPdfPreviewTab(isDark, farm),

            // ── Tab 2: Visual Summary & Insights ──
            _buildSummaryTab(isDark, farm, design),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141B17) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? theme.dividerColor : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pdfBytes != null ? _shareReport : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? const Color(0xFF2E4034) : const Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _pdfBytes != null && !_isDownloading ? _downloadReport : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(_isDownloading ? 'Saving...' : 'Download PDF Report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPreviewTab(bool isDark, Farm farm) {
    if (_isLoadingPdf) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Rendering high-resolution PDF...',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    if (_pdfError != null || _pdfBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 14),
              Text(
                'Could not load PDF document\n${_pdfError ?? ""}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    return PdfPreview(
      build: (format) => _pdfBytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      pdfFileName: 'AgriPV_Report_${farm.name.replaceAll(' ', '_')}.pdf',
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      scrollViewDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1411) : const Color(0xFFF1F5F9),
      ),
    );
  }

  Widget _buildSummaryTab(bool isDark, Farm farm, AgriPvDesign design) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B3826), const Color(0xFF122318)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2E6340) : const Color(0xFFC8E6C9),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${farm.location} • ${farm.areaAcres.toStringAsFixed(1)} Acres • ${farm.crop}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'System Specifications',
            style: AppTypography.screenHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          _metricGrid(isDark, [
            _MetricItem('Capacity', '${design.pvCapacityKw.toStringAsFixed(0)} kW', Icons.bolt_rounded, AppColors.primary),
            _MetricItem('Annual Energy', '${design.annualEnergyMwh.toStringAsFixed(0)} MWh', Icons.electric_meter_rounded, const Color(0xFF3B82F6)),
            _MetricItem('Panel Height', '${design.panelHeightMeters.toStringAsFixed(1)} m', Icons.height_rounded, const Color(0xFFF59E0B)),
            _MetricItem('Tilt Angle', '${design.tiltDegrees.toInt()}° South', Icons.rotate_right_rounded, const Color(0xFF8B5CF6)),
          ]),
          const SizedBox(height: 20),

          Text(
            'Financial Projections (25-Year)',
            style: AppTypography.screenHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          _metricGrid(isDark, [
            _MetricItem('Est. Cost', '₹${(design.projectCostCr).toStringAsFixed(2)} Cr', Icons.currency_rupee_rounded, const Color(0xFFEC4899)),
            _MetricItem('25-Yr NPV', '₹${(design.npvLakhs).toStringAsFixed(1)} L', Icons.trending_up_rounded, const Color(0xFF10B981)),
            _MetricItem('Payback Period', '${design.paybackYears.toStringAsFixed(1)} Years', Icons.schedule_rounded, const Color(0xFFF97316)),
            _MetricItem('IRR', '${design.irrPercent.toStringAsFixed(1)}%', Icons.pie_chart_rounded, const Color(0xFF06B6D4)),
          ]),
          const SizedBox(height: 20),

          Text(
            'Environmental & Crop Yield Impact',
            style: AppTypography.screenHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          _metricGrid(isDark, [
            _MetricItem('CO₂ Saved', '${design.co2SavedTons.toStringAsFixed(0)} Tons/yr', Icons.eco_rounded, const Color(0xFF10B981)),
            _MetricItem('Crop Yield', '${design.cropYieldPercent.toStringAsFixed(0)}% Retained', Icons.agriculture_rounded, const Color(0xFFEAB308)),
            _MetricItem('Water Saved', '${(design.waterSavedLiters / 1000).toStringAsFixed(0)}k L/yr', Icons.water_drop_rounded, const Color(0xFF0EA5E9)),
            _MetricItem('Land Productivity', '${design.landEquivalentRatio.toStringAsFixed(2)}x LER', Icons.landscape_rounded, const Color(0xFF84CC16)),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metricGrid(bool isDark, List<_MetricItem> items) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final m = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A221E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF26332C) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(m.icon, color: m.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem(this.title, this.value, this.icon, this.color);
}
