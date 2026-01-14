import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/storage/auth_storage.dart';
import '../../core/utils/date_utils.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse("$_baseUrl/api/pk/Customer/auth");
    final response = await http.post(
      uri,
      headers: await AuthStorage.getHeaders(),
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed ${response.statusCode}: ${response.body}");
    }
  }

  // LOGIN (already working)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String emailId,
    required String mobile,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/api/pk/Customer/register"),
      headers: await AuthStorage.getHeaders(),
      body: jsonEncode({
        "name": name,
        "emailId": emailId,
        "mobile": mobile,
        "postingDate": getPostingDate(),
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Registration failed: ${res.statusCode}");
    }
  }

  /// OTP VERIFY
  static Future<Map<String, dynamic>> verifyOtp({
    required String emailId,
    required String token,
    required String otpCode,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/api/pk/Customer/verify-otp"),
      headers: await AuthStorage.getHeaders(),
      body: jsonEncode({
        "emailId": emailId,
        "token": token,
        "otpCode": otpCode,
        "postingDate": getPostingDate(),
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("OTP Verification failed: ${res.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> forgetPassword({
    required String username,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/api/pk/Customer/update-password"),
      headers: await AuthStorage.getHeaders(),
      body: jsonEncode({"username": username, "password": newPassword}),
    );
    return jsonDecode(res.body);
  }
}
