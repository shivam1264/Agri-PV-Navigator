import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConfig {
  /// Base URL of the Agri-PV Navigator Node.js backend.
  /// Android emulator uses 10.0.2.2 to reach host localhost.
  /// Windows, Web, macOS, Linux, and iOS simulator use localhost.
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    try {
      if (Platform.isAndroid) {
        // Physical devices with `adb reverse tcp:5000 tcp:5000` route 127.0.0.1 directly to PC localhost
        return 'http://127.0.0.1:5000';
      }
    } catch (_) {
      // Platform check may throw on non-supported platforms
    }

    return 'http://localhost:5000';
  }

  static const Duration requestTimeout = Duration(seconds: 15);
}
