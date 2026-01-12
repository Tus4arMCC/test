import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';
import '../models/cart_wishlist_models.dart';

class WishlistApiService {
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

  /// Fetch checklist (wishlist items) from server using the checklist endpoint
  /// This is the primary endpoint for fetching user's wishlist
  static Future<Wishlist> fetchCheckList({
    required String uid,
    List<String>? variationCodes,
  }) async {
    try {
      // Use POST to match the server expectation (CheckList endpoint usually expects POST with body)
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.checklist}');

      final payload = {'uid': uid, 'd': _getEncodedTimestamp()};

      debugPrint('Checklist API URL: $uri');
      debugPrint('Checklist API Payload: $payload');

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('Checklist API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wishlist.fromJson(data);
      } else if (response.statusCode == 404) {
        // No wishlist found, return empty
        return Wishlist.empty();
      } else {
        throw Exception('Failed to fetch checklist (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching checklist: $e');
    }
  }

  /// Fetch wishlist from server
  /// When variations is null, server returns user's saved wishlist
  /// When variations is provided, server validates and returns wishlist details
  static Future<Wishlist> fetchWishlist({
    required String uid,
    required String date,
    List<CartVariation>? variations,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.checklist}');

      final payload = {
        'uid': uid,
        'date': date,
        if (variations != null)
          'variations': variations
              .map(
                (v) => {'variationId': v.variationId, 'quantity': v.quantity},
              )
              .toList(),
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wishlist.fromJson(data);
      } else if (response.statusCode == 404) {
        // No wishlist found, return empty
        return Wishlist.empty();
      } else {
        throw Exception('Failed to fetch wishlist (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching wishlist: $e');
    }
  }

  /// Add item to wishlist
  static Future<bool> addToWishlist({
    required String uid,
    required String variationCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.wishlistAdd}');

      final payload = {
        'uid': uid,
        'variationCode': variationCode,
        'd': _getEncodedTimestamp(),
      };

      debugPrint('Add to Wishlist Payload: $payload');

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('Add to Wishlist Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messageCode'] == 100 || data['code'] == 100;
      } else {
        throw Exception('Failed to add to wishlist (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error adding to wishlist: $e');
    }
  }

  /// Remove item from wishlist
  static Future<bool> removeFromWishlist({
    required String uid,
    required String variationCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.wishlistRemove}');

      final payload = {
        'uid': uid,
        'variationCode': variationCode,
        'd': _getEncodedTimestamp(),
      };

      debugPrint('Remove from Wishlist Payload: $payload');

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('Remove from Wishlist Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messageCode'] == 100 || data['code'] == 100;
      } else {
        throw Exception(
          'Failed to remove from wishlist (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error removing from wishlist: $e');
    }
  }

  /// Sync checklist with a single variation code (or null)
  static Future<Wishlist> syncChecklist({
    required String uid,
    String? variationCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.checklist}');

      final payload = {
        'uid': uid,
        'variationCode': variationCode,
        'd': _getEncodedTimestamp(),
      };

      debugPrint('Sync Checklist API Payload: $payload');

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('Sync Checklist API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wishlist.fromJson(data);
      } else if (response.statusCode == 404) {
        return Wishlist.empty();
      } else {
        throw Exception('Failed to sync checklist (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error syncing checklist: $e');
    }
  }
}
