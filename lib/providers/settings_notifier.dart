import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool isDarkMode;
  final String units; // 'metric' | 'imperial'
  final String language; // 'en' | 'hi'
  final bool notificationsEnabled;
  final String currency; // 'INR' | 'USD'

  const AppSettings({
    this.isDarkMode = false,
    this.units = 'metric',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.currency = 'INR',
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? units,
    String? language,
    bool? notificationsEnabled,
    String? currency,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      units: units ?? this.units,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currency: currency ?? this.currency,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(AppSettings(
          isDarkMode: _prefs.getBool('isDarkMode') ?? false,
          units: _prefs.getString('units') ?? 'metric',
          language: _prefs.getString('language') ?? 'en',
          notificationsEnabled: _prefs.getBool('notificationsEnabled') ?? true,
          currency: _prefs.getString('currency') ?? 'INR',
        ));

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setUnits(String value) async {
    await _prefs.setString('units', value);
    state = state.copyWith(units: value);
  }

  Future<void> setLanguage(String value) async {
    await _prefs.setString('language', value);
    state = state.copyWith(language: value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool('notificationsEnabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setCurrency(String value) async {
    await _prefs.setString('currency', value);
    state = state.copyWith(currency: value);
  }

  Future<void> resetAll() async {
    await _prefs.clear();
    state = const AppSettings();
  }
}
