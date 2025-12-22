import 'package:flutter/material.dart';
import '../../skeletion/product_card_skeleton.dart';
import '../widgets/product_card.dart';
import '../models/product_tag_model.dart';

class ProductTagSection extends StatelessWidget {
  final ProductTag? tag;
  final bool isLoading;

  const ProductTagSection({
    super.key,
    required this.isLoading,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: isLoading ? 5 : tag!.products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (isLoading) {
            return const ProductCardSkeleton();
          }
          return ProductCard(product: tag!.products[i]);
        },
      ),
    );
  }
}
