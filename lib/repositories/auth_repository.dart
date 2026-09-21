import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? organization,
  }) async {
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty && nameParts[0].isNotEmpty ? nameParts[0] : 'Farmer';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';

    final response = await _client.post(
      '/api/auth/register',
      requiresAuth: false,
      body: {
        'fullName': fullName,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phoneNumber ?? '',
        'phoneNumber': phoneNumber ?? '',
        'organization': organization,
      },
    );

    final tokens = response['tokens'];
    await TokenStorage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );

    final user = UserProfile.fromJson(response['user']);
    await TokenStorage.saveUser(user);
    return user;
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/api/auth/login',
      requiresAuth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    final tokens = response['tokens'];
    await TokenStorage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );

    final user = UserProfile.fromJson(response['user']);
    await TokenStorage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _client.post(
          '/api/auth/logout',
          body: {'refreshToken': refreshToken},
          requiresAuth: false,
        );
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasToken();
  }

  Future<UserProfile?> getCurrentUser() async {
    return await TokenStorage.getUser();
  }
}
