import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/api/pk/Customer/auth");
    // API_BASE_URL=http://192.168.1.9:5260/api/pk/Customer/auth
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "username": username,
        "password": password,
        "userType": 5,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed (${response.statusCode})");
    }
  }
}
