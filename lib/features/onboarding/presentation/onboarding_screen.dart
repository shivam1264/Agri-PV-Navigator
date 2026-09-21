import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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

  Future<void> _markDoneAndGoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/login');
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _markDoneAndGoLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _markDoneAndGoLogin,
            child: Text(
              'Skip',
              style: AppTypography.buttonText.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
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
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Visual Illustration Container
                        Container(
                          height: 210,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor, width: 1.5),
                            color: isDark ? theme.cardColor : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black54 : AppColors.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                              : (isDark ? const Color(0xFF1E2922) : AppColors.border),
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
          'assets/images/hero_agri_pv.jpg',
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
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/farm_aerial_01.jpg',
              fit: BoxFit.cover,
            ),
            CustomPaint(
              painter: FarmBoundaryPainter(
                areaAcres: 2.35,
                showPins: true,
                drawBackground: false,
              ),
            ),
          ],
        );
      case 2:
      default:
        return Image.asset(
          'assets/images/agri_pv_3d_render.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            painter: ShadowSimulationPainter(
              timeOfDayHour: 10.0,
              rowSpacing: 6.0,
            ),
          ),
        );
    }
  }

  Widget _buildHighlightRow(String text) {
    final isDark = AppTheme.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: isDark ? AppColors.accent : AppColors.primary,
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
                color: isDark ? Colors.white : AppColors.textPrimary,
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
