import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/report_provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/design_provider.dart';
import '../../../models/proposal_report.dart';
import '../../../services/pdf/report_pdf_service.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Designs', 'Financial', 'Impact'];

  static const _categoryColors = [
    Color(0xFF10B981),  // All → green
    Color(0xFF3B82F6),  // Designs → blue
    Color(0xFFF59E0B),  // Financial → amber
    Color(0xFF6366F1),  // Impact → indigo
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportProv = context.watch<ReportProvider>();
    final farmProv = context.watch<FarmProvider>();
    final allReports = List<ProposalReport>.from(reportProv.reports);

    // Resolve active farm or fallback farm
    final fallbackFarm = farmProv.selectedFarm ??
        (farmProv.farms.isNotEmpty ? farmProv.farms.first : farmProv.currentOrDraftFarm);
    final targetFarms = farmProv.farms.isNotEmpty ? farmProv.farms : [fallbackFarm];

    // Ensure strictly ONE comprehensive proposal report per farm
    for (final farm in targetFarms) {
      final baseId = farm.id.isNotEmpty ? farm.id : 'farm_${farm.name.hashCode}';
      final repId = 'rep_prop_$baseId';

      if (reportProv.isDeleted(repId) || reportProv.isDeleted(baseId)) continue;

      if (!allReports.any((r) =>
          r.farmName.toLowerCase() == farm.name.toLowerCase() ||
          r.id == repId ||
          r.id == baseId)) {
        allReports.add(ProposalReport(
          id: repId,
          title: '${farm.name} Agri-PV Comprehensive Feasibility & Proposal',
          farmName: farm.name,
          date: DateTime.now(),
          type: ReportType.proposal,
          fileSize: '1.8 MB',
          downloadUrl: '/api/reports/download/proposal',
        ));
      }
    }

    final filtered = allReports.where((r) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Designs') {
        return r.type == ReportType.proposal || r.type == ReportType.technical;
      }
      if (_selectedCategory == 'Financial') {
        return r.type == ReportType.financial || r.type == ReportType.proposal;
      }
      if (_selectedCategory == 'Impact') {
        return r.type == ReportType.environmental || r.type == ReportType.proposal;
      }
      return true;
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Reports', style: AppTypography.screenHeading.copyWith(fontSize: 20)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? theme.dividerColor : const Color(0xFFE2E8F0)),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filter Chips ──
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;
                  final color = _categoryColors[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color : (isDark ? theme.cardColor : Colors.white),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected ? color : (isDark ? theme.dividerColor : const Color(0xFFE2E8F0)),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                            : [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── Count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} report${filtered.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Reports List ──
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open_rounded, size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text('No $_selectedCategory reports found', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _ReportCard(
                        report: filtered[index],
                        color: _categoryColors[index % _categoryColors.length],
                      ),
                    ),
            ),

            BottomNavBar(
              currentIndex: 3,
              onTap: (i) {
                if (i == 0) context.go('/home');
                if (i == 1) context.go('/farms');
                if (i == 2) context.go('/farm-location');
                if (i == 3) context.go('/reports');
                if (i == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ProposalReport report;
  final Color color;

  const _ReportCard({required this.report, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? theme.dividerColor : const Color(0xFFE8F5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportDetailScreen(report: report),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // PDF icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: isDark ? 0.35 : 0.2)),
                  ),
                  child: Icon(Icons.description_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.agriculture_outlined,
                                size: 12,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                report.farmName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(report.date),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delete Button
                    GestureDetector(
                      onTap: () => _handleDeleteReport(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C1616) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF5C2626) : const Color(0xFFFECACA),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      ),
                    ),
                    // Download Button
                    GestureDetector(
                      onTap: () => _handleDirectDownload(context),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PDF',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2721) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteReport(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report?'),
        content: Text('Are you sure you want to delete the report for "${report.farmName}"? This action cannot be undone.'),
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

    if (confirmed == true && context.mounted) {
      await context.read<ReportProvider>().deleteReport(report.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Report for "${report.farmName}" deleted.')),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleDirectDownload(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Downloading "${report.title}"...'),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final farmProv = context.read<FarmProvider>();
      final matched = farmProv.farms.where(
        (f) => f.name.toLowerCase() == report.farmName.toLowerCase() ||
               f.id == report.id.replaceFirst('rep_', ''),
      );
      final farm = matched.isNotEmpty
          ? matched.first
          : (farmProv.selectedFarm ?? farmProv.currentOrDraftFarm);
      final design = context.read<DesignProvider>().activeDesign ??
          AgriPvCalculationService.generateDesign(
            id: 'design_${farm.id}',
            name: '${farm.name} Agri-PV System',
            areaAcres: farm.areaAcres > 0 ? farm.areaAcres : 2.5,
            crop: farm.crop.isNotEmpty ? farm.crop : 'Wheat',
          );

      final fallbackBytes = await ReportPdfService.buildProposalPdfBytes(farm: farm, design: design);
      if (!context.mounted) return;
      final path = await context.read<ReportProvider>().downloadAndOpenReport(report, fallbackBytes: fallbackBytes);

      if (path != null && context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saved: ${report.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(path),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
