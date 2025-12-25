import 'package:flutter/material.dart';
import '../models/product_image_model.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<ProductImage> images;

  const ProductImageCarousel({super.key, required this.images});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              return Image.network(
                images[i].image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 60),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        /// DOTS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _index == i ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _index == i
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
