import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
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
import '../../../models/farm.dart';
import '../../../models/agri_pv_design.dart';
import '../../visualization/engine/scene_3d_controller.dart';
import '../../visualization/engine/camera_controller.dart';
import '../../visualization/presentation/widgets/realtime_agri_pv_3d_viewport.dart';

class AgriPvSystemDesignScreen extends StatefulWidget {
  final bool readOnly;

  const AgriPvSystemDesignScreen({super.key, this.readOnly = false});

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
  String? _customBackgroundImageUrl;
  String _selectedPresetId = 'design_balanced';

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() {
        _customBackgroundImageUrl = xFile.path;
      });
    }
  }

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
    final farm = context.watch<FarmProvider>().currentOrDraftFarm;
    final farmArea = farm.areaAcres;
    final farmCrop = farm.crop;
    final farmName = farm.name;
    final presets = AgriPvOptimizerService.generateParetoDesigns(farmArea, farmCrop);

    // Live calculation via pure AgriPvCalculationService for real farm parameters
    final design = AgriPvCalculationService.generateDesign(
      id: 'design_${farm.id}',
      name: '$farmName Agri-PV System',
      areaAcres: farmArea,
      crop: farmCrop,
      mountingType: _mountingType,
      tiltDegrees: _tiltDegrees,
      orientation: _orientation,
      rowSpacingMeters: _rowSpacingMeters,
      panelCoveragePercent: _panelCoveragePercent,
    );

    // Polygon-fit field layout, recomputed live as the sliders move
    final layout = farm.boundary.length >= 3
        ? computeFieldRows(farm.boundary, _rowSpacingMeters, _panelCoveragePercent)
        : null;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => context.go(widget.readOnly ? '/farm-detail' : '/site-suitability'),
        ),
        title: Text(
          'System Design',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
            if (!widget.readOnly)
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
                    const SizedBox(height: 12),

                    // Mapped parcel context strip
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.landscape_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${farmArea.toStringAsFixed(2)} acres mapped',
                                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                                ),
                                Text(
                                  '${farm.boundary.length} corners • ${farm.location}',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (farm.boundary.length < 3)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'No boundary',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 1-Click Optimized Presets Banner
                    if (!widget.readOnly) ...[
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
                                  color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildPresetChip(
                            '🌾 Agri-First',
                            'Max Crop',
                            () {
                              final p = presets.firstWhere((d) => d.id == 'design_agri_first', orElse: () => presets[0]);
                              _applyPreset(p);
                            },
                            isHighlighted: _selectedPresetId == 'design_agri_first',
                          ),
                          const SizedBox(width: 8),
                          _buildPresetChip(
                            '⚖️ Best LER',
                            'Balanced',
                            () {
                              final p = presets.firstWhere((d) => d.id == 'design_balanced', orElse: () => presets[1]);
                              _applyPreset(p);
                            },
                            isHighlighted: _selectedPresetId == 'design_balanced',
                          ),
                          const SizedBox(width: 8),
                          _buildPresetChip(
                            '⚡ Power-First',
                            'Max Energy',
                            () {
                              final p = presets.firstWhere((d) => d.id == 'design_power_first', orElse: () => presets[2]);
                              _applyPreset(p);
                            },
                            isHighlighted: _selectedPresetId == 'design_power_first',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mounting Type Selection Chips
                      Text(
                        'Mounting Type',
                        style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (!widget.readOnly)
                      Row(
                        children: MountingType.values.map((type) {
                          final isSelected = _mountingType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedPresetId = 'custom';
                              _mountingType = type;
                              _sync3dConfig();
                            }),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : (isDark ? theme.cardColor : AppColors.surface),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : theme.dividerColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  type.label,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
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
                              Container(height: 26, width: 1, color: theme.dividerColor),
                              _buildMetricColumn('${design.annualEnergyMwh.toInt()} MWh', 'Est. Energy'),
                              Container(height: 26, width: 1, color: theme.dividerColor),
                              _buildMetricColumn('${design.cultivableAreaPercent.toInt()}%', 'Cultivable'),
                              Container(height: 26, width: 1, color: theme.dividerColor),
                              _buildMetricColumn('${design.cropYieldPercent.toInt()}%', 'Crop Yield'),
                            ],
                          ),
                          Divider(height: 18, color: theme.dividerColor),
                          // Secondary Scientific/Institutional Metrics
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricColumn('${design.dliMolM2Day.toStringAsFixed(1)} mol', 'Ground DLI', color: AppColors.accent),
                              Container(height: 26, width: 1, color: theme.dividerColor),
                              _buildMetricColumn('${(design.waterSavedLiters / 1000).toStringAsFixed(0)} kL', 'Water Saved', color: const Color(0xFF0284C7)),
                              Container(height: 26, width: 1, color: theme.dividerColor),
                              _buildMetricColumn('₹${design.lcoePerKwh.toStringAsFixed(2)}', 'LCOE / kWh', color: isDark ? AppColors.primaryLight : AppColors.primary),
                              Container(height: 26, width: 1, color: theme.dividerColor),
                              _buildMetricColumn('${design.irrPercent.toStringAsFixed(1)}%', 'Project IRR', color: const Color(0xFF16A34A)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sliders Container
                    if (!widget.readOnly)
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
                              _selectedPresetId = 'custom';
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
                              _selectedPresetId = 'custom';
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
                            onChanged: (val) => setState(() {
                              _selectedPresetId = 'custom';
                              _panelCoveragePercent = val;
                            }),
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

                    // Live 2D Field Layout Preview (rows fitted inside the mapped parcel)
                    Text(
                      'Field Layout Preview',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _ParcelLayoutPreview(farm: farm, layout: layout),
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
                                customBackgroundImageUrl: _customBackgroundImageUrl,
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
                                left: 10,
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
                    
                    if (!widget.readOnly)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickBackgroundImage,
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Upload Custom Field Background'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: AppColors.primaryDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            if (!widget.readOnly)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: '‹ Previous',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.go('/site-suitability'),
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
      _selectedPresetId = preset.id;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? (isDark ? const Color(0xFF133520) : AppColors.primarySurface)
                : (isDark ? theme.cardColor : AppColors.surface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlighted ? AppColors.primary : theme.dividerColor,
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
                  color: isHighlighted
                      ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                      : (isDark ? Colors.white : AppColors.textPrimary),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: isHighlighted
                      ? (isDark ? AppColors.accent : AppColors.primary)
                      : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueStr,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: isDark ? const Color(0xFF1E2922) : AppColors.borderLight,
            thumbColor: isDark ? AppColors.accent : AppColors.primary,
            overlayColor: isDark ? const Color(0xFF00E676).withValues(alpha: 0.15) : AppColors.primarySurface,
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

/// A row band that fits inside the parcel: 4 corners as [lat, lng] lists.
class FieldLayout {
  final List<List<List<double>>> rows;
  final int rowCount;
  final int panelEstimate;

  const FieldLayout({
    required this.rows,
    required this.rowCount,
    required this.panelEstimate,
  });
}

/// Fits east–west panel rows inside a simple (mapped) parcel polygon.
///
/// Pure math, no Flutter/UI state — asserts via test in test/field_layout_test.dart.
/// Row bands run along latitude; each band is the exact inside segment of the
/// polygon at that latitude (scanline), thickness = rowSpacing * coverage%.
FieldLayout computeFieldRows(
  List<List<double>> boundary,
  double rowSpacingMeters,
  double coveragePercent,
) {
  const metersPerDegLat = 111320.0;

  if (boundary.length < 3) return const FieldLayout(rows: [], rowCount: 0, panelEstimate: 0);
  for (final p in boundary) {
    if (p.length < 2) return const FieldLayout(rows: [], rowCount: 0, panelEstimate: 0);
  }
  final centerLat = boundary[0][0];
  final metersPerDegLng = metersPerDegLat * math.cos(centerLat * math.pi / 180).abs().clamp(0.05, 1.0).toDouble();

  var minLat = boundary[0][0], maxLat = boundary[0][0];
  var minLng = boundary[0][1], maxLng = boundary[0][1];
  for (final p in boundary) {
    minLat = math.min(minLat, p[0]);
    maxLat = math.max(maxLat, p[0]);
    minLng = math.min(minLng, p[1]);
    maxLng = math.max(maxLng, p[1]);
  }
  if (maxLat - minLat <= 0 || maxLng - minLng <= 0) {
    return const FieldLayout(rows: [], rowCount: 0, panelEstimate: 0);
  }

  final rowPitchDeg = rowSpacingMeters / metersPerDegLat;
  final rowThickDeg = rowPitchDeg * (coveragePercent / 100.0);
  if (rowPitchDeg <= 0 || rowThickDeg <= 0) {
    return const FieldLayout(rows: [], rowCount: 0, panelEstimate: 0);
  }

  // Horizontal extent of the polygon at a given latitude
  List<double> _crossings(double lat) {
    final xs = <double>[];
    for (var i = 0; i < boundary.length; i++) {
      final a = boundary[i];
      final b = boundary[(i + 1) % boundary.length];
      if ((a[0] <= lat && b[0] > lat) || (b[0] <= lat && a[0] > lat)) {
        final t = (lat - a[0]) / (b[0] - a[0]);
        xs.add(a[1] + t * (b[1] - a[1]));
      }
    }
    xs.sort();
    return xs;
  }

  final rows = <List<List<double>>>[];
  var panelEstimate = 0;

  for (double lat = minLat + rowThickDeg / 2; lat < maxLat; lat += rowPitchDeg) {
    final xs = _crossings(lat);
    if (xs.length < 2) continue;
    final bandMinLng = xs.first;
    final bandMaxLng = xs.last;
    rows.add([
      [lat + rowThickDeg / 2, bandMaxLng],
      [lat - rowThickDeg / 2, bandMaxLng],
      [lat - rowThickDeg / 2, bandMinLng],
      [lat + rowThickDeg / 2, bandMinLng],
    ]);
    final bandLenM = (bandMaxLng - bandMinLng) * metersPerDegLng;
    panelEstimate += math.max(0, (bandLenM / 2.2).floor());
  }

  return FieldLayout(rows: rows, rowCount: rows.length, panelEstimate: panelEstimate);
}

/// Read-only satellite map of the mapped parcel with the fitted panel rows
/// overlaid, so the design is visibly grounded in the real land.
class _ParcelLayoutPreview extends StatelessWidget {
  final Farm farm;
  final FieldLayout? layout;

  const _ParcelLayoutPreview({required this.farm, required this.layout});

  @override
  Widget build(BuildContext context) {
    final lay = layout;
    final rows = lay?.rows ?? const [];
    final statusText = lay == null
        ? 'Map only — no boundary mapped yet'
        : '${lay.rowCount} rows fit • ≈${lay.panelEstimate} panels (540Wp)';

    LatLng center;
    if (rows.isNotEmpty) {
      var lat = 0.0, lng = 0.0;
      for (final r in rows) {
        for (final c in r) {
          lat += c[0];
          lng += c[1];
        }
      }
      final count = rows.length * 4;
      center = LatLng(lat / count, lng / count);
    } else if (farm.latitude != null && farm.longitude != null) {
      center = LatLng(farm.latitude!, farm.longitude!);
    } else {
      center = const LatLng(25.4358, 81.8463);
    }

    final polygonPts = <LatLng>[
      for (final p in farm.boundary)
        if (p.length >= 2) LatLng(p[0], p[1]),
    ];

    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 16.5,
                  maxZoom: 19.0,
                  minZoom: 4.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    maxZoom: 19,
                  ),
                  if (rows.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        for (final r in rows)
                          Polygon(
                            points: [for (final c in r) LatLng(c[0], c[1])],
                            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                            borderColor: const Color(0xFF1D4ED8),
                            borderStrokeWidth: 1,
                          ),
                      ],
                    ),
                  if (polygonPts.length >= 3)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: polygonPts,
                          holePointsList: const [],
                          color: const Color(0x00000000),
                          borderColor: const Color(0xFF16A34A),
                          borderStrokeWidth: 2.5,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () => context.go('/farm-location'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Edit boundary',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
