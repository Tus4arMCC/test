import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';
import '../models/address_model.dart';
import '../../../core/utils/cookie_utils.dart';

class AddressApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<AddressModel>> fetchAddresses() async {
    final uid = await CookieUtils.resolveUid();
    final d = _getEncodedTimestamp();
    final uri = Uri.parse('$_baseUrl/${PkSoftUrls.address.get}/$uid/$d');
    final response = await http.get(
      uri,
      headers: await AuthStorage.getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List?) ?? (data['items'] as List?) ?? [];
      return list
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch addresses (${response.statusCode})');
  }

  static String _getEncodedTimestamp() {
    final now = DateTime.now();
    return base64Encode(utf8.encode(now.toString()));
  }

  static Future<AddressModel> createAddress(
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseUrl/${PkSoftUrls.address.create}');
    final response = await http.post(
      uri,
      headers: await AuthStorage.getHeaders(),
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final item = data['data'] ?? data;
      return AddressModel.fromJson(item as Map<String, dynamic>);
    }
    throw Exception('Failed to create address (${response.statusCode})');
  }
}
