import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyName = 'name';
  static const String _keyAvatar = 'avatar_url';
  static const String _keyBio = 'bio';

  static Future<void> saveUserSession({
    required int id,
    required String username,
    required String email,
    required String name,
    String? avatarUrl,
    String? bio,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
    if (avatarUrl != null) await prefs.setString(_keyAvatar, avatarUrl);
    if (bio != null) await prefs.setString(_keyBio, bio);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<Map<String, dynamic>?> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!loggedIn) return null;

    return {
      'id': prefs.getInt(_keyUserId) ?? 1,
      'username': prefs.getString(_keyUsername) ?? 'andrianpei',
      'email': prefs.getString(_keyEmail) ?? 'andriandowehz123@gmail.com',
      'name': prefs.getString(_keyName) ?? 'Andrian Pei',
      'avatar_url': prefs.getString(_keyAvatar) ?? '',
      'bio': prefs.getString(_keyBio) ?? 'Taken 🤍',
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

