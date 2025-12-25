import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_detail_model.dart';
class ProductApiService {
  static final _baseUrl = dotenv.env['API_BASE_URL']!;

static Future<ProductDetail> fetchProduct(String code) async {
  final res = await http.get(
    Uri.parse("$_baseUrl/api/pk/Customer/product/$code"),
  );

  final body = jsonDecode(res.body);

  // ✅ THIS IS THE FIX
  if (res.statusCode != 200) {
    throw Exception('Failed to load product');
  }
  return ProductDetail.fromJson(body['data']);
}

}
