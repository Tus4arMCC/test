import 'package:flutter/material.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/wishlist_button.dart';
import '../../home/models/product_model.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.product.isFavourite;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageUrl = resolveImageUrl(widget.product.primaryImage);

    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE + LIKE
          Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productCode: widget.product.code),
                  ),
                );
              },
              child: Stack(
                children: [
                  // Image Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: AppImage(
                        imageUrl: imageUrl ?? "",
                        fit: BoxFit.cover,
                        borderRadius: 16,
                      ),
                    ),
                  ),

                  /// WISHLIST BUTTON
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistButton(
                      variationId: widget.product.code,
                      isInWishlist: isFav,
                      productId: widget.product.code,
                      name: widget.product.name,
                      image: imageUrl,
                      price: widget.product.price,
                      oldPrice: widget.product.mrp,

                      iconSize: 18,
                      showBackground: true,
                      backgroundColor: theme.colorScheme.surface,
                      onWishlistChanged: (isInWishlist) {
                        setState(() {
                          isFav = isInWishlist;
                        });
                      },
                    ),
                  ),

                  /// OUT OF STOCK
                  if (widget.product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.black45,
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// NAME
          Text(
            widget.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          /// SELLER
          Text(
            widget.product.seller,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),

          const SizedBox(height: 4),

          // Rating Badge
          if (widget.product.rating > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.product.rating < 2.6
                      ? Colors.red
                      : widget.product.rating < 3.6
                      ? Colors.amber
                      : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, size: 10, color: Colors.white),
                  ],
                ),
              ),
            ),

          /// PRICE
          Row(
            children: [
              Text(
                "₹${widget.product.price}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "₹${widget.product.mrp}",
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
