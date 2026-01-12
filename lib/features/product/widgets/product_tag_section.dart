import 'package:flutter/material.dart';
import '../../home/models/product_model.dart';
import '../../product/widgets/product_card.dart';
import '../screens/product_list_screen.dart';

class ProductTagSection extends StatelessWidget {
  final String title;
  final List<Product> products;

  const ProductTagSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TAG TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                title.trim(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductListScreen(title: title, products: products),
                    ),
                  );
                },
                child: const Text("See All"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// HORIZONTAL PRODUCT LIST
        SizedBox(
          height: 310, // ✅ fixes overflow
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
