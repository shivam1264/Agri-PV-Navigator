import 'dart:io';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_profile.dart';

class UserRepository {
  final ApiClient _client = ApiClient();

  Future<UserProfile> getProfile() async {
    final response = await _client.get('/api/users/me');
    var user = UserProfile.fromJson(response);
    final customAvatar = await TokenStorage.getCustomAvatarPath();
    if (customAvatar != null && customAvatar.isNotEmpty) {
      try {
        if (File(customAvatar).existsSync()) {
          user = user.copyWith(profileImage: customAvatar);
        }
      } catch (_) {}
    }
    await TokenStorage.saveUser(user);
    return user;
  }

  Future<UserProfile> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? organization,
    String? preferredLanguage,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (organization != null) body['organization'] = organization;
    if (preferredLanguage != null) body['preferredLanguage'] = preferredLanguage;

    final response = await _client.patch('/api/users/me', body: body);
    var user = UserProfile.fromJson(response);
    final customAvatar = await TokenStorage.getCustomAvatarPath();
    if (customAvatar != null && customAvatar.isNotEmpty) {
      try {
        if (File(customAvatar).existsSync()) {
          user = user.copyWith(profileImage: customAvatar);
        }
      } catch (_) {}
    }
    await TokenStorage.saveUser(user);
    return user;
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _client.get('/api/users/preferences');
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> prefs) async {
    final response = await _client.patch('/api/users/preferences', body: prefs);
    return Map<String, dynamic>.from(response);
  }
}
