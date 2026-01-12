import 'package:flutter/material.dart';
import '../home/models/cart_wishlist_models.dart';
import '../home/services/wishlist_logic_service.dart';
import '../../core/widgets/app_image.dart';
// import 'widgets/like_button.dart'; // Removed

import '../../core/state/wishlist_state_manager.dart';

class WishlistScreen extends StatefulWidget {
  final bool showBackButton;
  const WishlistScreen({super.key, this.showBackButton = true});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late WishlistLogicService _wishlistLogic;
  final _wishlistManager = WishlistStateManager();

  @override
  void initState() {
    super.initState();
    _wishlistLogic = WishlistLogicService();
    // Add listener to rebuild when data changes
    _wishlistLogic.addListener(_onWishlistChanged);

    // Listen to global wishlist manager events (for consistent state across app)
    _wishlistManager.addListener(_onGlobalWishlistChanged);

    // Delay initialization to next frame to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWishlist();
    });
  }

  void _onWishlistChanged() {
    debugPrint('[WishlistScreen] Wishlist changed, rebuilding...');
    if (mounted) {
      setState(() {});
    }
  }

  void _onGlobalWishlistChanged() {
    if (!mounted || _wishlistLogic.isLoading) return;

    bool needsRefresh = false;

    // 1. Check if any currently displayed item was removed from global state
    for (var item in _wishlistLogic.wishlist.items) {
      if (!_wishlistManager.isInWishlist(item.variationId)) {
        needsRefresh = true;
        break;
      }
    }

    // 2. Check for count mismatch (items added externally)
    if (!needsRefresh && _wishlistManager.count != _wishlistLogic.itemCount) {
      needsRefresh = true;
    }

    if (needsRefresh) {
      debugPrint(
        '[WishlistScreen] Detected global state change, refreshing...',
      );
      // Refresh list to reflect changes (e.g. removed items disappearing)
      _wishlistLogic.initializeWishlist();
    }
  }

  void _initializeWishlist() async {
    try {
      debugPrint('[WishlistScreen] Starting wishlist initialization...');
      await _wishlistLogic.initializeWishlist();

      // SYNC: Update the global manager with what we just found
      // This ensures the heart icons everywhere are correct based on this fresh fetch
      for (var item in _wishlistLogic.wishlist.items) {
        if (!_wishlistManager.isInWishlist(item.variationId)) {
          // We can't easily "inject" into manager without triggering listeners
          // So we might just want to ensure manager knows about these.
          // _wishlistManager.initialize() usually fetches too.
        }
      }
      // Better: Just tell manager to initialize itself if it hasn't
      _wishlistManager.initialize();

      debugPrint('[WishlistScreen] Wishlist initialization complete');
    } catch (e) {
      debugPrint('[WishlistScreen] Error initializing wishlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: RichText(
          text: TextSpan(
            text: "My Wishlist ",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF282C3F),
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "${_wishlistLogic.itemCount} items",
                style: const TextStyle(
                  color: Color(0xFF94969F),
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _wishlistLogic.isLoading
          ? _buildLoadingState(context)
          : _wishlistLogic.wishlist.items.isEmpty
          ? _buildEmptyWishlist(context)
          : _buildWishlistGrid(context, colorScheme),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Loading your wishlist...',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your wishlist is empty',
            style: TextStyle(color: Color(0xFF94969F), fontSize: 20),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add items you love to your wishlist 💖',
            style: TextStyle(color: Color(0xFF94969F)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58, // Adjusted for taller cards to prevent overflow
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _wishlistLogic.wishlist.items.length,
      itemBuilder: (context, index) {
        final item = _wishlistLogic.wishlist.items[index];
        return _buildWishlistCard(context, item);
      },
    );
  }

  Widget _buildWishlistCard(BuildContext context, WishlistItem item) {
    final discount = (item.oldPrice != null && item.oldPrice! > item.price)
        ? ((item.oldPrice! - item.price) / item.oldPrice! * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        // Navigate to Product Detail
        // Assuming route generation or using a direct push
        Navigator.pushNamed(
          context,
          '/product/${item.variationId}', // Helper needed if named routes aren't dynamic like this
          arguments: item.variationId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: AppImage(imageUrl: item.image, fit: BoxFit.cover),
                  ),
                ),
                // Wishlist Icon (Close/Remove)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Logic to remove is handled by finding the WishlistButton in context usually,
                        // but here we call logic directly or use the manager
                        _wishlistManager.toggleWishlistWithApi(
                          variationId: item.variationId,
                          productId: item.productId,
                          name: item.name,
                          image: item.image,
                          price: item.price,
                          oldPrice: item.oldPrice,
                          inStock: item.inStock,
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
                // Discount Badge (Web: .discount-badge)
                if (discount > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF282C3F),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF282C3F),
                        ),
                      ),
                      if (item.oldPrice != null && item.oldPrice! > item.price)
                        Text(
                          '₹${item.oldPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: item.inStock
                          ? () {
                              // Move to Bag Logic
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC3545),
                        side: const BorderSide(color: Color(0xFFDC3545)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('MOVE TO BAG'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wishlistManager.removeListener(_onGlobalWishlistChanged);
    _wishlistLogic.removeListener(_onWishlistChanged);
    _wishlistLogic.dispose();
    super.dispose();
  }
}
