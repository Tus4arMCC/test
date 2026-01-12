import 'package:flutter/material.dart';
import '../../home/models/product_data_model.dart';

class ProductActionBar extends StatelessWidget {
  final ProductData product;

  const ProductActionBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: product.product.isOutOfStock ? null : () {},
              child: const Text("Add to Cart"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: product.product.isOutOfStock ? null : () {},
              child: const Text("Buy Now"),
            ),
          ),
        ],
      ),
    );
  }
}
