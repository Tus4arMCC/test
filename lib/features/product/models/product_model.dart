import 'product_image.dart';

class Product {
  final String code;
  final String name;
  final double mrp;
  final double price;
  final int rating;
  final String seller;
  final bool isOutOfStock;
  bool isFavourite;
  final bool isInCart;
  final List<ProductImage> images;

  givesPrimaryImage() {
    if (images.isEmpty) return null;
    return images.firstWhere(
      (img) => img.primary,
      orElse: () => images.first,
    ).image;
  }

  Product({
    required this.code,
    required this.name,
    required this.mrp,
    required this.price,
    required this.rating,
    required this.seller,
    required this.isOutOfStock,
    required this.isFavourite,
    required this.isInCart,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code'],
      name: json['product'],
      mrp: (json['mrp'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      rating: json['rating'] ?? 0,
      seller: json['seller'] ?? '',
      isOutOfStock: json['isOutOfStock'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
      isInCart: json['isInCart'] ?? false,
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
    );
  }
}
