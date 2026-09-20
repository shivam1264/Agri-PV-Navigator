import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/painters/farm_boundary_painter.dart';

class FarmLocationScreen extends StatefulWidget {
  const FarmLocationScreen({super.key});

  @override
  State<FarmLocationScreen> createState() => _FarmLocationScreenState();
}

class _FarmLocationScreenState extends State<FarmLocationScreen> {
  double _areaAcres = 2.35;
  String _locationName = 'Phulpur, Prayagraj';
  final String _stateName = 'Uttar Pradesh, India';
  final TextEditingController _searchController = TextEditingController(text: 'Phulpur, Prayagraj');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Farm Location',
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
            // Progress Stepper (Step 1: Location)
            ProgressStepper(
              currentStep: 1,
              onStepTapped: (step) {
                if (step == 2) context.go('/farm-details');
                if (step == 3) context.go('/site-suitability');
                if (step == 4) context.go('/agri-pv-design');
              },
            ),

            // Top Bar / Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Up Your Farm Location',
                    style: AppTypography.screenHeading.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  // Search input & "Use My Location" chip
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Search location or use map',
                              prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Use My Location Chip
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _locationName = 'Phulpur, Prayagraj';
                            _searchController.text = 'Phulpur, Prayagraj';
                          });
                        },
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.my_location_rounded, size: 15, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Use My Location',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Map View Area with Polygon & Map Controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // Satellite Background Image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/satellite_map.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Interactive Satellite Farm Boundary Custom Painter
                        Positioned.fill(
                          child: GestureDetector(
                            onTapUp: (details) {
                              // Tapping slightly adjusts boundary area for interactive feel
                              setState(() {
                                _areaAcres = (_areaAcres == 2.35) ? 2.50 : 2.35;
                              });
                            },
                            child: CustomPaint(
                              painter: FarmBoundaryPainter(
                                areaAcres: _areaAcres,
                                showPins: true,
                                drawBackground: false,
                              ),
                            ),
                          ),
                        ),

                        // Map Controls on Top Right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Column(
                            children: [
                              _buildMapButton(Icons.layers_outlined, () {}),
                              const SizedBox(height: 8),
                              _buildMapButton(Icons.add_rounded, () {
                                setState(() => _areaAcres += 0.1);
                              }),
                              const SizedBox(height: 6),
                              _buildMapButton(Icons.remove_rounded, () {
                                setState(() => _areaAcres = (_areaAcres - 0.1).clamp(0.5, 20.0));
                              }),
                            ],
                          ),
                        ),

                        // Instruction overlay tag at top left
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.touch_app_outlined, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Tap pins to adjust boundary',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Info Card: Selected Area & Location
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Area',
                            style: AppTypography.labelSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_areaAcres.toStringAsFixed(2)} acres',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 36, width: 1, color: AppColors.border),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: AppTypography.labelSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _locationName,
                            style: AppTypography.cardTitle.copyWith(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _stateName,
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/home'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/farm-details'),
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

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
