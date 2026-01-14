import 'package:flutter/material.dart';
import '../state/wishlist_state_manager.dart';
import '../state/count_state_manager.dart';

/// A reusable wishlist/like button component that handles adding/removing items
/// from the wishlist with backend integration
class WishlistButton extends StatefulWidget {
  /// The variation ID of the product
  final String variationId;

  /// Whether the item is currently in the wishlist (initial state)
  final bool isInWishlist;

  /// Callback when wishlist state changes
  final ValueChanged<bool>? onWishlistChanged;

  /// Size of the icon
  final double iconSize;

  /// Color when item is in wishlist
  final Color? activeColor;

  /// Color when item is not in wishlist
  final Color? inactiveColor;

  /// Whether to show a background circle
  final bool showBackground;

  /// Background color
  final Color? backgroundColor;

  // Optional Product Details for Random User Cookie Storage
  final String? productId;
  final String? name;
  final String? image;
  final double? price;
  final double? oldPrice;
  final bool inStock;

  const WishlistButton({
    super.key,
    required this.variationId,
    required this.isInWishlist,
    this.onWishlistChanged,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
    this.showBackground = false,
    this.backgroundColor,
    this.productId,
    this.name,
    this.image,
    this.price,
    this.oldPrice,
    this.inStock = true,
  });

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton>
    with SingleTickerProviderStateMixin {
  late bool _isInWishlist;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _wishlistManager = WishlistStateManager();
  final _countManager = CountStateManager();

  @override
  void initState() {
    super.initState();
    // Prefer explicit widget state from API; fall back to global manager
    _isInWishlist =
        widget.isInWishlist ||
        _wishlistManager.isInWishlist(widget.variationId);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to global wishlist changes
    _wishlistManager.addListener(_onWishlistStateChanged);
  }

  @override
  void didUpdateWidget(covariant WishlistButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent passes new API data, keep local state in sync.
    if (oldWidget.variationId != widget.variationId ||
        oldWidget.isInWishlist != widget.isInWishlist) {
      _isInWishlist =
          widget.isInWishlist ||
          _wishlistManager.isInWishlist(widget.variationId);
    }
  }

  void _onWishlistStateChanged() {
    if (mounted) {
      final newState = _wishlistManager.isInWishlist(widget.variationId);
      if (newState != _isInWishlist) {
        setState(() {
          _isInWishlist = newState;
        });
      }
    }
  }

  @override
  void dispose() {
    _wishlistManager.removeListener(_onWishlistStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleWishlist() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Animate the button
      await _animationController.forward();
      await _animationController.reverse();

      // Toggle via Manager (References Global Logic)
      await _wishlistManager.toggleWishlistWithApi(
        variationId: widget.variationId,
        productId: widget.productId,
        name: widget.name,
        image: widget.image,
        price: widget.price,
        oldPrice: widget.oldPrice,
        inStock: widget.inStock,
      );

      // Update count locally
      // Check current state from Manager (Link of truth)
      final inWishlist = _wishlistManager.isInWishlist(widget.variationId);
      if (inWishlist) {
        _countManager.incrementWishlist();
      } else {
        _countManager.decrementWishlist();
      }

      widget.onWishlistChanged?.call(inWishlist);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeColor = widget.activeColor ?? colorScheme.error;
    final inactiveColor =
        widget.inactiveColor ?? colorScheme.onSurface.withValues(alpha: 0.6);

    Widget iconWidget = ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(
        _isInWishlist ? Icons.favorite : Icons.favorite_border,
        color: _isInWishlist ? activeColor : inactiveColor,
        size: widget.iconSize,
      ),
    );

    if (_isLoading) {
      iconWidget = SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _isInWishlist ? activeColor : inactiveColor,
          ),
        ),
      );
    }

    Widget button = IconButton(
      onPressed: _isLoading ? null : _toggleWishlist,
      icon: iconWidget,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: widget.iconSize,
    );

    if (widget.showBackground) {
      button = Container(
        width: widget.iconSize + 16,
        height: widget.iconSize + 16,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: button),
      );
    }

    return button;
  }
}
