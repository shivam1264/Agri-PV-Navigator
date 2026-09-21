import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/clearance_badge.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../services/calculation/agri_pv_calculation_service.dart';
import '../../../services/calculation/agri_pv_optimizer_service.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/design_provider.dart';
import '../../../models/agri_pv_design.dart';
import '../../visualization/engine/scene_3d_controller.dart';
import '../../visualization/engine/camera_controller.dart';
import '../../visualization/presentation/widgets/realtime_agri_pv_3d_viewport.dart';

class AgriPvSystemDesignScreen extends StatefulWidget {
  const AgriPvSystemDesignScreen({super.key});

  @override
  State<AgriPvSystemDesignScreen> createState() => _AgriPvSystemDesignScreenState();
}

class _AgriPvSystemDesignScreenState extends State<AgriPvSystemDesignScreen> {
  MountingType _mountingType = MountingType.elevated;
  double _tiltDegrees = 20.0;
  PanelOrientation _orientation = PanelOrientation.south;
  double _rowSpacingMeters = 6.0;
  double _panelCoveragePercent = 40.0;
  final Scene3dController _scene3dController = Scene3dController();

  @override
  void initState() {
    super.initState();
    _scene3dController.cameraController.setPreset(CameraPreset.perspective);
    _sync3dConfig();
  }

  void _sync3dConfig() {
    final cfg = _scene3dController.designConfig;
    cfg.panelTilt = _tiltDegrees;
    cfg.panelHeight = _mountingType.defaultHeight;
    cfg.rowSpacing = _rowSpacingMeters;
  }

