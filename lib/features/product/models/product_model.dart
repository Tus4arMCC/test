import 'package:hive/hive.dart';
import 'product_image_model.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double mrp;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final bool isFavourite;

  @HiveField(5)
  final bool isInCart;

  @HiveField(6)
  final String seller;

  @HiveField(7)
  final bool isOutOfStock;

  @HiveField(8)
  final List<ProductImage> images;

  Product({
    required this.code,
    required this.name,
    required this.mrp,
    required this.price,
    required this.isFavourite,
    required this.isInCart,
    required this.seller,
    required this.isOutOfStock,
    required this.images,
  });

  /// ✅ Primary image helper
  String? get primaryImage {
    if (images.isEmpty) return null;
    final primary = images.where((e) => e.primary).toList();
    return (primary.isNotEmpty ? primary.first : images.first).image;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List? ?? [];

    return Product(
      code: json['code'] ?? '',
      name: json['product'] ?? '',
      mrp: (json['mrp'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      isFavourite: json['isFavourite'] ?? false,
      isInCart: json['isInCart'] ?? false,
      seller: json['seller'] ?? '',
      isOutOfStock: json['isOutOfStock'] ?? false,
      images: imagesJson
          .map((e) => ProductImage.fromJson(e))
          .toList(),
    );
  }
}
