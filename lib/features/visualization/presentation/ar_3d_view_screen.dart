import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../engine/scene_3d_controller.dart';
import '../engine/design_configuration.dart';
import '../engine/camera_controller.dart';
import 'widgets/realtime_agri_pv_3d_viewport.dart';
import 'widgets/sun_time_slider.dart';

class Ar3dViewScreen extends StatefulWidget {
  const Ar3dViewScreen({super.key});

  @override
  State<Ar3dViewScreen> createState() => _Ar3dViewScreenState();
}

class _Ar3dViewScreenState extends State<Ar3dViewScreen> {
  final Scene3dController _sceneController = Scene3dController();
  bool _isArView = false;
  int _controlTab = 0; // 0: Sun/Time, 1: Structure (Tilt/Height/Spacing), 2: Crops

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final config = _sceneController.designConfig;
    final camera = _sceneController.cameraController;
    final sun = _sceneController.sunController;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '3D / AR Digital Twin Simulation',
          style: AppTypography.screenHeading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/agri-pv-design'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset 3D Scene',
            onPressed: () {
              config.resetToDefaults();
              camera.reset();
              sun.timeOfDayHour = 10.5;
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Mode Switcher [3D Digital Twin] | [AR Live View]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isArView = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isArView ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.threed_rotation_rounded,
                                    size: 16, color: !_isArView ? Colors.white : AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  '3D Digital Twin',
                                  style: TextStyle(
                                    color: !_isArView ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isArView = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isArView ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.view_in_ar_rounded,
                                    size: 16, color: _isArView ? Colors.white : AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'AR Field View',
                                  style: TextStyle(
                                    color: _isArView ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main 3D Viewport / AR Surface
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        if (_isArView)
                          // Live AR Camera Overlay Simulation
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/hero_agri_pv.jpg',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 36),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'AR Spatial Anchor Active',
                                      style: AppTypography.cardTitle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          const Shadow(color: Colors.black54, blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Text(
                                        'Superimposing ${config.panelHeight.toStringAsFixed(1)}m stilts and ${config.cropType.label} crop rows with true sun alignment.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          shadows: [
                                            const Shadow(color: Colors.black54, blurRadius: 4),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: const Text(
                                        'Surface Detected: Ground Plane (±1.5cm)',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          // Real-Time 3D Interactive Scene Viewport
                          RealtimeAgriPv3dViewport(
                            controller: _sceneController,
                            showSunGizmo: true,
                            enableGestures: true,
                          ),

                        // Camera View Preset Badges on Top-Left
                        if (!_isArView)
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
                                  _buildCameraPresetChip('3D Iso', CameraPreset.perspective),
                                  const SizedBox(width: 4),
                                  _buildCameraPresetChip('Top', CameraPreset.top),
                                  const SizedBox(width: 4),
                                  _buildCameraPresetChip('Side', CameraPreset.side),
                                  const SizedBox(width: 4),
                                  _buildCameraPresetChip('Sun', CameraPreset.sun),
                                ],
                              ),
                            ),
                          ),

                        // Interactive Camera Navigation Tools on Top-Right
                        if (!_isArView)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Column(
                              children: [
                                _buildToolButton(
                                  icon: Icons.rotate_right_rounded,
                                  tooltip: 'Orbit 45°',
                                  onTap: () => camera.onDragOrbit(35.0, 0.0),
                                ),
                                const SizedBox(height: 6),
                                _buildToolButton(
                                  icon: Icons.zoom_in_rounded,
                                  tooltip: 'Zoom In',
                                  onTap: () => camera.onPinchZoom(1.15),
                                ),
                                const SizedBox(height: 6),
                                _buildToolButton(
                                  icon: Icons.zoom_out_rounded,
                                  tooltip: 'Zoom Out',
                                  onTap: () => camera.onPinchZoom(0.85),
                                ),
                                const SizedBox(height: 6),
                                _buildToolButton(
                                  icon: Icons.center_focus_strong_rounded,
                                  tooltip: 'Reset View',
                                  onTap: () => camera.reset(),
                                ),
                              ],
                            ),
                          ),

                        // Live Real-Time 3D Parameters Indicator
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Tilt: ${config.panelTilt.toInt()}° | H: ${config.panelHeight.toStringAsFixed(1)}m | Spacing: ${config.rowSpacing.toStringAsFixed(1)}m | ${config.cropType.name.toUpperCase()}',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Parametric Control Tabs: [Sun & Shadows] | [Structure 3D] | [Crops]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildControlTab(0, 'Sun & Time', Icons.wb_sunny_rounded),
                  const SizedBox(width: 6),
                  _buildControlTab(1, '3D Structure', Icons.solar_power_rounded),
                  const SizedBox(width: 6),
                  _buildControlTab(2, 'Crops & Farm', Icons.eco_rounded),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Dynamic Control Panel Sheet
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_controlTab),
                    child: SingleChildScrollView(
                      child: _buildSelectedTabContent(config, sun),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/agri-pv-design'),
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Shadow Sim ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/shadow-simulation'),
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

  Widget _buildControlTab(int index, String title, IconData icon) {
    final isSelected = _controlTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _controlTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(DesignConfiguration config, dynamic sun) {
    if (_controlTab == 0) {
      // Tab 0: Sun Position & Shadow Scrubbing
      return SunTimeSlider(
        sunController: _sceneController.sunController,
        showPlayButton: true,
      );
    } else if (_controlTab == 1) {
      // Tab 1: Real-time 3D Structure Sliders
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Column(
          children: [
            // Tilt Slider
            _buildSliderRow(
              label: 'Panel Tilt Angle',
              valueStr: '${config.panelTilt.toInt()}°',
              value: config.panelTilt,
              min: 0.0,
              max: 45.0,
              divisions: 45,
              onChanged: (val) => config.panelTilt = val,
            ),
            const Divider(height: 12, color: AppColors.borderLight),
            // Height Slider
            _buildSliderRow(
              label: 'Mounting Stilt Height',
              valueStr: '${config.panelHeight.toStringAsFixed(1)} m',
              value: config.panelHeight,
              min: 1.5,
              max: 5.0,
              divisions: 35,
              onChanged: (val) => config.panelHeight = val,
            ),
            const Divider(height: 12, color: AppColors.borderLight),
            // Row Spacing Slider
            _buildSliderRow(
              label: 'Row Spacing (Pitch)',
              valueStr: '${config.rowSpacing.toStringAsFixed(1)} m',
              value: config.rowSpacing,
              min: 3.0,
              max: 12.0,
              divisions: 18,
              onChanged: (val) => config.rowSpacing = val,
            ),
          ],
        ),
      );
    } else {
      // Tab 2: Crop Type Selection & 3D Row Density
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select 3D Under-Canopy Crop',
              style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: AgriCrop3dType.values.map((crop) {
                final isSelected = config.cropType == crop;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => config.cropType = crop,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          crop.name[0].toUpperCase() + crop.name.substring(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Number of Panel Rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Solar Array Rows:', style: AppTypography.bodySmall),
                Row(
                  children: [2, 3, 4, 5].map((r) {
                    final isSel = config.panelRows == r;
                    return GestureDetector(
                      onTap: () => config.panelRows = r,
                      child: Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$r',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSliderRow({
    required String label,
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(valueStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ],
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.borderLight,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPresetChip(String label, CameraPreset preset) {
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

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
