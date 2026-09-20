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
import '../../features/suitability/presentation/suitability_details_screen.dart';
import '../../features/design/presentation/agri_pv_system_design_screen.dart';
import '../../features/visualization/presentation/ar_3d_view_screen.dart';
import '../../features/visualization/presentation/shadow_simulation_screen.dart';
import '../../features/comparison/presentation/compare_designs_screen.dart';
import '../../features/economics/presentation/techno_economic_screen.dart';
import '../../features/proposal/presentation/proposal_report_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/support/presentation/help_support_screen.dart';
import '../../features/support/presentation/about_screen.dart';
import '../../features/success/presentation/success_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/farms',
      builder: (context, state) => const MyFarmsScreen(),
    ),
    GoRoute(
      path: '/farm-detail',
      builder: (context, state) => const FarmDetailScreen(),
    ),
    GoRoute(
      path: '/farm-location',
      builder: (context, state) => const FarmLocationScreen(),
    ),
    GoRoute(
      path: '/farm-details',
      builder: (context, state) => const FarmDetailsScreen(),
    ),
    GoRoute(
      path: '/site-suitability',
      builder: (context, state) => const SiteSuitabilityScreen(),
    ),
    GoRoute(
      path: '/suitability-details',
      builder: (context, state) => const SuitabilityDetailsScreen(),
    ),
    GoRoute(
      path: '/agri-pv-design',
      builder: (context, state) => const AgriPvSystemDesignScreen(),
    ),
    GoRoute(
      path: '/ar-3d-view',
      builder: (context, state) => const Ar3dViewScreen(),
    ),
    GoRoute(
      path: '/shadow-simulation',
      builder: (context, state) => const ShadowSimulationScreen(),
    ),
    GoRoute(
      path: '/compare-designs',
      builder: (context, state) => const CompareDesignsScreen(),
    ),
    GoRoute(
      path: '/techno-economic',
      builder: (context, state) => const TechnoEconomicScreen(),
    ),
    GoRoute(
      path: '/proposal-report',
      builder: (context, state) => const ProposalReportScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
  ],
);
