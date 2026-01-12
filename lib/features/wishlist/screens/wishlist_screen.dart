import 'package:flutter/material.dart';
import '../../home/models/product_model.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/wishlist_button.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // View Mode: 'Grid' or 'List'
  String _viewMode = 'Grid';

  // Mock Data mimicking the HTML content
  final List<Product> _wishlistItems = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
        centerTitle: true,
        title: Text(
          "My Wishlist",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_bag_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_wishlistItems.length} items saved",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Custom Segmented Control
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildViewToggleBtn(Icons.grid_view, "Grid", colorScheme),
                      const SizedBox(width: 4),
                      _buildViewToggleBtn(Icons.view_list, "List", colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _viewMode == 'Grid'
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wishlistItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              itemBuilder: (context, index) {
                return _WishlistGridItem(product: _wishlistItems[index]);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _wishlistItems.length,
              separatorBuilder: (_, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _WishlistGridItem(product: _wishlistItems[index]);
              },
            ),
    );
  }

  Widget _buildViewToggleBtn(
    IconData icon,
    String mode,
    ColorScheme colorScheme,
  ) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? colorScheme.primary : Colors.grey,
        ),
      ),
    );
  }
}

class _WishlistGridItem extends StatelessWidget {
  final Product product;

  const _WishlistGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Explicitly getting String for image
    String imageUrl = product.primaryImage ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image & Actions
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Remove from Wishlist Button
              Positioned(
                top: 8,
                right: 8,
                child: WishlistButton(
                  variationId: product.code,
                  isInWishlist: true, // Always true in wishlist screen
                  iconSize: 18,
                  showBackground: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  onWishlistChanged: (isInWishlist) {
                    // Item removed from wishlist, could refresh the list here
                  },
                ),
              ),

              // Low Stock Badge (Conditional - just demoing on first item for visual match)
              if (product.code == "1")
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "LOW STOCK",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Brand
        Text(
          product.seller.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Name
        Text(
          product.name,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Price
        Row(
          children: [
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.mrp > product.price) ...[
              const SizedBox(width: 8),
              Text(
                "\$${product.mrp.toStringAsFixed(2)}",
                style: textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Move to Bag Button
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Move to Bag",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
