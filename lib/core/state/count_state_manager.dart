import 'package:flutter/foundation.dart';
import '../../features/home/services/count_api_service.dart';
import '../storage/auth_storage.dart';
import '../cache/cache_manager.dart';

/// Global state manager for cart and wishlist counts
/// Handles both random (not logged in) and authenticated users
class CountStateManager extends ChangeNotifier {
  static final CountStateManager _instance = CountStateManager._internal();
  factory CountStateManager() => _instance;
  CountStateManager._internal();

  int _cartCount = 0;
  int _wishlistCount = 0;
  bool _isRandom = true;
  bool _isInitialized = false;

  // Cache keys
  static const String _keyCartProducts = 'random_cart_products';
  static const String _keyWishlistProducts = 'random_wishlist_products';
  static const String _keyIsRandom = 'is_random_user';

  int get cartCount => _cartCount;
  int get wishlistCount => _wishlistCount;
  bool get isRandom => _isRandom;

  /// Initialize counts from backend
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final user = await AuthStorage.getUser();
      final uid =
          user?['uid'] ?? user?['id'] ?? user?['code'] ?? user?['userName'];

      if (uid == null) {
        debugPrint('No user found, skipping count initialization');
        return;
      }

      // Get cached products for random users
      final cartProducts = await _getCachedCartProducts();
      final wishlistProducts = await _getCachedWishlistProducts();

      // Fetch counts from backend
      final response = await CountApiService.getCount(
        uid: uid.toString(),
        cartProducts: cartProducts,
        wishlistProducts: wishlistProducts,
      );

      _cartCount = response.cartCount;
      _wishlistCount = response.wishlistCount;
      _isRandom = response.isRandom;

      // Save isRandom status
      await CacheManager.instance.set(_keyIsRandom, _isRandom);

      // If user is NOT random (authenticated), clear the local random cache
      // The server is now the Source of Truth, and any local items have been merged
      if (!_isRandom) {
        await CacheManager.instance.clear(_keyCartProducts);
        await CacheManager.instance.clear(_keyWishlistProducts);
        debugPrint('User is authenticated. Cleared local random cache.');
      }

      _isInitialized = true;
      notifyListeners();

      debugPrint(
        'Count initialized: Cart=$_cartCount, Wishlist=$_wishlistCount, IsRandom=$_isRandom',
      );
    } catch (e) {
      debugPrint('Error initializing counts: $e');
    }
  }

  /// Refresh counts from backend
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  /// Update cart count locally
  void updateCartCount(int count) {
    _cartCount = count;
    notifyListeners();
  }

  /// Update wishlist count locally
  void updateWishlistCount(int count) {
    _wishlistCount = count;
    notifyListeners();
  }

  /// Increment cart count
  void incrementCart() {
    _cartCount++;
    notifyListeners();
  }

  /// Decrement cart count
  void decrementCart() {
    if (_cartCount > 0) {
      _cartCount--;
      notifyListeners();
    }
  }

  /// Increment wishlist count
  void incrementWishlist() {
    _wishlistCount++;
    notifyListeners();
  }

  /// Decrement wishlist count
  void decrementWishlist() {
    if (_wishlistCount > 0) {
      _wishlistCount--;
      notifyListeners();
    }
  }

  /// Add product to random user cart cache
  Future<void> addToRandomCart(String variationCode) async {
    if (!_isRandom) return;

    final products = await _getCachedCartProducts();
    if (!products.contains(variationCode)) {
      products.add(variationCode);
      await _saveCachedCartProducts(products);
      incrementCart();
    }
  }

  /// Remove product from random user cart cache
  Future<void> removeFromRandomCart(String variationCode) async {
    if (!_isRandom) return;

    final products = await _getCachedCartProducts();
    if (products.remove(variationCode)) {
      await _saveCachedCartProducts(products);
      decrementCart();
    }
  }

  /// Add product to random user wishlist cache
  Future<void> addToRandomWishlist(String variationCode) async {
    if (!_isRandom) return;

    final products = await _getCachedWishlistProducts();
    if (!products.contains(variationCode)) {
      products.add(variationCode);
      await _saveCachedWishlistProducts(products);
      incrementWishlist();
    }
  }

  /// Remove product from random user wishlist cache
  Future<void> removeFromRandomWishlist(String variationCode) async {
    if (!_isRandom) return;

    final products = await _getCachedWishlistProducts();
    if (products.remove(variationCode)) {
      await _saveCachedWishlistProducts(products);
      decrementWishlist();
    }
  }

  /// Clear all counts (on logout)
  Future<void> clear() async {
    _cartCount = 0;
    _wishlistCount = 0;
    _isRandom = true;
    _isInitialized = false;

    // Clear cached products
    await CacheManager.instance.clear(_keyCartProducts);
    await CacheManager.instance.clear(_keyWishlistProducts);
    await CacheManager.instance.clear(_keyIsRandom);

    notifyListeners();
  }

  // Private helper methods

  Future<List<String>> _getCachedCartProducts() async {
    final cached = CacheManager.instance.get<String>(_keyCartProducts);
    if (cached == null || cached.isEmpty) return [];

    try {
      final List<dynamic> list = (cached as List);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveCachedCartProducts(List<String> products) async {
    await CacheManager.instance.set(_keyCartProducts, products);
  }

  Future<List<String>> _getCachedWishlistProducts() async {
    final cached = CacheManager.instance.get<String>(_keyWishlistProducts);
    if (cached == null || cached.isEmpty) return [];

    try {
      final List<dynamic> list = (cached as List);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveCachedWishlistProducts(List<String> products) async {
    await CacheManager.instance.set(_keyWishlistProducts, products);
  }
}
