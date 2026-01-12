// Example usage of LikeButton component in different screens

import 'package:flutter/material.dart';
import './like_button.dart';

// ============================================
// EXAMPLE 1: In Product Details Screen
// ============================================

class ProductDetailsExample extends StatefulWidget {
  final String productVariationCode = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

  @override
  State<ProductDetailsExample> createState() => _ProductDetailsExampleState();
}

class _ProductDetailsExampleState extends State<ProductDetailsExample> {
  bool _isInWishlist = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          LikeButton(
            variationCode: widget.productVariationCode,
            initiallyLiked: _isInWishlist,
            onLikeChanged: () {
              setState(() {
                _isInWishlist = !_isInWishlist;
              });
              // Show snackbar feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isInWishlist
                        ? 'Added to wishlist'
                        : 'Removed from wishlist',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            iconSize: 28,
            likedColor: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: Text('Product Image')),
            ),
            const SizedBox(height: 24),

            // Product title with inline like button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const Text(
                    'Premium Wireless Headphones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                LikeButton(
                  variationCode: widget.productVariationCode,
                  initiallyLiked: _isInWishlist,
                  onLikeChanged: () {
                    setState(() {
                      _isInWishlist = !_isInWishlist;
                    });
                  },
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price
            const Text(
              '\$99.99',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'High-quality sound with noise cancellation. Perfect for music lovers.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EXAMPLE 2: In Product List/Grid Item
// ============================================

class ProductGridItemExample extends StatefulWidget {
  final String productName;
  final String productImage;
  final String variationCode;

  const ProductGridItemExample({
    required this.productName,
    required this.productImage,
    required this.variationCode,
  });

  @override
  State<ProductGridItemExample> createState() => _ProductGridItemExampleState();
}

class _ProductGridItemExampleState extends State<ProductGridItemExample> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with like button overlay
          Stack(
            children: [
              Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: Text('Product Image')),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: LikeButton(
                  variationCode: widget.variationCode,
                  initiallyLiked: _isLiked,
                  onLikeChanged: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                  iconSize: 28,
                  likedColor: Colors.red,
                  unlikedColor: Colors.white,
                ),
              ),
            ],
          ),

          // Product details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$49.99',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// EXAMPLE 3: In Cart Item
// ============================================

class CartItemWithLikeExample extends StatefulWidget {
  final String variationCode;

  const CartItemWithLikeExample({required this.variationCode});

  @override
  State<CartItemWithLikeExample> createState() =>
      _CartItemWithLikeExampleState();
}

class _CartItemWithLikeExampleState extends State<CartItemWithLikeExample> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Center(child: Text('Image')),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('\$29.99'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Qty: 2'),
                    const Spacer(),
                    // Like button
                    LikeButton(
                      variationCode: widget.variationCode,
                      initiallyLiked: _isLiked,
                      onLikeChanged: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
