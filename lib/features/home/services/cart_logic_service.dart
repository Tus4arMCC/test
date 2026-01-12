import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/utils/cookie_utils.dart';
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

      // Get variations from cookie
      final cartCookie = await CookieUtils.getCartCookie();
      final variations = _parseCartCookie(cartCookie);

      if (variations.isEmpty) {
        _cart = Cart.empty();
      } else {
        // Fetch bag data from API
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

  /// Add item to cart
  /// For Random users: updates local state and debounces API call
  /// For Guest/Auth users: updates local state and immediately calls API
  Future<void> addToCart({
    required String variationId,
    required int quantity,
    String? mappingCode,
  }) async {
    try {
      final uid = await CookieUtils.resolveUid();
      final userType = await CookieUtils.getUserType();

      // Update local cart cookie
      await _updateCartCookie(
        variationId,
        quantity,
        isAdd: true,
        mappingCode: mappingCode,
      );

      // For random users, debounce the stock check
      if (userType == 'random') {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
          await _checkStockStatus(uid);
        });
      } else {
        // For auth/guest users, immediately check stock
        await _checkStockStatus(uid);
      }

      // Refresh cart display
      await initializeCart();
    } catch (e) {
      _error = 'Failed to add to cart: $e';
      notifyListeners();
    }
  }

  /// Update quantity of cart item
  Future<void> updateQuantity({
    required String variationId,
    required int newQuantity,
  }) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(variationId);
        return;
      }

      final uid = await CookieUtils.resolveUid();
      final userType = await CookieUtils.getUserType();

      // Update local cart cookie. MappingCode is not needed for update as it should exist.
      await _updateCartCookie(variationId, newQuantity, isAdd: false);

      // Debounce stock check for random users
      if (userType == 'random') {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
          await _checkStockStatus(uid);
        });
      } else {
        await _checkStockStatus(uid);
      }

      // Refresh cart
      await initializeCart();
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      notifyListeners();
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String variationId) async {
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

      // Remove from local cookie
      await _removeFromCartCookie(variationId);

      // Call API
      await CartApiService.removeFromCart(
        uid: uid,
        variationId: variationId,
        mappingCode: mappingCode,
      );

      // Refresh cart
      await initializeCart();
    } catch (e) {
      _error = 'Failed to remove from cart: $e';
      notifyListeners();
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
              // We might need mappingCode here too but CartProduct doesn't fully expose it
              // unless we map it from the cart cookie if locally available.
              // For now assuming backend knows mapping from variationId or it's not critical for checkout step 1.
            ),
          )
          .toList();

      // Call API
      final token = await CartApiService.proceedOrder(
        uid: uid,
        variations: selectedVariations,
        mode: mode,
        addressCode: addressCode,
      );

      if (token == null) {
        throw Exception('No token received from server');
      }

      // Finalize order
      await CartApiService.finalizeOrder(token: token, uid: uid, mode: mode);

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

  /// Check stock status for cart items
  Future<void> _checkStockStatus(String uid) async {
    try {
      final cartCookie = await CookieUtils.getCartCookie();
      final variations = _parseCartCookie(cartCookie);

      if (variations.isEmpty) return;

      final stockMap = await CartApiService.checkStockStatus(
        uid: uid,
        variations: variations,
      );

      // Update cart items with stock status
      for (var item in _cart.items) {
        if (stockMap.containsKey(item.variationId)) {
          // In a real app, you might mark out-of-stock items
          // For now, just track the status
        }
      }
    } catch (e) {
      debugPrint('Stock check error: $e');
      // Don't show error for stock check, just log it
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
