import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/utils/cookie_utils.dart';
import '../models/cart_wishlist_models.dart';
import 'wishlist_api_service.dart';

/// Business logic for wishlist management
/// Handles role-based wishlist operations for Random, Guest, and Authenticated users
class WishlistLogicService with ChangeNotifier {
  Wishlist _wishlist = Wishlist.empty();
  bool _isLoading = false;
  String? _error;

  Wishlist get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _wishlist.itemCount;

  /// Initialize wishlist by fetching from API
  /// For Random/Guest users: also merges with cookie data if API returns empty
  /// For Authenticated users: relies solely on API data
  Future<void> initializeWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[WishlistLogic] Initializing wishlist...');

      final uid = await CookieUtils.resolveUid();
      final isAuth = await CookieUtils.isUserLoggedIn();
      debugPrint('[WishlistLogic] Resolved UID: $uid, isAuth: $isAuth');

      // Fetch wishlist from checklist endpoint
      debugPrint('[WishlistLogic] Fetching from checklist API...');
      _wishlist = await WishlistApiService.fetchCheckList(uid: uid);
      debugPrint(
        '[WishlistLogic] Received ${_wishlist.items.length} items from API',
      );

      // If empty and NOT authenticated, try to load from cookie
      if (!isAuth && _wishlist.items.isEmpty) {
        debugPrint(
          '[WishlistLogic] Guest/Random user & API empty, checking cookie...',
        );
        final wishlistCookie = await CookieUtils.getWishlistCookie();
        if (wishlistCookie != null && wishlistCookie.isNotEmpty) {
          _wishlist = _parseWishlistCookie(wishlistCookie);
          debugPrint(
            '[WishlistLogic] Loaded ${_wishlist.items.length} items from cookie',
          );
        }
      } else if (isAuth) {
        debugPrint('[WishlistLogic] Authenticated user, skipping cookie check');
      }

      debugPrint(
        '[WishlistLogic] Initialization complete with ${_wishlist.items.length} items',
      );
    } catch (e) {
      _error = 'Failed to load wishlist: $e';
      _wishlist = Wishlist.empty();
      debugPrint('[WishlistLogic] ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[WishlistLogic] State updated, notified listeners');
    }
  }

  /// Add item to wishlist
  /// Updates local cookie (only for unauth users) and syncs with server
  Future<void> addToWishlist({
    required String productId,
    required String variationId,
    required String name,
    required String image,
    required double price,
    double? oldPrice,
    required bool inStock,
    String? variant,
  }) async {
    try {
      final uid = await CookieUtils.resolveUid();
      final isAuth = await CookieUtils.isUserLoggedIn();

      // Add to local cookie first ONLY if not authenticated
      if (!isAuth) {
        await _addToWishlistCookie(
          productId: productId,
          variationId: variationId,
          name: name,
          image: image,
          price: price,
          oldPrice: oldPrice,
          inStock: inStock,
          variant: variant,
        );
      }

      // Sync with API
      await WishlistApiService.addToWishlist(
        uid: uid,
        variationCode: variationId,
      );

      // Refresh wishlist
      await initializeWishlist();
    } catch (e) {
      _error = 'Failed to add to wishlist: $e';
      notifyListeners();
    }
  }

  /// Remove item from wishlist
  Future<void> removeFromWishlist(String variationId) async {
    try {
      final uid = await CookieUtils.resolveUid();
      final isAuth = await CookieUtils.isUserLoggedIn();

      // Remove from local cookie ONLY if not authenticated
      if (!isAuth) {
        await _removeFromWishlistCookie(variationId);
      }

      // Sync with API
      await WishlistApiService.removeFromWishlist(
        uid: uid,
        variationCode: variationId,
      );

      // Refresh wishlist
      await initializeWishlist();
    } catch (e) {
      _error = 'Failed to remove from wishlist: $e';
      notifyListeners();
    }
  }

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlist.contains(productId);
  }

  /// Clear wishlist
  Future<void> clearWishlist() async {
    try {
      final isAuth = await CookieUtils.isUserLoggedIn();

      if (!isAuth) {
        await CookieUtils.clearWishlistCookie();
      }

      _wishlist = Wishlist.empty();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear wishlist: $e';
      notifyListeners();
    }
  }

  /// Private helpers

  /// Parse wishlist cookie to get Wishlist object
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

  /// Add item to wishlist cookie
  Future<void> _addToWishlistCookie({
    required String productId,
    required String variationId,
    required String name,
    required String image,
    required double price,
    double? oldPrice,
    required bool inStock,
    String? variant,
  }) async {
    try {
      final wishlistCookie = await CookieUtils.getWishlistCookie();
      final currentWishlist = _parseWishlistCookie(wishlistCookie);

      // Check if item already exists
      final existingIndex = currentWishlist.items.indexWhere(
        (item) => item.variationId == variationId,
      );

      if (existingIndex < 0) {
        // Add new item
        currentWishlist.items.add(
          WishlistItem(
            productId: productId,
            variationId: variationId,
            name: name,
            image: image,
            price: price,
            oldPrice: oldPrice,
            inStock: inStock,
            variant: variant,
            addedAt: DateTime.now(),
          ),
        );

        // Save to cookie
        final wishlistJson = jsonEncode(currentWishlist.toJson());
        await CookieUtils.setWishlistCookie(wishlistJson);
      }
    } catch (e) {
      _error = 'Failed to update wishlist cookie: $e';
    }
  }

  /// Remove item from wishlist cookie
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
      _error = 'Failed to remove from wishlist cookie: $e';
    }
  }
}
