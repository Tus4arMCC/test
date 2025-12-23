import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

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

  /// Pick primary image (future-proof)
  String? get _imageUrl {
    if (widget.product.images.isEmpty) return null;
    return widget.product.images
        .firstWhere(
          (e) => e.primary,
          orElse: () => widget.product.images.first,
        )
        .image;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE + LIKE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: theme.colorScheme.surfaceVariant,
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: const Icon(Icons.image),
                          ),
                  ),
                ),

                /// OUT OF STOCK OVERLAY (optional)
                if (widget.product.isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Out of Stock",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                /// LIKE BUTTON
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFav = !isFav;
                      });
                      // TODO: sync with backend / cache later
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFav
                            ? theme.colorScheme.primary
                            : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// NAME
            Text(
              widget.product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),

            /// SELLER
            Text(
              widget.product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 4),

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
      ),
    );
  }
}
