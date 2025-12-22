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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.product.givesPrimaryImage();

    return GestureDetector(
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
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const ColoredBox(
                            color: Colors.grey,
                            child: Icon(Icons.image),
                          ),
                  ),
                ),

                /// LIKE BUTTON
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isFav = !isFav;
                        widget.product.isFavourite = isFav;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
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
