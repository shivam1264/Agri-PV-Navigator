import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/painters/agrivoltaic_3d_painter.dart';
import '../../../shared/painters/farm_boundary_painter.dart';
import '../../../shared/painters/shadow_simulation_painter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: 'Grow Food\nGenerate Clean Energy\nBuild a Better Tomorrow',
      highlights: [
        'Higher Farmer Income',
        'Clean Renewable Energy',
        'Sustainable Agriculture',
      ],
      type: 0,
    ),
    OnboardingItem(
      title: 'See What\'s Possible\non Your Land',
      highlights: [
        'Precision GIS Boundary Mapping',
        'Soil & Slope Multi-factor Analysis',
        'Tailored Crop Shading Assessments',
      ],
      type: 1,
    ),
    OnboardingItem(
      title: 'Design Before\nYou Invest',
      highlights: [
        'Interactive 3D & Shadow Simulation',
        'Tractor & Machinery Clearance Checks',
        'Comprehensive Bankable PDF Reports',
      ],
      type: 2,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Skip',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title,
                          style: AppTypography.largeHeading.copyWith(
                            fontSize: 26,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Visual Illustration Container
                        Container(
                          height: 210,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 1.5),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: _buildVisual(item.type),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Value highlight pills
                        ...item.highlights.map((highlight) => _buildHighlightRow(highlight)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  // 3-dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next / Get Started Button
                  AppButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next  →',
                    onPressed: _onNext,
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(int type) {
    switch (type) {
      case 0:
        return Image.asset(
          'assets/images/onboarding_solar.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            painter: Agrivoltaic3dPainter(
              rotationAngle: 0.3,
              zoom: 1.05,
              panelTiltDeg: 20,
              rowSpacingM: 6.0,
              timeOfDayHour: 10.0,
            ),
          ),
        );
      case 1:
        return CustomPaint(
          painter: FarmBoundaryPainter(
            areaAcres: 2.35,
            showPins: true,
          ),
        );
      case 2:
      default:
        return CustomPaint(
          painter: ShadowSimulationPainter(
            timeOfDayHour: 10.0,
            rowSpacing: 6.0,
          ),
        );
    }
  }

  Widget _buildHighlightRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final List<String> highlights;
  final int type;

  const OnboardingItem({
    required this.title,
    required this.highlights,
    required this.type,
  });
}
