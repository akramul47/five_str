import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../core/network/dio_client.dart';
import 'core_providers.dart';

/// Auth state.
class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth state notifier.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final DioClient _dioClient;

  AuthNotifier(this._authService, this._dioClient)
      : super(const AuthState(isLoading: true)) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // Try to load cached user data
      final userData = await _authService.getUserData();
      UserModel? user;
      if (userData != null) {
        try {
          user = UserModel.fromJson(
            jsonDecode(userData) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
      state = AuthState(isLoggedIn: true, user: user);
      // Refresh user data in background
      refreshUser();
    } else {
      state = const AuthState(isLoggedIn: false);
    }
  }

  /// Login with email and password.
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dioClient.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final token = data['data']['token'] as String;
        final user = UserModel.fromJson(
          data['data']['user'] as Map<String, dynamic>,
        );
        await _authService.saveToken(token);
        await _authService.saveUserData(
          jsonEncode(data['data']['user']),
        );
        state = AuthState(isLoggedIn: true, user: user);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] as String? ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register a new user.
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dioClient.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (city != null) 'city': city,
          if (latitude != null) 'current_latitude': latitude,
          if (longitude != null) 'current_longitude': longitude,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final token = data['data']['token'] as String;
        final user = UserModel.fromJson(
          data['data']['user'] as Map<String, dynamic>,
        );
        await _authService.saveToken(token);
        await _authService.saveUserData(
          jsonEncode(data['data']['user']),
        );
        state = AuthState(isLoggedIn: true, user: user);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] as String? ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Refresh user data from the API.
  Future<void> refreshUser() async {
    try {
      final response = await _dioClient.get(ApiConfig.user);
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final user = UserModel.fromJson(
          data['data']['user'] as Map<String, dynamic>,
        );
        await _authService.saveUserData(
          jsonEncode(data['data']['user']),
        );
        state = state.copyWith(user: user);
      }
    } catch (_) {
      // Silently fail — cached data is still available
    }
  }

  /// Logout.
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConfig.logout);
    } catch (_) {}
    await _authService.clearToken();
    state = const AuthState(isLoggedIn: false);
  }

  /// Clear any error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(dioClientProvider),
  );
});
