import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/painters/agrivoltaic_3d_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Minimum splash display time
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    // 1. Check if already logged in
    final hasToken = await TokenStorage.hasValidToken();
    if (!mounted) return;

    if (hasToken) {
      // Already logged in → go straight to home
      context.go('/home');
      return;
    }

    // 2. Not logged in → check if onboarding was already seen
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;

    if (onboardingDone) {
      // Seen before → go directly to login
      context.go('/login');
    } else {
      // First time → show onboarding
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D0B) : Colors.white,
      body: Stack(
        children: [
          // Background scenic agrivoltaic landscape photo
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_agri_pv.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => CustomPaint(
                painter: Agrivoltaic3dPainter(
                  rotationAngle: 0.25,
                  zoom: 1.1,
                  panelTiltDeg: 22,
                  rowSpacingM: 6.0,
                  timeOfDayHour: 10.0,
                ),
              ),
            ),
          ),

          // Soft gradient overlay on top and bottom for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? const Color(0xFF090D0B) : Colors.white).withValues(alpha: 0.92),
                    (isDark ? const Color(0xFF090D0B) : Colors.white).withValues(alpha: 0.35),
                    (isDark ? const Color(0xFF090D0B) : Colors.white).withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.45, 0.85],
                ),
              ),
            ),
          ),

          // Central Logo & Branding
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),
                  // Logo Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF121815) : Colors.white).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF1E2922) : AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : AppColors.shadow,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const AppLogo(
                      size: 64,
                      showText: true,
                      showTagline: true,
                    ),
                  ),

                  // Minimal Loading Indicator & Bottom Pill
                  Column(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bottom pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          'Sustainable Farms. Brighter Tomorrows.',
                          style: AppTypography.buttonText.copyWith(
                            fontSize: 14,
                            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
