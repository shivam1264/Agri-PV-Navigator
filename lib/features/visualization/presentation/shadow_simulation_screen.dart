import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../engine/scene_3d_controller.dart';
import '../engine/camera_controller.dart';
import 'widgets/realtime_agri_pv_3d_viewport.dart';
import 'widgets/sun_time_slider.dart';

class ShadowSimulationScreen extends StatefulWidget {
  const ShadowSimulationScreen({super.key});

  @override
  State<ShadowSimulationScreen> createState() => _ShadowSimulationScreenState();
}

class _ShadowSimulationScreenState extends State<ShadowSimulationScreen> {
  final Scene3dController _sceneController = Scene3dController();

  @override
  void initState() {
    super.initState();
    _sceneController.cameraController.setPreset(CameraPreset.perspective);
    _sceneController.addListener(_onSceneUpdate);
  }

  @override
  void dispose() {
    _sceneController.removeListener(_onSceneUpdate);
    _sceneController.dispose();
    super.dispose();
  }

  void _onSceneUpdate() {
    if (mounted) setState(() {});
  }

  // Calculate dynamic shaded area % based on time of day and solar elevation
  int get _shadedAreaPercent {
    final altDeg = _sceneController.sunController.solarAltitudeDeg;
    if (altDeg <= 5) return 48;
    // Lower altitude = longer shadows
    final shade = (1.0 - (altDeg / 75.0)) * 32.0 + 14.0;
    return shade.round().clamp(14, 52);
  }

  // PAR light penetration to understory crops
  int get _parLightPenetrationPercent {
    return (100 - _shadedAreaPercent * 0.75).round().clamp(60, 95);
  }

  @override
  Widget build(BuildContext context) {
    final sun = _sceneController.sunController;
    final camera = _sceneController.cameraController;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '3D Solar & Shadow Simulation',
          style: AppTypography.screenHeading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/ar-3d-view'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dynamic Real-Time 3D Shadow Viewport
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      children: [
                        // Real-Time 3D Farm & Dynamic Shadow Viewport
                        RealtimeAgriPv3dViewport(
                          controller: _sceneController,
                          showSunGizmo: true,
                          enableGestures: true,
                        ),

                        // Camera Preset Bar on Top Left
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCameraChip('3D Iso', CameraPreset.perspective),
                                const SizedBox(width: 4),
                                _buildCameraChip('Top Heatmap', CameraPreset.top),
                                const SizedBox(width: 4),
                                _buildCameraChip('Side Stilt', CameraPreset.side),
                                const SizedBox(width: 4),
                                _buildCameraChip('Sun Angle', CameraPreset.sun),
                              ],
                            ),
                          ),
                        ),

                        // Live Sunlight & Shadow Angle Badge
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBC02D), size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Alt: ${sun.solarAltitudeDeg.toInt()}° | Az: ${sun.solarAzimuthDeg.toInt()}°',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Touch Instruction Tag
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Drag to rotate 3D view | Scrub time slider below',
                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Time of Day Scrubber
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SunTimeSlider(
                sunController: sun,
                showPlayButton: true,
              ),
            ),
            const SizedBox(height: 8),

            // Microclimate & Crop Shading Analysis Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAnalysisMetric(
                          icon: Icons.brightness_medium_rounded,
                          title: 'PAR Light',
                          value: '$_parLightPenetrationPercent%',
                          color: AppColors.primary,
                        ),
                        _buildAnalysisMetric(
                          icon: Icons.opacity_rounded,
                          title: 'Moisture Saved',
                          value: '+22%',
                          color: AppColors.water,
                        ),
                        _buildAnalysisMetric(
                          icon: Icons.thermostat_rounded,
                          title: 'Heat Reduction',
                          value: '-3.6 °C',
                          color: AppColors.success,
                        ),
                        _buildAnalysisMetric(
                          icon: Icons.brightness_6_rounded,
                          title: 'Crop Shading',
                          value: '$_shadedAreaPercent%',
                          color: AppColors.solar,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ 3D / AR View',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/ar-3d-view'),
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'View Proposal ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/proposal-report'),
                      height: 44,
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
          if (index == 3) context.go('/proposal-report');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildCameraChip(String label, CameraPreset preset) {
    final isSelected = _sceneController.cameraController.currentPreset == preset;
    return GestureDetector(
      onTap: () => _sceneController.cameraController.setPreset(
        preset,
        currentSunAzimuthRad: _sceneController.sunController.solarAzimuthRad,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisMetric({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
