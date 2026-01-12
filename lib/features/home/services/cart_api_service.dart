import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/auth_storage.dart';
import '../../../core/constants/api_urls.dart';
import '../models/cart_wishlist_models.dart';

class CartApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch bag (cart) data from server
  /// Sends UID and variations to get cart details with prices and stock status
  static Future<Cart> fetchBag({
    required String uid,
    required List<CartVariation> variations,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.bag}');

      final payload = {
        'uid': uid,
        'variations': variations
            .map((v) => {'variationId': v.variationId, 'quantity': v.quantity})
            .toList(),
        'd': _getEncodedTimestamp(),
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['messageCode'] == 100 || data['code'] == 100) {
          final fetchedCart = Cart.fromJson(data);

          // Merge quantities from local request into fetched items
          // API doesn't return quantity, so we must restore it from our request
          final quantityMap = {
            for (var v in variations) v.variationId: v.quantity,
          };

          final updatedItems = fetchedCart.items.map((item) {
            final qty = quantityMap[item.variationId] ?? 1;
            return item.copyWith(quantity: qty);
          }).toList();

          // Recalculate totals with correct quantities
          final subtotal = updatedItems.fold<double>(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          // Simple total calculation (add tax/shipping/discount logic if needed)
          final total =
              subtotal +
              fetchedCart.tax +
              fetchedCart.shipping -
              fetchedCart.discount;

          return fetchedCart.copyWith(
            items: updatedItems,
            subtotal: subtotal,
            total: total,
          );
        } else {
          // If the list is empty, sometimes code might differ or data might be null.
          // For now, respect the error code.
          throw Exception('Failed to fetch bag: ${data['message']}');
        }
      } else {
        throw Exception('Failed to fetch bag (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching bag: $e');
    }
  }

  /// Check stock status for product variations
  static Future<Map<String, bool>> checkStockStatus({
    required String uid,
    required List<CartVariation> variations,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.bag}');

      final payload = {
        'uid': uid,
        'variations': variations
            .map((v) => {'variationId': v.variationId, 'quantity': v.quantity})
            .toList(),
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cart = Cart.fromJson(data);

        // Build a map of variationId -> inStock status
        final stockMap = <String, bool>{};
        for (var item in cart.items) {
          stockMap[item.variationId] = item.inStock;
        }
        return stockMap;
      } else {
        throw Exception(
          'Failed to check stock status (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error checking stock status: $e');
    }
  }

  /// Proceed with order (checkout)
  /// Returns a token if successful
  static Future<String?> proceedOrder({
    required String uid,
    required List<CartVariation> variations,
    required String mode,
    required String addressCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.cart}');

      final payload = {
        'uid': uid,
        'variations': variations
            .map((v) => {'variationId': v.variationId, 'quantity': v.quantity})
            .toList(),
        'mode': mode,
        'addressCode': addressCode,
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check response code
        final code = data['code'] ?? 0;
        if (code == 100) {
          // Success - return token
          return data['token'];
        } else if (code == 102) {
          throw Exception('User not verified');
        } else {
          throw Exception('Order processing failed: ${data['message']}');
        }
      } else {
        throw Exception('Failed to proceed order (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error proceeding order: $e');
    }
  }

  /// Finalize order after token is obtained
  static Future<bool> finalizeOrder({
    required String token,
    required String uid,
    required String mode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.cart}');

      final payload = {
        'token': token,
        'uid': uid,
        'mode': mode,
        'action': 'finalize',
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code'] == 100;
      } else {
        throw Exception('Failed to finalize order (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error finalizing order: $e');
    }
  }

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

  /// Add item to cart
  static Future<bool> addToCart({
    required String uid,
    required String variationId,
    required int quantity,
    String? mappingCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.cartAdd}');

      final payload = {
        'uid': uid,
        'variationCode': variationId,
        'mappingCode': mappingCode ?? variationId,
        'd': _getEncodedTimestamp(),
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messageCode'] == 100 || data['code'] == 100;
      } else {
        throw Exception('Failed to add to cart (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  /// Remove item from cart
  static Future<bool> removeFromCart({
    required String uid,
    required String variationId,
    String? mappingCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/${PkSoftUrls.customer.cartRemove}');

      final payload = {
        'uid': uid,
        'variationCode': variationId,
        'mappingCode': mappingCode ?? variationId,
        'd': _getEncodedTimestamp(),
      };

      final response = await http.post(
        uri,
        headers: await AuthStorage.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messageCode'] == 100 || data['code'] == 100;
      } else {
        throw Exception('Failed to remove from cart (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }
}
