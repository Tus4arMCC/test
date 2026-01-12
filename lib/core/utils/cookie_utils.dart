import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Cookie utility for managing user identification across random, guest, and authenticated users
class CookieUtils {
  static const String _randomUserKey = 'random_user';
  static const String _guestIdKey = 'guest_id';
  static const String _userIdKey = 'user_id';
  static const String _cartCookieKey = 'cart';
  static const String _wishlistCookieKey = 'wishlist';

  static late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get or create a random user UUID
  static Future<String> getRandomUserId() async {
    String? randomId = _prefs.getString(_randomUserKey);
    if (randomId == null) {
      randomId = const Uuid().v4();
      await _prefs.setString(_randomUserKey, randomId);
    }
    return randomId;
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final userId = _prefs.getString(_userIdKey);
    return userId != null && userId.isNotEmpty;
  }

  /// Get user ID (for authenticated users)
  static Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  /// Set user ID (called after login)
  static Future<void> setUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  /// Get guest ID
  static Future<String?> getGuestId() async {
    return _prefs.getString(_guestIdKey);
  }

  /// Set guest ID
  static Future<void> setGuestId(String guestId) async {
    await _prefs.setString(_guestIdKey, guestId);
  }

  /// Resolve UID based on user hierarchy: user_id -> guest_id -> random_user
  /// Returns the appropriate user ID for the current user type
  static Future<String> resolveUid() async {
    // Check if authenticated user
    final userId = _prefs.getString(_userIdKey);
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }

    // Check if guest user
    final guestId = _prefs.getString(_guestIdKey);
    if (guestId != null && guestId.isNotEmpty) {
      return guestId;
    }

    // Default to random user
    return await getRandomUserId();
  }

  /// Get user type: 'auth', 'guest', or 'random'
  static Future<String> getUserType() async {
    final userId = _prefs.getString(_userIdKey);
    if (userId != null && userId.isNotEmpty) {
      return 'auth';
    }

    final guestId = _prefs.getString(_guestIdKey);
    if (guestId != null && guestId.isNotEmpty) {
      return 'guest';
    }

    return 'random';
  }

  /// Clear all user data (logout)
  static Future<void> clearAllUserData() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_guestIdKey);
    // Note: _randomUserKey is kept for tracking
  }

  /// Get cart cookie (JSON string of cart items)
  static Future<String?> getCartCookie() async {
    return _prefs.getString(_cartCookieKey);
  }

  /// Set cart cookie
  static Future<void> setCartCookie(String cartJson) async {
    await _prefs.setString(_cartCookieKey, cartJson);
  }

  /// Get wishlist cookie (JSON string of wishlist items)
  static Future<String?> getWishlistCookie() async {
    return _prefs.getString(_wishlistCookieKey);
  }

  /// Set wishlist cookie
  static Future<void> setWishlistCookie(String wishlistJson) async {
    await _prefs.setString(_wishlistCookieKey, wishlistJson);
  }

  /// Clear cart cookie
  static Future<void> clearCartCookie() async {
    await _prefs.remove(_cartCookieKey);
  }

  /// Clear wishlist cookie
  static Future<void> clearWishlistCookie() async {
    await _prefs.remove(_wishlistCookieKey);
  }
}
