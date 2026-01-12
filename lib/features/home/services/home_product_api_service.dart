import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';

class ProductApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static Future<Map<String, dynamic>> fetchHomeProducts() async {
    final uri = Uri.parse("$_baseUrl/${PkSoftUrls.customer.details}");

    final res = await http.get(uri, headers: await AuthStorage.getHeaders());

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load home products (${res.statusCode})");
    }
  }
}
