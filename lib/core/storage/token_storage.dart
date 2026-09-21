import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'agri_pv_access_token';
  static const _keyRefreshToken = 'agri_pv_refresh_token';
  static const _keyUserJson = 'agri_pv_cached_user';
  static const _keyCustomAvatarPath = 'agri_pv_custom_avatar_path';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  static Future<void> saveCachedUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserJson, userJson);
  }

  static Future<String?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserJson);
  }

  static Future<void> saveUser(UserProfile user) async {
    await saveCachedUser(jsonEncode(user.toJson()));
  }

  static Future<UserProfile?> getUser() async {
    final raw = await getCachedUser();
    if (raw != null && raw.isNotEmpty) {
      try {
        return UserProfile.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
    return null;
  }

  static Future<void> saveCustomAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomAvatarPath, path);
  }

  static Future<String?> getCustomAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomAvatarPath);
  }

  static Future<void> clearCustomAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomAvatarPath);
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserJson);
    await prefs.remove(_keyCustomAvatarPath);
  }

  static Future<void> clearTokens() async {
    await clearAll();
  }

  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> hasToken() async {
    return await hasValidToken();
  }
}
