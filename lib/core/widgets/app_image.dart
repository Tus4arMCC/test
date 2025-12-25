import 'package:flutter/material.dart';
import 'skeleton.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValidUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: isValidUrl
          ? Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return ScheduledSkeleton(width: width, height: height, borderRadius: 0);
              },
              errorBuilder: (_, __, ___) => _buildPlaceholder(context),
            )
          : _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(
        Icons.image,
        color: Colors.grey[400],
        size: (width ?? 100) * 0.3,
      ),
    );
  }
}
