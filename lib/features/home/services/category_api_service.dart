import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CategoryApiService {
    static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';
  static const _fallback = [
    "All",
    "Dresses",
    "Shoes",
    "Bags",
    "Accessories",
    "Denim",
  ];

  static Future<List<String>> fetchCategories() async {
    try {
      final res = await http.get(
        Uri.parse("$_baseUrl/api/pk/Customer/load/category"),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> response = jsonDecode(res.body);
        final List data = response['data'] ?? [];
        return data.map((e) => e['name'].toString()).toList();
      }
    } catch (_) {}

    return _fallback;
  }
}
