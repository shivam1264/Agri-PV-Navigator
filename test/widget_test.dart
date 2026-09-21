import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agri_pv_navigator/main.dart';
import 'package:agri_pv_navigator/providers/auth_provider.dart';
import 'package:agri_pv_navigator/providers/farm_provider.dart';
import 'package:agri_pv_navigator/providers/dashboard_provider.dart';
import 'package:agri_pv_navigator/providers/design_provider.dart';
import 'package:agri_pv_navigator/providers/suitability_provider.dart';
import 'package:agri_pv_navigator/providers/economics_provider.dart';
import 'package:agri_pv_navigator/providers/report_provider.dart';
import 'package:agri_pv_navigator/providers/notification_provider.dart';
import 'package:agri_pv_navigator/providers/support_provider.dart';
import 'package:agri_pv_navigator/providers/settings_provider.dart';

void main() {
  testWidgets('Agri-PV Navigator smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => FarmProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => DesignProvider()),
          ChangeNotifierProvider(create: (_) => SuitabilityProvider()),
          ChangeNotifierProvider(create: (_) => EconomicsProvider()),
          ChangeNotifierProvider(create: (_) => ReportProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => SupportProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const AgriPvNavigatorApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(AgriPvNavigatorApp), findsOneWidget);
  });
}
