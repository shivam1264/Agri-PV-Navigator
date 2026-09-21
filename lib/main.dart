import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/farm_provider.dart';
import 'providers/settings_notifier.dart';
import 'services/storage/local_db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize DB (seeds demo farms on first run)
  await LocalDbService().database;
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const AgriPvNavigatorApp(),
    ),
  );
}

class AgriPvNavigatorApp extends ConsumerWidget {
  const AgriPvNavigatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Agri-PV Navigator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
