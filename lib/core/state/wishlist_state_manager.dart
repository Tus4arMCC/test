import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../features/home/models/cart_wishlist_models.dart';
import '../../features/home/services/wishlist_api_service.dart';
import '../utils/cookie_utils.dart';

/// Global wishlist state manager
/// Tracks which products are in the wishlist across the entire app
class WishlistStateManager extends ChangeNotifier {
  static final WishlistStateManager _instance =
      WishlistStateManager._internal();
  factory WishlistStateManager() => _instance;
  WishlistStateManager._internal();

  final Set<String> _wishlistVariationCodes = {};
  bool _isInitialized = false;

  /// Check if a product is in the wishlist
  bool isInWishlist(String variationCode) {
    return _wishlistVariationCodes.contains(variationCode);
  }

  /// Toggle wishlist state (Handles both API and Cookie)
  Future<void> toggleWishlistWithApi({
    required String variationId,
    String? productId,
    String? name,
    String? image,
    double? price,
    double? oldPrice,
    bool inStock = true,
  }) async {
    // 1. Optimistic UI Update
    final isAdding = !_wishlistVariationCodes.contains(variationId);
    if (isAdding) {
      _wishlistVariationCodes.add(variationId);
    } else {
      _wishlistVariationCodes.remove(variationId);
    }
    notifyListeners();

    try {
      final uid = await CookieUtils.resolveUid();
      // final userType = await CookieUtils.getUserType(); // Old check
      final isAuth = await CookieUtils.isUserLoggedIn();

      // 2. Cookie Update (ONLY if NOT authenticated)
      if (!isAuth) {
        if (isAdding) {
          await _addToWishlistCookie(
            productId: productId ?? variationId,
            variationId: variationId,
            name: name ?? 'Unknown Product',
            image: image ?? '',
            price: price ?? 0,
            oldPrice: oldPrice,
            inStock: inStock,
          );
        } else {
          await _removeFromWishlistCookie(variationId);
        }
      }

      // 3. API Sync (Always sync with API)
      if (isAdding) {
        await WishlistApiService.addToWishlist(
          uid: uid,
          variationCode: variationId,
        );
      } else {
        await WishlistApiService.removeFromWishlist(
          uid: uid,
          variationCode: variationId,
        );
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      // Verify state from server if error occurs?
    }
  }

  /// Initialize wishlist state from backend/cookie
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final uid = await CookieUtils.resolveUid();
      final isAuth = await CookieUtils.isUserLoggedIn();

      // Load from API
      // Use syncChecklist to get IDs
      final wishlist = await WishlistApiService.fetchCheckList(uid: uid);

      _wishlistVariationCodes.clear();
      for (var item in wishlist.items) {
        _wishlistVariationCodes.add(item.variationId);
      }

      // Also merge from cookie if needed (Random/Guest specific)
      // Only do this if NOT authenticated
      if (!isAuth) {
        final cookieJson = await CookieUtils.getWishlistCookie();
        if (cookieJson != null) {
          final cookieWishlist = _parseWishlistCookie(cookieJson);
          for (var item in cookieWishlist.items) {
            _wishlistVariationCodes.add(item.variationId);
          }
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing wishlist state: $e');
    }
  }

  /// Refresh wishlist from backend
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  /// Clear all wishlist state
  void clear() {
    _wishlistVariationCodes.clear();
    _isInitialized = false;
    notifyListeners();
  }

  /// Get wishlist count
  int get count => _wishlistVariationCodes.length;

  // --- Cookie Helpers (Duplicated from WishlistLogicService for Independence) ---

  Wishlist _parseWishlistCookie(String? wishlistCookie) {
    if (wishlistCookie == null || wishlistCookie.isEmpty) {
      return Wishlist.empty();
    }
    try {
      final json = jsonDecode(wishlistCookie) as Map<String, dynamic>;
      return Wishlist.fromJson(json);
    } catch (e) {
      return Wishlist.empty();
    }
  }

  Future<void> _addToWishlistCookie({
    required String productId,
    required String variationId,
    required String name,
    required String image,
    required double price,
    double? oldPrice,
    required bool inStock,
  }) async {
    try {
      final wishlistCookie = await CookieUtils.getWishlistCookie();
      final currentWishlist = _parseWishlistCookie(wishlistCookie);

      final existingIndex = currentWishlist.items.indexWhere(
        (item) => item.variationId == variationId,
      );

      if (existingIndex < 0) {
        currentWishlist.items.add(
          WishlistItem(
            productId: productId,
            variationId: variationId,
            name: name,
            image: image,
            price: price,
            oldPrice: oldPrice,
            inStock: inStock,
            addedAt: DateTime.now(),
          ),
        );
        final wishlistJson = jsonEncode(currentWishlist.toJson());
        await CookieUtils.setWishlistCookie(wishlistJson);
      }
    } catch (e) {
      debugPrint('Failed to update wishlist cookie: $e');
    }
  }

  Future<void> _removeFromWishlistCookie(String variationId) async {
    try {
      final wishlistCookie = await CookieUtils.getWishlistCookie();
      final currentWishlist = _parseWishlistCookie(wishlistCookie);

      currentWishlist.items.removeWhere(
        (item) => item.variationId == variationId,
      );

      if (currentWishlist.items.isEmpty) {
        await CookieUtils.clearWishlistCookie();
      } else {
        final wishlistJson = jsonEncode(currentWishlist.toJson());
        await CookieUtils.setWishlistCookie(wishlistJson);
      }
    } catch (e) {
      debugPrint('Failed to remove from wishlist cookie: $e');
    }
  }
}
