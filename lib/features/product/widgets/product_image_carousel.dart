import 'package:flutter/material.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/app_image.dart';
import '../../home/models/product_image_model.dart';

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

    if (images.isEmpty) {
      return Container(
        height: 320,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final imageUrl = resolveImageUrl(images[i].image);
              return AppImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                borderRadius: 0,
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        /// DOTS
        if (images.length > 1)
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
