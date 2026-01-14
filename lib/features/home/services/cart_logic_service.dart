import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/utils/cookie_utils.dart';
import '../../../core/state/count_state_manager.dart';
import '../models/cart_wishlist_models.dart';
import 'cart_api_service.dart';

/// Business logic for cart management
/// Handles role-based cart operations for Random, Guest, and Authenticated users
class CartLogicService with ChangeNotifier {
  Cart _cart = Cart.empty();
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  Cart get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cart.itemCount;
  double get total => _cart.total;

  /// Initialize cart by fetching from API based on user type
  Future<void> initializeCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = await CookieUtils.resolveUid();
      final userType = await CookieUtils.getUserType();

      // Get variations from cookie
      final cartCookie = await CookieUtils.getCartCookie();
      final variations = _parseCartCookie(cartCookie);

      // For authenticated and guest users: ALWAYS try to fetch from API
      // The server will return all their bag items regardless of cookie state
      // For random users: Only fetch if there are items in the local cookie
      if (variations.isEmpty && userType == 'random') {
        _cart = Cart.empty();
      } else {
        // Fetch bag data from API
        // For auth/guest: variations will be empty, API returns all items
        // For random: variations has the items they added locally
        _cart = await CartApiService.fetchBag(uid: uid, variations: variations);
      }
    } catch (e) {
      _error = 'Failed to load cart: $e';

      // FALLBACK: Skeleton Cart for Random Users on API Failure
      // If API fails, show cached items with placeholder data so cart isn't empty
      try {
        final userType = await CookieUtils.getUserType();
        final cartCookie = await CookieUtils.getCartCookie();
        final variations = _parseCartCookie(cartCookie);

        if (userType == 'random' && variations.isNotEmpty) {
          List<CartProduct> skeletonItems = variations.map((v) {
            return CartProduct(
              productId: "",
              variationId: v.variationId,
              quantity: v.quantity,
              name: "Loading Item...",
              image: "",
              price: 0,
              oldPrice: 0,
              inStock: true,
            );
          }).toList();

          _cart = Cart(
            items: skeletonItems,
            total: 0,
            subtotal: 0,
            tax: 0,
            discount: 0,
            shipping: 0,
          );
          debugPrint("Used Skeleton Cart fallback for random user");
        } else {
          _cart = Cart.empty();
        }
      } catch (fallbackError) {
        debugPrint("Skeleton fallback failed: $fallbackError");
        _cart = Cart.empty();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addToCart({
    required String variationId,
    required int quantity,
    String? mappingCode,
  }) async {
    try {
      final uid = await CookieUtils.resolveUid();

      // Call cartAdd API directly
      final response = await CartApiService.addToCart(
        uid: uid,
        variationId: variationId,
        quantity: quantity,
        mappingCode: mappingCode,
      );

      if (!response.success) {
        throw Exception(response.message);
      }

      // Update local cart cookie
      await _updateCartCookie(
        variationId,
        quantity,
        isAdd: true,
        mappingCode: mappingCode,
      );

      return response.message;
    } catch (e) {
      _error = 'Failed to add to cart: $e';
      notifyListeners();
      rethrow;
    } finally {
      try {
        await CountStateManager().refresh();
      } catch (_) {}
    }
  }

  /// Update quantity of cart item
  Future<String> updateQuantity({
    required String variationId,
    required int newQuantity,
  }) async {
    try {
      if (newQuantity <= 0) {
        return await removeFromCart(variationId);
      }

      final uid = await CookieUtils.resolveUid();

      // Get mappingCode from cookie
      final cartCookie = await CookieUtils.getCartCookie();
      final variations = _parseCartCookie(cartCookie);
      final item = variations.firstWhere(
        (v) => v.variationId == variationId,
        orElse: () => CartVariation(variationId: '', quantity: 0),
      );
      final mappingCode = item.mappingCode;

      // Call cartAdd API with new quantity
      final response = await CartApiService.addToCart(
        uid: uid,
        variationId: variationId,
        quantity: newQuantity,
        mappingCode: mappingCode,
      );

      if (!response.success) {
        throw Exception(response.message);
      }

      // Update local cart cookie
      await _updateCartCookie(variationId, newQuantity, isAdd: false);

      return response.message;
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      notifyListeners();
      rethrow;
    } finally {
      try {
        await CountStateManager().refresh();
      } catch (_) {}
    }
  }

  /// Remove item from cart
  /// Returns the message from API response
  Future<String> removeFromCart(String variationId) async {
    try {
      final uid = await CookieUtils.resolveUid();

      // Retrieve mappingCode from cookie before removal
      final cartCookie = await CookieUtils.getCartCookie();
      final variations = _parseCartCookie(cartCookie);
      final item = variations.firstWhere(
        (v) => v.variationId == variationId,
        orElse: () => CartVariation(variationId: '', quantity: 0),
      );
      final mappingCode = item.mappingCode;
      final quantity = item.quantity;

      // Call cartRemove API
      final response = await CartApiService.removeFromCart(
        uid: uid,
        variationId: variationId,
        mappingCode: mappingCode,
        quantity: quantity,
      );

      if (!response.success) {
        throw Exception(response.message);
      }

      // Remove from local cookie
      await _removeFromCartCookie(variationId);

      return response.message;
    } catch (e) {
      _error = 'Failed to remove from cart: $e';
      notifyListeners();
      rethrow;
    } finally {
      try {
        await CountStateManager().refresh();
      } catch (_) {}
    }
  }

  /// Proceed with checkout
  /// Returns token if successful, throws exception otherwise
  Future<String> proceedCheckout({
    required List<String> selectedVariationIds,
    required String mode,
    required String addressCode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final uid = await CookieUtils.resolveUid();

      // Build variations list from selected items
      final selectedVariations = _cart.items
          .where((item) => selectedVariationIds.contains(item.variationId))
          .map(
            (item) => CartVariation(
              variationId: item.variationId,
              quantity: item.quantity,
            ),
          )
          .toList();

      // Call API
      final tokenResponse = await CartApiService.proceedOrder(
        uid: uid,
        variations: selectedVariations,
        mode: mode,
        addressCode: addressCode,
      );

      if (tokenResponse == null) {
        throw Exception('No token received from server');
      }

      // Extract token string from response
      final token =
          tokenResponse['token'] as String? ?? tokenResponse.toString();
      if (token.isEmpty) {
        throw Exception('Invalid token received from server');
      }

      // Finalize order
      await CartApiService.finalizeOrder(token: token, uid: uid);

      // Remove purchased items from cart cookie
      for (var variationId in selectedVariationIds) {
        await _removeFromCartCookie(variationId);
      }

      // Refresh cart
      await initializeCart();

      return token;
    } catch (e) {
      _error = 'Checkout failed: $e';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      try {
        await CountStateManager().refresh();
      } catch (_) {}
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    try {
      await CookieUtils.clearCartCookie();
      _cart = Cart.empty();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      notifyListeners();
    } finally {
      try {
        await CountStateManager().refresh();
      } catch (_) {}
    }
  }

  /// Private helpers

  /// Parse cart cookie to get list of variations
  List<CartVariation> _parseCartCookie(String? cartCookie) {
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

  /// Update cart cookie with new quantity
  Future<void> _updateCartCookie(
    String variationId,
    int quantity, {
    required bool isAdd,
    String? mappingCode,
  }) async {
    try {
      final cartCookie = await CookieUtils.getCartCookie();
      List<CartVariation> variations = _parseCartCookie(cartCookie);

      if (isAdd) {
        // Check if variation already exists
        final existingIndex = variations.indexWhere(
          (v) => v.variationId == variationId,
        );

        if (existingIndex >= 0) {
          // Update existing quantity
          // Preserve existing mappingCode if strict update, or overwrite if new one provided?
          // Usually mappingCode shouldn't change for same variation.
          final existing = variations[existingIndex];
          variations[existingIndex] = CartVariation(
            variationId: variationId,
            quantity: existing.quantity + quantity,
            mappingCode: mappingCode ?? existing.mappingCode,
          );
        } else {
          // Add new variation
          variations.add(
            CartVariation(
              variationId: variationId,
              quantity: quantity,
              mappingCode: mappingCode,
            ),
          );
        }
      } else {
        // Set exact quantity (for update)
        final existingIndex = variations.indexWhere(
          (v) => v.variationId == variationId,
        );

        if (existingIndex >= 0) {
          final existing = variations[existingIndex];
          variations[existingIndex] = CartVariation(
            variationId: variationId,
            quantity: quantity,
            mappingCode: mappingCode ?? existing.mappingCode,
          );
        }
      }

      // Save to cookie
      final cartJson = jsonEncode(variations.map((v) => v.toJson()).toList());
      await CookieUtils.setCartCookie(cartJson);
    } catch (e) {
      _error = 'Failed to update cart cookie: $e';
    }
  }

  /// Remove item from cart cookie
  Future<void> _removeFromCartCookie(String variationId) async {
    try {
      final cartCookie = await CookieUtils.getCartCookie();
      List<CartVariation> variations = _parseCartCookie(cartCookie);

      variations.removeWhere((v) => v.variationId == variationId);

      final cartJson = jsonEncode(variations.map((v) => v.toJson()).toList());
      if (variations.isEmpty) {
        await CookieUtils.clearCartCookie();
      } else {
        await CookieUtils.setCartCookie(cartJson);
      }
    } catch (e) {
      _error = 'Failed to remove from cart cookie: $e';
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
