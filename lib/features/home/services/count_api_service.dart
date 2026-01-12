import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';

/// Model for count response
class CountResponse {
  final bool isRandom;
  final int cartCount;
  final int wishlistCount;

  CountResponse({
    required this.isRandom,
    required this.cartCount,
    required this.wishlistCount,
  });

  factory CountResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CountResponse(
      isRandom: data['isRandom'] ?? false,
      cartCount: data['cartCount'] ?? 0,
      wishlistCount: data['wishlistCount'] ?? 0,
    );
  }
}

class CountApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Generate base64 encoded timestamp matching JavaScript btoa(new Date().toString())
  static String _getEncodedTimestamp() {
    // Format: "Tue Jan 06 2026 15:21:33 GMT+0530 (India Standard Time)"
    final now = DateTime.now();
    final weekday = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ][now.weekday % 7];
    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][now.month - 1];
    final day = now.day.toString().padLeft(2, '0');
    final year = now.year;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final offset = now.timeZoneOffset;
    final offsetHours = (offset.inHours).abs().toString().padLeft(2, '0');
    final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
      2,
      '0',
    );
    final offsetSign = offset.isNegative ? '-' : '+';

    final timestamp =
        '$weekday $month $day $year $hour:$minute:$second GMT$offsetSign$offsetHours$offsetMinutes (India Standard Time)';
    return base64Encode(utf8.encode(timestamp));
  }

  /// Get cart and wishlist counts
  /// For random users: send cached cart/wishlist variation codes
  /// For authenticated users: backend returns counts from database
  static Future<CountResponse> getCount({
    required String uid,
    List<String> cartProducts = const [],
    List<String> wishlistProducts = const [],
  }) async {
    try {
      final d = _getEncodedTimestamp();
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.count}/$uid/$d');

      final payload = {
        'c_products': cartProducts,
        'w_products': wishlistProducts,
      };

      debugPrint('Count API Payload: $payload');

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('Count API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CountResponse.fromJson(data);
      } else {
        throw Exception('Failed to get count (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting count: $e');
    }
  }
}
