import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthStorage {
  static const String _keyJwt = "jwt_token";
  static const String _keyPkToken = "pksoft_token";
  static const String _keyUser = "user_data";

  static Future<void> saveLoginData({
    required String jwt,
    required String pkToken,
    required Map<String, dynamic> userModel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJwt, jwt);
    await prefs.setString(_keyPkToken, pkToken);
    await prefs.setString(_keyUser, jsonEncode(userModel));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString(_keyUser);
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  static Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyJwt);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getJwt();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJwt);
    await prefs.remove(_keyPkToken);
    await prefs.remove(_keyUser);
  }
}
