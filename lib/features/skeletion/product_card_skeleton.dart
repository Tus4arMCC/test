import 'package:flutter/material.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 12, width: 120, color: Colors.grey.shade300),
          const SizedBox(height: 6),
          Container(height: 10, width: 80, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Container(height: 12, width: 60, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
