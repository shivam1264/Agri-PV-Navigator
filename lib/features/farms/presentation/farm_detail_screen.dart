import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../shared/painters/farm_boundary_painter.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/report_provider.dart';

class FarmDetailScreen extends StatelessWidget {
  const FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmProvider = context.watch<FarmProvider>();
    final farm = farmProvider.selectedFarm ?? (farmProvider.farms.isNotEmpty ? farmProvider.farms.first : null);

    if (farm == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Farm Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/farms'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No farm selected'),
              const SizedBox(height: 12),
              SizedBox(
                width: 160,
                child: AppButton(
                  text: 'Go to My Farms',
                  onPressed: () => context.go('/farms'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          farm.name,
          style: AppTypography.screenHeading.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/farms'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Delete Farm',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Farm?'),
                  content: Text('Are you sure you want to delete "${farm.name}"? This action cannot be undone.'),
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
                await context.read<FarmProvider>().deleteFarm(farm.id);
                if (context.mounted) {
                  context.read<ReportProvider>().deleteReport('rep_prop_${farm.id}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Farm "${farm.name}" deleted.')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF1E293B),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.go('/farms');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Satellite Farm Polygon Box
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? theme.dividerColor : AppColors.border,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.35) : AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: CustomPaint(
                          painter: FarmBoundaryPainter(
                            areaAcres: farm.areaAcres,
                            showPins: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Farm Summary Card
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                farm.name,
                                style: AppTypography.screenHeading.copyWith(fontSize: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF123520) : AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF1B5E30) : AppColors.primaryLight.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '✓ ${farm.suitabilityScore}/100 Suitable',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFF00E676) : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Location', '${farm.location}, ${farm.state}', isDark),
                          Divider(height: 16, color: isDark ? theme.dividerColor : AppColors.borderLight),
                          _buildDetailRow('Total Area', '${farm.areaAcres} acres', isDark),
                          Divider(height: 16, color: isDark ? theme.dividerColor : AppColors.borderLight),
                          _buildDetailRow('Primary Crop', farm.crop, isDark),
                          Divider(height: 16, color: isDark ? theme.dividerColor : AppColors.borderLight),
                          _buildDetailRow('Soil Type', farm.soilType, isDark),
                          Divider(height: 16, color: isDark ? theme.dividerColor : AppColors.borderLight),
                          _buildDetailRow('Land Slope', farm.slope, isDark),
                          Divider(height: 16, color: isDark ? theme.dividerColor : AppColors.borderLight),
                          _buildDetailRow('Grid Proximity', '${farm.gridProximityKm} km to substation', isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Action Buttons
                    Text(
                      'Farm Actions',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'View Analysis',
                            variant: AppButtonVariant.outline,
                            icon: Icons.analytics_outlined,
                            onPressed: () => context.go('/site-suitability'),
                            height: 44,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            text: 'View Design',
                            variant: AppButtonVariant.primary,
                            icon: Icons.solar_power_rounded,
                            onPressed: () => context.go('/agri-pv-design'),
                            height: 44,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: '3D Simulation',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.view_in_ar_rounded,
                            onPressed: () => context.go('/ar-3d-view'),
                            height: 44,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            text: 'View Reports',
                            variant: AppButtonVariant.outline,
                            icon: Icons.description_outlined,
                            onPressed: () => context.go('/reports'),
                            height: 44,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) context.go('/home');
                if (index == 1) context.go('/farms');
                if (index == 2) context.go('/farm-location');
                if (index == 3) context.go('/reports');
                if (index == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
