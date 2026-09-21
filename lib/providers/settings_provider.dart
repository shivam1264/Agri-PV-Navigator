import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  bool _notificationsEnabled = true;
  String _theme = 'Light';
  String _language = 'English';
  String _units = 'Metric (SI, acres)';
  String _currency = 'INR (₹)';

  bool get notificationsEnabled => _notificationsEnabled;
  String get theme => _theme;
  String get language => _language;
  String get units => _units;
  String get currency => _currency;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _theme = prefs.getString('theme') ?? 'Light';
      _language = prefs.getString('language') ?? 'English';
      _units = prefs.getString('units') ?? 'Metric (SI, acres)';
      _currency = prefs.getString('currency') ?? 'INR (₹)';
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
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    _theme = _theme == 'Light' ? 'Dark' : 'Light';
    notifyListeners();
    _save();
  }

  Future<void> toggleLanguage() async {
    _language = _language == 'English' ? 'Hindi (हिंदी)' : 'English';
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

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setString('theme', _theme);
      await prefs.setString('language', _language);
      await prefs.setString('units', _units);
      await prefs.setString('currency', _currency);

      await _userRepo.updatePreferences({
        'notificationsEnabled': _notificationsEnabled,
        'theme': _theme,
        'language': _language,
        'units': _units,
        'currency': _currency,
      });
    } catch (_) {}
  }
}
