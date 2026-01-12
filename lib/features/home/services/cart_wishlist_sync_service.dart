import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/cookie_utils.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';
import '../models/cart_wishlist_models.dart';

/// Service for syncing local cart and wishlist to server
/// Called on login or app initialization
class CartWishlistSyncService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Generate base64 encoded timestamp matching JavaScript btoa(new Date().toString())
  static String _getEncodedTimestamp() {
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

  /// Sync cart and wishlist with server counts
  /// For Random users: returns (0, 0)
  /// For Auth/Guest users: syncs local items and returns server counts
  static Future<({int cartCount, int wishlistCount})>
  syncCartWishlistWithCounts() async {
    try {
      final userType = await CookieUtils.getUserType();

      // Random users don't sync
      if (userType == 'random') {
        return (cartCount: 0, wishlistCount: 0);
      }

      final uid = await CookieUtils.resolveUid();

      // Get local cookie items
      final cartCookie = await CookieUtils.getCartCookie();
      final wishlistCookie = await CookieUtils.getWishlistCookie();

      final cartVariations = _parseCartCookie(cartCookie);
      final wishlistVariations = _parseWishlistCookie(wishlistCookie);

      // Build product lists
      final cartProductIds = cartVariations.map((v) => v.variationId).toList();
      final wishlistProductIds = wishlistVariations
          .map((item) => item.variationId)
          .toList();

      // Call COUNT endpoint
      final response = await _callCountEndpoint(
        uid: uid,
        cartProducts: cartProductIds,
        wishlistProducts: wishlistProductIds,
      );

      // Extract counts from response
      int cartCount = 0;
      int wishlistCount = 0;

      if (response != null && response['data'] != null) {
        cartCount = response['data']['cartCount'] ?? 0;
        wishlistCount = response['data']['wishlistCount'] ?? 0;
      }

      return (cartCount: cartCount, wishlistCount: wishlistCount);
    } catch (e) {
      print('Sync error: $e');
      return (cartCount: 0, wishlistCount: 0);
    }
  }

  /// Call the COUNT endpoint to sync items
  static Future<Map<String, dynamic>?> _callCountEndpoint({
    required String uid,
    required List<String> cartProducts,
    required List<String> wishlistProducts,
  }) async {
    try {
      final d = _getEncodedTimestamp();
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.count}/$uid/$d');

      final payload = {
        'c_products': cartProducts,
        'w_products': wishlistProducts,
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Count endpoint error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error calling COUNT endpoint: $e');
      return null;
    }
  }

  /// Parse cart cookie
  static List<CartVariation> _parseCartCookie(String? cartCookie) {
    if (cartCookie == null || cartCookie.isEmpty) {
      return [];
    }

    try {
      final json = jsonDecode(cartCookie) as List;
      return json
          .map((item) => CartVariation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Parse wishlist cookie
  static List<WishlistItem> _parseWishlistCookie(String? wishlistCookie) {
    if (wishlistCookie == null || wishlistCookie.isEmpty) {
      return [];
    }

    try {
      final json = jsonDecode(wishlistCookie) as Map<String, dynamic>;
      final wishlist = Wishlist.fromJson(json);
      return wishlist.items;
    } catch (e) {
      return [];
    }
  }
}
