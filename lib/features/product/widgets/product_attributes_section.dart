import 'package:flutter/material.dart';
import '../../home/models/product_attribute_model.dart';

class ProductAttributesSection extends StatelessWidget {
  final List<ProductAttribute> attributes;  

  const ProductAttributesSection({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Details",
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          ...attributes.map(
            (attr) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      attr.name,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      attr.value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
