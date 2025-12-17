import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _loginUrl =
      "http://192.168.1.6:5260/api/pk/Customer/auth";

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        // MUST match Swagger model exactly
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Login failed ${response.statusCode}: ${response.body}",
      );
    }
  }
}
