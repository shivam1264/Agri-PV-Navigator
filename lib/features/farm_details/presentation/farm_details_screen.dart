import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_dropdown.dart';
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
    final draftDistrict = (draft['district'] as String? ?? '').trim();
    final draftName = (draft['name'] as String? ?? '').trim();

    if (draftName.isNotEmpty && !draftName.toLowerCase().startsWith('farm at ')) {
      _nameController.text = draftName;
    } else if (draftDistrict.isNotEmpty && draftDistrict.toLowerCase() != 'location') {
      _nameController.text = 'Farm at $draftDistrict';
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
