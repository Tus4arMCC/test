import 'package:flutter/material.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/app_image.dart';
import '../../home/models/variation_model.dart'; // Import for SellerPrice

class SellerCard extends StatelessWidget {
  final SellerPrice seller;
  final String variationName;
  final bool isSelected;
  final Function(SellerPrice) onSelect;
  final String? productImage;

  const SellerCard({
    super.key,
    required this.seller,
    required this.variationName,
    required this.isSelected,
    required this.onSelect,
    this.productImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onSelect(seller),
      child: Container(
        width: 250, // Fixed width for horizontal scrolling
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8F8) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFDC3545) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFDC3545).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image (Small)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AppImage(
                      imageUrl: resolveImageUrl(productImage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Seller Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.seller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  (seller.rating ?? 4.5).toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection Circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFDC3545)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFFDC3545)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Price Section
            Row(
              children: [
                Text(
                  "₹${seller.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC3545),
                  ),
                ),
                const SizedBox(width: 8),
                if (seller.mrp > seller.price) ...[
                  Text(
                    "₹${seller.mrp.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${((1 - (seller.price / seller.mrp)) * 100).round()}% OFF",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Benefits / Delivery
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  "Free Delivery",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
