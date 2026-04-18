import 'package:shared_preferences/shared_preferences.dart';

/// Manages auth token persistence.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save the auth token.
  Future<void> saveToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_tokenKey, token);
  }

  /// Get the stored auth token, or null if not logged in.
  Future<String?> getToken() async {
    final prefs = await _preferences;
    return prefs.getString(_tokenKey);
  }

  /// Clear the stored token (logout).
  Future<void> clearToken() async {
    final prefs = await _preferences;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Check if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save cached user data as JSON string.
  Future<void> saveUserData(String jsonString) async {
    final prefs = await _preferences;
    await prefs.setString(_userKey, jsonString);
  }

  /// Get cached user data JSON string.
  Future<String?> getUserData() async {
    final prefs = await _preferences;
    return prefs.getString(_userKey);
  }
}
