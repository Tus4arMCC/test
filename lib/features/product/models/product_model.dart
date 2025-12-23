import 'package:hive/hive.dart';

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

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List? ?? [];
    final productImages = imagesList
        .map((img) => ProductImage(
              image: img['image'] ?? '',
              primary: img['primary'] ?? false,
            ))
        .toList();

    return Product(
      code: json['code'] ?? '',
      name: json['product'] ?? json['name'] ?? '',
      mrp: (json['mrp'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      isFavourite: json['isFavourite'] ?? false,
      isInCart: json['isInCart'] ?? false,
      seller: json['seller'] ?? '',
      isOutOfStock: json['isOutOfStock'] ?? false,
      images: productImages,
    );
  }
}

@HiveType(typeId: 2)
class ProductImage {
  @HiveField(0)
  final String image;

  @HiveField(1)
  final bool primary;

  ProductImage({
    required this.image,
    required this.primary,
  });
}
