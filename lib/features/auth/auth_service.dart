import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _loginUrl =
      "http://192.168.1.9:5260/api/Auth/login";

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(_loginUrl);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "username": username,
        "password": password,
        // ❗ only include fields Swagger expects
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        "Login failed ${response.statusCode}: ${response.body}",
      );
    }
  }
}
