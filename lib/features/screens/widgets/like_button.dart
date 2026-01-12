import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/cookie_utils.dart';

/// Reusable like/wishlist button component
/// Handles both adding to and removing from wishlist
class LikeButton extends StatefulWidget {
  final String variationCode;
  final bool initiallyLiked;
  final VoidCallback? onLikeChanged;
  final double iconSize;
  final Color? likedColor;
  final Color? unlikedColor;

  const LikeButton({
    super.key,
    required this.variationCode,
    this.initiallyLiked = false,
    this.onLikeChanged,
    this.iconSize = 24,
    this.likedColor,
    this.unlikedColor,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _isLiked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initiallyLiked;
  }

  /// Generate base64 encoded timestamp
  String _getEncodedTimestamp() {
    final timestamp = DateTime.now().toString();
    return base64Encode(utf8.encode(timestamp));
  }

  /// Toggle like/unlike
  Future<void> _toggleLike() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final uid = await CookieUtils.resolveUid();

      // Call appropriate wishlist API based on current state
      final success = _isLiked
          ? await _callRemoveWishlistApi(
              uid: uid,
              variationCode: widget.variationCode,
            )
          : await _callAddWishlistApi(
              uid: uid,
              variationCode: widget.variationCode,
            );

      if (success) {
        setState(() {
          _isLiked = !_isLiked;
        });
        widget.onLikeChanged?.call();
      }
    } catch (e) {
      debugPrint('Like button error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Call add to wishlist API endpoint
  Future<bool> _callAddWishlistApi({
    required String uid,
    required String variationCode,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final uri = Uri.parse('$baseUrl/api/pk/Customer/wishlist/add');

      final payload = {
        'uid': uid,
        'variationCode': variationCode,
        'd': _getEncodedTimestamp(),
      };

      debugPrint('Add Wishlist API Payload: $payload');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('Add Wishlist API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final code = data['code'] ?? 0;
        return code == 100; // Success code
      } else {
        debugPrint('Add Wishlist API Error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Add Wishlist API Exception: $e');
      return false;
    }
  }

  /// Call remove from wishlist API endpoint
  Future<bool> _callRemoveWishlistApi({
    required String uid,
    required String variationCode,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final uri = Uri.parse('$baseUrl/api/pk/Customer/wishlist/remove');

      final payload = {
        'uid': uid,
        'variationCode': variationCode,
        'd': _getEncodedTimestamp(),
      };

      debugPrint('Remove Wishlist API Payload: $payload');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('Remove Wishlist API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final code = data['code'] ?? 0;
        return code == 100; // Success code
      } else {
        debugPrint('Remove Wishlist API Error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Remove Wishlist API Exception: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final likedColor = widget.likedColor ?? Colors.red;
    final unlikedColor = widget.unlikedColor ?? Colors.grey;

    return GestureDetector(
      onTap: _isLoading ? null : _toggleLike,
      child: Tooltip(
        message: _isLiked ? 'Remove from wishlist' : 'Add to wishlist',
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: _isLoading
              ? SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isLiked ? likedColor : unlikedColor,
                    ),
                  ),
                )
              : Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_outline,
                  size: widget.iconSize,
                  color: _isLiked ? likedColor : unlikedColor,
                ),
        ),
      ),
    );
  }
}
