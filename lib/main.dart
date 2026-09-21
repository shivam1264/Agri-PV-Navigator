import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/design_provider.dart';
import 'providers/suitability_provider.dart';
import 'providers/economics_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/support_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DesignProvider()),
        ChangeNotifierProvider(create: (_) => SuitabilityProvider()),
        ChangeNotifierProvider(create: (_) => EconomicsProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
      ],
      child: const AgriPvNavigatorApp(),
    ),
  );
}

class AgriPvNavigatorApp extends StatelessWidget {
  const AgriPvNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp.router(
      title: 'Agri-PV Navigator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(highContrast: settings.highContrast),
      darkTheme: AppTheme.getDarkTheme(highContrast: settings.highContrast),
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
            highContrast: settings.highContrast,
            disableAnimations: settings.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
