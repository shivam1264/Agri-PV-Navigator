import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/suitability_provider.dart';
import '../../../providers/design_provider.dart';

class FarmDetailsScreen extends StatefulWidget {
  const FarmDetailsScreen({super.key});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  String _selectedCrop = 'Wheat';
  String _selectedSoil = 'Loamy';
  String _selectedSlope = '< 2% (Almost flat)';
  String _selectedIrrigation = 'Available';
  String _selectedGrid = '2.4 km';

  @override
  void initState() {
    super.initState();
    final draft = context.read<FarmProvider>().draftFarm;
    if (draft['name'] != null && (draft['name'] as String).isNotEmpty) {
      _nameController.text = draft['name'];
    } else if (draft['district'] != null && (draft['district'] as String).isNotEmpty) {
      _nameController.text = 'Farm at ${draft['district']}';
    } else {
      _nameController.text = 'My Solar Farm';
    }

    if (draft['areaAcres'] != null) {
      final area = (draft['areaAcres'] as num).toDouble();
      _areaController.text = area.toStringAsFixed(2);
    } else {
      _areaController.text = '3.50';
    }

    if (draft['cropType'] != null) _selectedCrop = draft['cropType'];
    if (draft['soilType'] != null) _selectedSoil = draft['soilType'];
    if (draft['slope'] != null) _selectedSlope = draft['slope'];
    if (draft['irrigation'] != null) _selectedIrrigation = draft['irrigation'];
    if (draft['gridProximityKm'] != null) _selectedGrid = '${draft['gridProximityKm']} km';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Widget _mappingSummaryCard({
    required int corners,
    required double? areaAcres,
    required String? district,
    required String? state,
    required double? lat,
    required double? lng,
    required ThemeData theme,
    required bool isDark,
  }) {
    final titleColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final subColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final coords = (lat != null && lng != null) ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}' : null;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Land Mapping Summary', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow(Icons.location_city_rounded, 'Region', (district?.isNotEmpty ?? false) ? district! : '—', titleColor, subColor),
          if (state != null && state.isNotEmpty) _summaryRow(Icons.map_rounded, 'State', state, titleColor, subColor),
          _summaryRow(Icons.crop_landscape_rounded, 'Mapped Area', areaAcres != null ? '${areaAcres.toStringAsFixed(2)} acres' : '—', titleColor, subColor,
              accent: AppColors.primary),
          _summaryRow(Icons.polyline_rounded, 'Boundary Corners', '$corners', titleColor, subColor),
          if (coords != null) _summaryRow(Icons.gps_fixed_rounded, 'Coordinates', coords, titleColor, subColor),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value, Color titleColor, Color subColor, {Color? accent}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: accent ?? subColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: subColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: accent ?? titleColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _onNext() async {
    final farmProv = context.read<FarmProvider>();
    final areaVal = double.tryParse(_areaController.text.trim()) ?? 2.35;
    final nameVal = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Farm at ${farmProv.draftFarm['district'] ?? 'Site'}';

    final gridKm = double.tryParse(_selectedGrid.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 2.4;

    farmProv.updateDraftDetails(
      name: nameVal,
      areaAcres: areaVal,
      cropType: _selectedCrop,
      soilType: _selectedSoil,
      slope: _selectedSlope,
      irrigation: _selectedIrrigation,
      irrigationSource: _selectedIrrigation,
      gridProximityKm: gridKm,
    );

    final farm = await farmProv.submitDraftFarm();
    if (!mounted) return;

    if (farm != null) {
      // Pre-load suitability and designs with live fallbackFarm
      context.read<SuitabilityProvider>().loadSuitability(farm.id, fallbackFarm: farm);
      context.read<DesignProvider>().loadDesignsForFarm(farm.id);
      context.go('/site-suitability');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmProv.error ?? 'Failed to save farm. Please try again.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProv = context.watch<FarmProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Values auto-filled from the land mapping done on the location screen
    final draftMap = farmProv.draftFarm;
    final rawBoundary = draftMap['boundaryPoints'];
    final mappedCorners = rawBoundary is List ? rawBoundary.length : 0;
    final areaFromMapping = draftMap['areaFromMapping'] == true;
    final mappedLat = (draftMap['latitude'] as num?)?.toDouble();
    final mappedLng = (draftMap['longitude'] as num?)?.toDouble();
    final mappedDistrict = (draftMap['district'] as String?)?.trim();
    final mappedState = draftMap['state'] as String?;
    final mappedArea = (draftMap['areaAcres'] as num?)?.toDouble();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => context.go('/farm-location'),
        ),
        title: Text(
          'Farm Details',
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
            // Progress Stepper (Step 2: Details)
            ProgressStepper(
              currentStep: 2,
              onStepTapped: (step) {
                if (step == 1) context.go('/farm-location');
                if (step == 3) context.go('/site-suitability');
                if (step == 4) context.go('/agri-pv-design');
              },
            ),

            // Scrollable Form Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us about your farm',
                      style: AppTypography.screenHeading.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your farm details to accurately calculate site suitability and crop compatibility.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 20),

                    // Land Mapping Summary (auto-filled from location screen)
                    if (mappedCorners > 0) ...[
                      _mappingSummaryCard(
                        corners: mappedCorners,
                        areaAcres: mappedArea,
                        district: mappedDistrict,
                        state: mappedState,
                        lat: mappedLat,
                        lng: mappedLng,
                        theme: theme,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Farm Name Input
                    AppTextField(
                      label: 'Farm Name',
                      hint: 'e.g. My Farm',
                      controller: _nameController,
                      prefixIcon: Icons.drive_file_rename_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Total Area Input
                    AppTextField(
                      label: 'Total Area (acres)',
                      hint: '2.35',
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.crop_landscape_rounded,
                      suffix: areaFromMapping
                          ? Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.link_rounded, size: 12, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'From boundary',
                                    style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Primary Crop Dropdown
                    AppDropdown<String>(
                      label: 'Primary Crop',
                      value: _selectedCrop,
                      prefixIcon: Icons.grain_rounded,
                      items: const [
                        DropdownMenuItem(value: 'Wheat', child: Text('Wheat (C3 Shade-Tolerant)')),
                        DropdownMenuItem(value: 'Rice', child: Text('Rice (Paddy)')),
                        DropdownMenuItem(value: 'Potato', child: Text('Potato (High Value)')),
                        DropdownMenuItem(value: 'Mustard', child: Text('Mustard / Oilseeds')),
                        DropdownMenuItem(value: 'Leafy Vegetables', child: Text('Leafy Vegetables (High Shade)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCrop = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Soil Type Dropdown
                    AppDropdown<String>(
                      label: 'Soil Type',
                      value: _selectedSoil,
                      prefixIcon: Icons.grass_rounded,
                      items: const [
                        DropdownMenuItem(value: 'Loamy', child: Text('Loamy (Fertile & Stable)')),
                        DropdownMenuItem(value: 'Alluvial', child: Text('Alluvial Soil')),
                        DropdownMenuItem(value: 'Sandy Loam', child: Text('Sandy Loam')),
                        DropdownMenuItem(value: 'Clay', child: Text('Clay / Black Soil')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSoil = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Land Slope Dropdown
                    AppDropdown<String>(
                      label: 'Land Slope',
                      value: _selectedSlope,
                      prefixIcon: Icons.landscape_rounded,
                      items: const [
                        DropdownMenuItem(value: '< 2% (Almost flat)', child: Text('< 2% (Almost flat - Ideal)')),
                        DropdownMenuItem(value: '2% - 5% (Gentle)', child: Text('2% - 5% (Gentle slope)')),
                        DropdownMenuItem(value: '> 5% (Moderate)', child: Text('> 5% (Moderate slope)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSlope = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Irrigation Availability Dropdown
                    AppDropdown<String>(
                      label: 'Irrigation Availability',
                      value: _selectedIrrigation,
                      prefixIcon: Icons.water_drop_rounded,
                      items: const [
                        DropdownMenuItem(value: 'Available', child: Text('Available (Tubewell / Canal)')),
                        DropdownMenuItem(value: 'Seasonal', child: Text('Seasonal / Partial')),
                        DropdownMenuItem(value: 'Rainfed', child: Text('Rainfed Only')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedIrrigation = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Grid Proximity Dropdown
                    AppDropdown<String>(
                      label: 'Grid Proximity',
                      value: _selectedGrid,
                      prefixIcon: Icons.electric_bolt_rounded,
                      items: const [
                        DropdownMenuItem(value: '< 1 km', child: Text('< 1 km (Very Close)')),
                        DropdownMenuItem(value: '2.4 km', child: Text('2.4 km (Optimal)')),
                        DropdownMenuItem(value: '3 - 5 km', child: Text('3 - 5 km (Feasible)')),
                        DropdownMenuItem(value: '> 5 km', child: Text('> 5 km (High Interconnection Capex)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGrid = val);
                      },
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
                      onPressed: () => context.go('/farm-location'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: farmProv.isLoading ? null : _onNext,
                      isLoading: farmProv.isLoading,
                      height: 46,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: 2,
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
}
