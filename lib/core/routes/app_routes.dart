import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/farms/presentation/my_farms_screen.dart';
import '../../features/farms/presentation/farm_detail_screen.dart';
import '../../features/farm_location/presentation/farm_location_screen.dart';
import '../../features/farm_details/presentation/farm_details_screen.dart';
import '../../features/suitability/presentation/site_suitability_screen.dart';
import '../../features/design/presentation/agri_pv_system_design_screen.dart';
import '../../features/visualization/presentation/ar_3d_view_screen.dart';
import '../../features/visualization/presentation/shadow_simulation_screen.dart';
import '../../features/economics/presentation/techno_economic_screen.dart';
import '../../features/proposal/presentation/proposal_report_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/support/presentation/help_support_screen.dart';
import '../../features/support/presentation/about_screen.dart';
import '../../features/success/presentation/success_screen.dart';

Page<dynamic> _buildFadePage(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildFadePage(context, state, const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _buildFadePage(context, state, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildFadePage(context, state, const LoginScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildFadePage(context, state, const HomeScreen()),
    ),
    GoRoute(
      path: '/farms',
      pageBuilder: (context, state) => _buildFadePage(context, state, const MyFarmsScreen()),
    ),
    GoRoute(
      path: '/farm-detail',
      pageBuilder: (context, state) => _buildFadePage(context, state, const FarmDetailScreen()),
    ),
    GoRoute(
      path: '/farm-location',
      pageBuilder: (context, state) => _buildFadePage(context, state, const FarmLocationScreen()),
    ),
    GoRoute(
      path: '/farm-details',
      pageBuilder: (context, state) => _buildFadePage(context, state, const FarmDetailsScreen()),
    ),
    GoRoute(
      path: '/site-suitability',
      pageBuilder: (context, state) => _buildFadePage(context, state, const SiteSuitabilityScreen()),
    ),
    GoRoute(
      path: '/agri-pv-design',
      pageBuilder: (context, state) => _buildFadePage(context, state, const AgriPvSystemDesignScreen()),
    ),
    GoRoute(
      path: '/ar-3d-view',
      pageBuilder: (context, state) => _buildFadePage(context, state, const Ar3dViewScreen()),
    ),
    GoRoute(
      path: '/shadow-simulation',
      pageBuilder: (context, state) => _buildFadePage(context, state, const ShadowSimulationScreen()),
    ),
    GoRoute(
      path: '/techno-economic',
      pageBuilder: (context, state) => _buildFadePage(context, state, const TechnoEconomicScreen()),
    ),
    GoRoute(
      path: '/proposal-report',
      pageBuilder: (context, state) => _buildFadePage(context, state, const ProposalReportScreen()),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) => _buildFadePage(context, state, const ReportsScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildFadePage(context, state, const ProfileScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildFadePage(context, state, const SettingsScreen()),
    ),
    GoRoute(
      path: '/help-support',
      pageBuilder: (context, state) => _buildFadePage(context, state, const HelpSupportScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => _buildFadePage(context, state, const AboutScreen()),
    ),
    GoRoute(
      path: '/success',
      pageBuilder: (context, state) => _buildFadePage(context, state, const SuccessScreen()),
    ),
  ],
);
