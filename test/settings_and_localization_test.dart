import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_pv_navigator/providers/settings_provider.dart';
import 'package:agri_pv_navigator/core/localization/app_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider - Themes Tests', () {
    test('Default theme is Light and produces ThemeMode.light', () async {
      final settings = SettingsProvider();
      await settings.init();

      expect(settings.theme, 'Light');
      expect(settings.isDarkMode, false);
      expect(settings.themeMode, ThemeMode.light);
    });

    test('toggleTheme alternates between Light and Dark', () async {
      final settings = SettingsProvider();
      await settings.init();

      await settings.toggleTheme();
      expect(settings.theme, 'Dark');
      expect(settings.isDarkMode, true);
      expect(settings.themeMode, ThemeMode.dark);

      await settings.toggleTheme();
      expect(settings.theme, 'Light');
      expect(settings.isDarkMode, false);
      expect(settings.themeMode, ThemeMode.light);
    });

    test('setTheme supports System mode', () async {
      final settings = SettingsProvider();
      await settings.init();

      await settings.setTheme('System');
      expect(settings.theme, 'System');
      expect(settings.themeMode, ThemeMode.system);
    });
  });

  group('SettingsProvider - Language & Localization Tests', () {
    test('Default language is English', () async {
      final settings = SettingsProvider();
      await settings.init();

      expect(settings.language, 'English');
      expect(settings.isHindi, false);
      expect(settings.tr('profile'), 'Profile');
    });

    test('toggleLanguage alternates between English and Hindi', () async {
      final settings = SettingsProvider();
      await settings.init();

      await settings.toggleLanguage();
      expect(settings.isHindi, true);
      expect(settings.tr('profile'), 'प्रोफ़ाइल');
      expect(settings.tr('theme'), 'थीम');
      expect(settings.tr('edit_profile'), 'प्रोफ़ाइल संपादित करें');

      await settings.toggleLanguage();
      expect(settings.isHindi, false);
      expect(settings.tr('profile'), 'Profile');
    });

    test('AppStrings dictionary contains non-empty strings for both languages', () {
      const keys = [
        'app_title',
        'home',
        'farms',
        'design',
        'reports',
        'profile',
        'settings',
        'appearance',
        'theme',
        'theme_light',
        'theme_dark',
        'language',
        'units',
        'accessibility',
        'high_contrast',
        'large_targets',
        'reduce_motion',
      ];

      for (final key in keys) {
        final enStr = AppStrings.get(key, language: 'English');
        final hiStr = AppStrings.get(key, language: 'Hindi (हिंदी)');

        expect(enStr.isNotEmpty, true, reason: 'Key $key missing in EN');
        expect(hiStr.isNotEmpty, true, reason: 'Key $key missing in HI');
        expect(enStr != hiStr, true, reason: 'Key $key is not translated in HI');
      }
    });
  });

  group('SettingsProvider - Units Conversion Tests', () {
    test('formatArea correctly formats acres and converts to hectares', () async {
      final settings = SettingsProvider();
      await settings.init();

      // Default: Metric (SI, acres)
      expect(settings.formatArea(2.35), '2.35 ac');

      // Switch to Hectares (ha)
      await settings.setUnits('Hectares (ha)');
      // 2.35 acres * 0.404686 = 0.95101 ha -> 0.95 ha
      expect(settings.formatArea(2.35), '0.95 ha');
    });

    test('formatLength converts between meters and feet', () async {
      final settings = SettingsProvider();
      await settings.init();

      // Metric: meters
      expect(settings.formatLength(3.0), '3.0 m');

      // Imperial: feet (3.0 * 3.28084 = 9.84252 -> 9.8 ft)
      await settings.setUnits('Imperial (ft, acres)');
      expect(settings.formatLength(3.0), '9.8 ft');
    });

    test('formatWater converts between liters and gallons', () async {
      final settings = SettingsProvider();
      await settings.init();

      // Metric: liters
      expect(settings.formatWater(1000.0), '1000 L');

      // Imperial: gallons (1000 * 0.264172 = 264 gal)
      await settings.setUnits('Imperial (ft, acres)');
      expect(settings.formatWater(1000.0), '264 gal');
    });

    test('formatPower converts kW to MW for >= 1000 kW', () async {
      final settings = SettingsProvider();
      await settings.init();

      expect(settings.formatPower(450.0), '450.0 kW');
      expect(settings.formatPower(1250.0), '1.25 MW');
    });
  });

  group('SettingsProvider - Accessibility Suite Tests', () {
    test('Accessibility setters update values and clamp text scale', () async {
      final settings = SettingsProvider();
      await settings.init();

      expect(settings.textScale, 1.0);
      expect(settings.highContrast, false);
      expect(settings.largeTouchTargets, false);
      expect(settings.reduceMotion, false);

      await settings.setTextScale(1.25);
      expect(settings.textScale, 1.25);

      // Clamps outside [0.8, 1.4]
      await settings.setTextScale(2.5);
      expect(settings.textScale, 1.4);

      await settings.setTextScale(0.2);
      expect(settings.textScale, 0.8);

      await settings.setHighContrast(true);
      expect(settings.highContrast, true);

      await settings.setLargeTouchTargets(true);
      expect(settings.largeTouchTargets, true);

      await settings.setReduceMotion(true);
      expect(settings.reduceMotion, true);

      // Reset
      await settings.resetAccessibility();
      expect(settings.textScale, 1.0);
      expect(settings.highContrast, false);
      expect(settings.largeTouchTargets, false);
      expect(settings.reduceMotion, false);
    });
  });
}
