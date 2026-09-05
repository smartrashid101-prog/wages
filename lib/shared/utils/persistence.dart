import 'package:shared_preferences/shared_preferences.dart';

class Persistence {
  static const String _sessionKey = 'supabase_session';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveSession(String sessionData) async {
    await _prefs?.setString(_sessionKey, sessionData);
  }

  static String? getSession() {
    return _prefs?.getString(_sessionKey);
  }

  static Future<void> clearSession() async {
    await _prefs?.remove(_sessionKey);
  }
}