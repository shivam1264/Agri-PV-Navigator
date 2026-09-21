import 'package:flutter/foundation.dart';

class AppConfig {
  /// Base URL of the Agri-PV Navigator Node.js backend.
  /// Defaults to the live Render production backend.
  /// Can be overridden via --dart-define=API_BASE_URL=... if needed.
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Default production cloud backend
    return 'https://agri-pv-navigator.onrender.com';
  }

  static const Duration requestTimeout = Duration(seconds: 30);
}
