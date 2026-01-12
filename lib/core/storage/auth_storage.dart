import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../cache/cache_manager.dart';
import '../utils/cookie_utils.dart';

class AuthStorage {
  static const String _keyJwt = "jwt_token";
  static const String _keyPkToken = "pksoft_token";
  static const String _keyUser = "user_data";
  static const String _keyVariationCode = "variation_code";

  static Future<void> saveLoginData({
    required String jwt,
    required String pkToken,
    required Map<String, dynamic> userModel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJwt, jwt);
    await prefs.setString(_keyPkToken, pkToken);
    await prefs.setString(_keyUser, jsonEncode(userModel));

    // Save variation code to Hive
    if (userModel['code'] != null) {
      await CacheManager.instance.set(_keyVariationCode, userModel['code']);
    }

    // Sync with CookieUtils for correct UID resolution
    final uid =
        userModel['code'] ??
        userModel['uid'] ??
        userModel['id'] ??
        userModel['userName'];
    if (uid != null) {
      // Ensure CookieUtils is initialized or use prefs directly if needed,
      // but calling setUserId is better to keep logic central.
      // Assuming CookieUtils is initialized in main.dart
      try {
        await CookieUtils.setUserId(uid.toString());
      } catch (e) {
        // Fallback if CookieUtils not initialized
        await prefs.setString('user_id', uid.toString());
      }
    }
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

    // Clear variation code from Hive
    await CacheManager.instance.clear(_keyVariationCode);

    // Clear CookieUtils data
    try {
      await CookieUtils.clearAllUserData();
    } catch (_) {
      await prefs.remove('user_id');
      await prefs.remove('guest_id');
    }
  }

  static Future<String?> getVariationCode() async {
    return CacheManager.instance.get<String>(_keyVariationCode);
  }

  static Future<String?> getPkToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPkToken);
  }

  static Future<Map<String, String>> getHeaders() async {
    final jwt = await getJwt();
    final pkToken = await getPkToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (jwt != null && jwt.isNotEmpty) {
      headers['jwt'] = jwt;
    }

    if (pkToken != null && pkToken.isNotEmpty) {
      headers['x-auth'] = pkToken;
    }

    return headers;
  }
}