  @override
  void dispose() {
    _scene3dController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>().selectedFarm;
    final farmArea = farm?.areaAcres ?? 2.35;
    final farmCrop = farm?.crop ?? 'Wheat';
    final farmName = farm?.name ?? 'My Farm';
    final presets = AgriPvOptimizerService.generateParetoDesigns(farmArea, farmCrop);

    // Live calculation via pure AgriPvCalculationService for real farm parameters
    final design = AgriPvCalculationService.generateDesign(
      id: 'design_${farm?.id ?? "custom"}',
      name: '$farmName Agri-PV System',
      areaAcres: farmArea,
      crop: farmCrop,
      mountingType: _mountingType,
      tiltDegrees: _tiltDegrees,
      orientation: _orientation,
      rowSpacingMeters: _rowSpacingMeters,
      panelCoveragePercent: _panelCoveragePercent,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => context.go('/site-suitability'),
        ),
        title: const Text(
          'System Design',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper (Step 4: Design)
            ProgressStepper(
              currentStep: 4,
              onStepTapped: (step) {
                if (step == 1) context.go('/farm-location');
                if (step == 2) context.go('/farm-details');
                if (step == 3) context.go('/site-suitability');
              },
            ),

            // Main Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure Your Agri-PV System',
                      style: AppTypography.screenHeading.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust mounting structure, spacing, and tilt to balance solar generation with crop yield.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 14),

                    // 1-Click Optimized Presets Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Optimized Presets ($farmCrop)',
                              style: AppTypography.label.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.go('/compare-designs'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Compare All ›', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildPresetChip('🌾 Agri-First', 'Max Crop', () {
                          final p = presets.firstWhere((d) => d.id == 'design_agri_first', orElse: () => presets[0]);
                          _applyPreset(p);
                        }),
                        const SizedBox(width: 8),
                        _buildPresetChip('⚖️ Best LER', 'Balanced', () {
                          final p = presets.firstWhere((d) => d.id == 'design_balanced', orElse: () => presets[1]);
                          _applyPreset(p);
                        }, isHighlighted: true),
                        const SizedBox(width: 8),
                        _buildPresetChip('⚡ Power-First', 'Max Energy', () {
                          final p = presets.firstWhere((d) => d.id == 'design_power_first', orElse: () => presets[2]);
                          _applyPreset(p);
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mounting Type Selection Chips
                    Text(
                      'Mounting Type',
                      style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: MountingType.values.map((type) {
                        final isSelected = _mountingType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _mountingType = type;
                              _sync3dConfig();
                            }),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  type.label,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Live Calculated Primary Metrics Bar (4 Stats)
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricColumn('${design.pvCapacityKw.toInt()} kW', 'PV Capacity'),
                              Container(height: 26, width: 1, color: AppColors.border),
                              _buildMetricColumn('${design.annualEnergyMwh.toInt()} MWh', 'Est. Energy'),
                              Container(height: 26, width: 1, color: AppColors.border),
                              _buildMetricColumn('${design.cultivableAreaPercent.toInt()}%', 'Cultivable'),
                              Container(height: 26, width: 1, color: AppColors.border),
                              _buildMetricColumn('${design.cropYieldPercent.toInt()}%', 'Crop Yield'),
                            ],
                          ),
                          const Divider(height: 18, color: AppColors.borderLight),
                          // Secondary Scientific/Institutional Metrics
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricColumn('${design.dliMolM2Day.toStringAsFixed(1)} mol', 'Ground DLI', color: AppColors.accent),
                              Container(height: 26, width: 1, color: AppColors.border),
                              _buildMetricColumn('${(design.waterSavedLiters / 1000).toStringAsFixed(0)} kL', 'Water Saved', color: const Color(0xFF0284C7)),
                              Container(height: 26, width: 1, color: AppColors.border),
                              _buildMetricColumn('₹${design.lcoePerKwh.toStringAsFixed(2)}', 'LCOE / kWh', color: AppColors.primary),
                              Container(height: 26, width: 1, color: AppColors.border),
                              _buildMetricColumn('${design.irrPercent.toStringAsFixed(1)}%', 'Project IRR', color: const Color(0xFF16A34A)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sliders Container
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Panel Tilt Slider
                          _buildSliderRow(
                            label: 'Panel Tilt',
                            valueStr: '${_tiltDegrees.toInt()}°',
                            value: _tiltDegrees,
                            min: 10,
                            max: 40,
                            onChanged: (val) => setState(() {
                              _tiltDegrees = val;
                              _sync3dConfig();
                            }),
                          ),
                          const Divider(height: 22, color: AppColors.borderLight),

                          // Row Spacing Slider
                          _buildSliderRow(
                            label: 'Row Spacing',
                            valueStr: '${_rowSpacingMeters.toStringAsFixed(1)} m',
                            value: _rowSpacingMeters,
                            min: 4.0,
                            max: 12.0,
                            onChanged: (val) => setState(() {
                              _rowSpacingMeters = val;
                              _sync3dConfig();
                            }),
                          ),
                          const Divider(height: 22, color: AppColors.borderLight),

                          // Panel Coverage Slider
                          _buildSliderRow(
                            label: 'Panel Coverage',
                            valueStr: '${_panelCoveragePercent.toInt()}%',
                            value: _panelCoveragePercent,
                            min: 20,
                            max: 70,
                            onChanged: (val) => setState(() => _panelCoveragePercent = val),
                          ),
                          const Divider(height: 22, color: AppColors.borderLight),

                          // Orientation Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Orientation',
                                style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
                              ),
                              DropdownButton<PanelOrientation>(
                                value: _orientation,
                                underline: const SizedBox(),
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                items: PanelOrientation.values.map((o) => DropdownMenuItem(
                                  value: o,
                                  child: Text(o.label),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _orientation = val;
                                      _sync3dConfig();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Machinery Clearance Check Banner
                    ClearanceBadge(
                      isCompatible: design.isMachineryCompatible,
                      details: design.clearanceStatus,
                    ),
                    const SizedBox(height: 16),

                    // 3D Digital Model Visual Preview Banner
                    GestureDetector(
                      onTap: () => context.go('/ar-3d-view'),
                      child: Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 1.2),
                          boxShadow: const [
                            BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RealtimeAgriPv3dViewport(
                                controller: _scene3dController,
                                showSunGizmo: false,
                                enableGestures: false,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.threed_rotation_rounded, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Interactive 3D Model',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 12,
                                right: 12,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_mountingType.label} Structure',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          'Height: ${design.panelHeightMeters.toStringAsFixed(1)}m | Tilt: ${_tiltDegrees.toInt()}° | Row: ${_rowSpacingMeters.toStringAsFixed(1)}m',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Visual Exploration Quick Links (3D/AR View & Shadow Simulation)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/ar-3d-view'),
                            icon: const Icon(Icons.view_in_ar_rounded, size: 18),
                            label: const Text('View in 3D / AR'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/shadow-simulation'),
                            icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                            label: const Text('Shadow Sim'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.go('/compare-designs'),
                        icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                        label: const Text('Compare with other designs'),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      onPressed: () => context.go('/suitability-details'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        context.read<DesignProvider>().setActiveDesign(design);
                        context.go('/ar-3d-view');
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

  void _applyPreset(AgriPvDesign preset) {
    setState(() {
      _mountingType = preset.mountingType;
      _tiltDegrees = preset.tiltDegrees;
      _orientation = preset.orientation;
      _rowSpacingMeters = preset.rowSpacingMeters;
      _panelCoveragePercent = preset.panelCoveragePercent;
      _sync3dConfig();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${preset.name} preset!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPresetChip(String title, String subtitle, VoidCallback onTap, {bool isHighlighted = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlighted ? AppColors.primary : AppColors.border,
              width: isHighlighted ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted ? AppColors.primaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String val, String title, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueStr,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.borderLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primarySurface,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
