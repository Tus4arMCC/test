import 'package:flutter/material.dart';
import '../../home/models/product_detail_model.dart';

class ProductPriceSection extends StatelessWidget {
  final ProductDetail product;

  const ProductPriceSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: theme.textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          Text(
            "Sold by ${product.seller}",
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                "₹${product.price}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "₹${product.mrp}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          if (product.isOutOfStock)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Out of stock",
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }
}
