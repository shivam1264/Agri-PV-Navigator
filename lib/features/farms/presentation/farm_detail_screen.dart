import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/painters/farm_boundary_painter.dart';
import '../../../services/storage/mock_data_service.dart';

class FarmDetailScreen extends StatelessWidget {
  const FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = MockDataService().farms.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          farm.name,
          style: AppTypography.screenHeading.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/farms'),
        ),
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
                        border: Border.all(color: AppColors.border, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
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
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '✓ ${farm.suitabilityScore}/100 Suitable',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Location', '${farm.location}, ${farm.state}'),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildDetailRow('Total Area', '${farm.areaAcres} acres'),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildDetailRow('Primary Crop', farm.crop),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildDetailRow('Soil Type', farm.soilType),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildDetailRow('Land Slope', farm.slope),
                          const Divider(height: 16, color: AppColors.borderLight),
                          _buildDetailRow('Grid Proximity', '${farm.gridProximityKm} km to substation'),
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

  Widget _buildDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(fontSize: 12),
        ),
        Text(
          val,
          style: AppTypography.cardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
