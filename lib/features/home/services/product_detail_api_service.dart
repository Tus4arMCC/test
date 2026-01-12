import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';
import '../models/product_data_model.dart';

class ProductApiService {
  static final _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<ProductData> fetchProduct(String code) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/${PkSoftUrls.customer.product}/$code"),
      headers: await AuthStorage.getHeaders(),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception('Failed to load product');
    }
    return ProductData.fromJson(body['data']);
  }
}
