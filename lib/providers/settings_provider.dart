import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';
import '../core/localization/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  bool _notificationsEnabled = true;
  String _theme = 'Light'; // 'Light', 'Dark', 'System'
  String _language = 'English'; // 'English', 'Hindi (हिंदी)'
  String _units = 'Metric (SI, acres)'; // 'Metric (SI, acres)', 'Imperial (ft, acres)', 'Hectares (ha)'
  String _currency = 'INR (₹)';

  // Accessibility settings
  double _textScale = 1.0;
  bool _highContrast = false;
  bool _largeTouchTargets = false;
  bool _reduceMotion = false;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  String get theme => _theme;
  String get language => _language;
  String get units => _units;
  String get currency => _currency;

  double get textScale => _textScale;
  bool get highContrast => _highContrast;
  bool get largeTouchTargets => _largeTouchTargets;
  bool get reduceMotion => _reduceMotion;

  bool get isDarkMode => _theme == 'Dark';
  bool get isHindi => _language.toLowerCase().contains('hindi');

  ThemeMode get themeMode {
    if (_theme == 'Dark') return ThemeMode.dark;
    if (_theme == 'System') return ThemeMode.system;
    return ThemeMode.light;
  }

  /// String translation helper connected directly to current language
  String tr(String key) => AppStrings.get(key, language: _language);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _theme = prefs.getString('theme') ?? 'Light';
      _language = prefs.getString('language') ?? 'English';
      _units = prefs.getString('units') ?? 'Metric (SI, acres)';
      _currency = prefs.getString('currency') ?? 'INR (₹)';

      _textScale = prefs.getDouble('textScale') ?? 1.0;
      _highContrast = prefs.getBool('highContrast') ?? false;
      _largeTouchTargets = prefs.getBool('largeTouchTargets') ?? false;
      _reduceMotion = prefs.getBool('reduceMotion') ?? false;

      notifyListeners();

      // Attempt remote fetch
      final remotePrefs = await _userRepo.getPreferences();
      if (remotePrefs.containsKey('notificationsEnabled')) {
        _notificationsEnabled = remotePrefs['notificationsEnabled'] as bool;
      }
      if (remotePrefs.containsKey('theme')) {
        _theme = remotePrefs['theme'] as String;
      }
      if (remotePrefs.containsKey('language')) {
        _language = remotePrefs['language'] as String;
      }
      if (remotePrefs.containsKey('units')) {
        _units = remotePrefs['units'] as String;
      }
      notifyListeners();
    } catch (_) {}
  }

  // ── Theme Methods ────────────────────────────────────────────────────────
  Future<void> setTheme(String newTheme) async {
    if (_theme == newTheme) return;
    _theme = newTheme;
    notifyListeners();
    _save();
  }

  Future<void> toggleTheme() async {
    _theme = _theme == 'Light' ? 'Dark' : 'Light';
    notifyListeners();
    _save();
  }

  // ── Language Methods ─────────────────────────────────────────────────────
  Future<void> setLanguage(String newLang) async {
    if (_language == newLang) return;
    _language = newLang;
    notifyListeners();
    _save();
  }

  Future<void> toggleLanguage() async {
    _language = isHindi ? 'English' : 'Hindi (हिंदी)';
    notifyListeners();
    _save();
  }

  // ── Units Methods & Conversions ──────────────────────────────────────────
  Future<void> setUnits(String newUnits) async {
    if (_units == newUnits) return;
    _units = newUnits;
    notifyListeners();
    _save();
  }

  Future<void> cycleUnits() async {
    const options = ['Metric (SI, acres)', 'Imperial (ft, acres)', 'Hectares (ha)'];
    final idx = options.indexOf(_units);
    _units = options[(idx + 1) % options.length];
    notifyListeners();
    _save();
  }

  /// Formats area in acres into current chosen unit (acres or hectares)
  String formatArea(double acres) {
    if (_units.contains('Hectares')) {
      final ha = acres * 0.404686;
      return '${ha.toStringAsFixed(2)} ha';
    }
    return '${acres.toStringAsFixed(2)} ac';
  }

  /// Formats length/height in meters into current chosen unit (meters or feet)
  String formatLength(double meters) {
    if (_units.contains('Imperial')) {
      final feet = meters * 3.28084;
      return '${feet.toStringAsFixed(1)} ft';
    }
    return '${meters.toStringAsFixed(1)} m';
  }

  /// Formats water volume in liters into current chosen unit (liters or gallons)
  String formatWater(double liters) {
    if (_units.contains('Imperial')) {
      final gallons = liters * 0.264172;
      return '${gallons.round()} gal';
    }
    return '${liters.round()} L';
  }

  /// Formats power in kW or MW
  String formatPower(double kW) {
    if (kW >= 1000) {
      return '${(kW / 1000).toStringAsFixed(2)} MW';
    }
    return '${kW.toStringAsFixed(1)} kW';
  }

  String formatCurrency(double inr) {
    return '₹${inr.toStringAsFixed(0)}';
  }

  // ── Accessibility Methods ────────────────────────────────────────────────
  Future<void> setTextScale(double scale) async {
    _textScale = scale.clamp(0.8, 1.4);
    notifyListeners();
    _save();
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    _save();
  }

  Future<void> setLargeTouchTargets(bool value) async {
    _largeTouchTargets = value;
    notifyListeners();
    _save();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    _save();
  }

  Future<void> resetAccessibility() async {
    _textScale = 1.0;
    _highContrast = false;
    _largeTouchTargets = false;
    _reduceMotion = false;
    notifyListeners();
    _save();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    _save();
  }

  // ── Persistence ──────────────────────────────────────────────────────────
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setString('theme', _theme);
      await prefs.setString('language', _language);
      await prefs.setString('units', _units);
      await prefs.setString('currency', _currency);

      await prefs.setDouble('textScale', _textScale);
      await prefs.setBool('highContrast', _highContrast);
      await prefs.setBool('largeTouchTargets', _largeTouchTargets);
      await prefs.setBool('reduceMotion', _reduceMotion);

      await _userRepo.updatePreferences({
        'notificationsEnabled': _notificationsEnabled,
        'theme': _theme,
        'language': _language,
        'units': _units,
        'currency': _currency,
        'textScale': _textScale,
        'highContrast': _highContrast,
        'largeTouchTargets': _largeTouchTargets,
        'reduceMotion': _reduceMotion,
      });
    } catch (_) {}
  }
}
