import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _authTokenKey = "auth_token";
  static const String _userIdKey = "user_id";

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }
  static Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }
  static Future<String?> loadId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance() ;
    return prefs.getString(_userIdKey) ;
  }

  static Future<String?> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }


  static Future<void> destroySession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_authTokenKey);
  }

}
