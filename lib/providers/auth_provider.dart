import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../core/storage/token_storage.dart';
import '../core/errors/app_exceptions.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();

  UserProfile? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserProfile? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _authRepo.isLoggedIn();
      if (hasToken) {
        _user = await _userRepo.getProfile();
        _isAuthenticated = true;
      } else {
        final cached = await TokenStorage.getUser();
        _user = cached ??
            const UserProfile(
              id: 'local_user',
              name: 'Farmer',
              email: 'farmer@example.com',
              phone: '',
              initials: 'SK',
              totalFarms: 1,
              totalAreaAcres: 2.35,
              designsCreated: 1,
              profileImage: 'assets/images/farmer_avatar.jpg',
            );
        _isAuthenticated = false;
      }
    } catch (e) {
      final cached = await TokenStorage.getUser();
      _user = cached;
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepo.login(email: email, password: password);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? organization,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepo.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        organization: organization,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepo.logout();
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? organization,
    String? preferredLanguage,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // 1. Immediately update local state so changes take effect instantly
    final current = _user ??
        const UserProfile(
          id: 'local_user',
          name: 'Farmer',
          email: 'farmer@example.com',
          phone: '',
          initials: 'SK',
          totalFarms: 1,
          totalAreaAcres: 2.35,
          designsCreated: 1,
          profileImage: 'assets/images/farmer_avatar.jpg',
        );

    final newName = fullName != null && fullName.trim().isNotEmpty ? fullName.trim() : current.name;
    final newPhone = phoneNumber != null ? phoneNumber.trim() : current.phone;
    final newImage = profileImage ?? current.profileImage;
    final initials = newName.length >= 2
        ? newName.substring(0, 2).toUpperCase()
        : (newName.isNotEmpty ? newName[0].toUpperCase() : 'SK');

    _user = current.copyWith(
      name: newName,
      phone: newPhone,
      initials: initials,
      profileImage: newImage,
    );
    try {
      await TokenStorage.saveUser(_user!);
    } catch (e) {
      debugPrint('[AuthProvider] Failed saving user to local storage: $e');
    }

    // 2. If online and authenticated, sync with backend
    if (_isAuthenticated) {
      try {
        final remote = await _userRepo.updateProfile(
          fullName: fullName,
          phoneNumber: phoneNumber,
          organization: organization,
          preferredLanguage: preferredLanguage,
        );
        _user = remote.copyWith(
          profileImage: newImage,
          phone: newPhone,
        );
        await TokenStorage.saveUser(_user!);
      } catch (e) {
        debugPrint('[AuthProvider] Backend sync skipped or failed: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateAvatar(String avatarPath) async {
    await updateProfile(profileImage: avatarPath);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
