import 'product_image_model.dart';
import 'product_attribute_model.dart';

class ProductDetail {
  final String code;
  final String name;
  final double mrp;
  final double price;
  final int rating;
  final int avail;
  final String seller;
  final bool isOutOfStock;
  final bool isFavourite;
  final bool isInCart;
  final List<ProductImage> images;
  final List<ProductAttribute> attributes;

  ProductDetail({
    required this.code,
    required this.name,
    required this.mrp,
    required this.price,
    required this.rating,
    required this.avail,
    required this.seller,
    required this.isOutOfStock,
    required this.isFavourite,
    required this.isInCart,
    required this.images,
    required this.attributes,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      code: json['code'] ?? '',
      name: json['product'] ?? '',
      mrp: (json['mrp'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      rating: json['rating'] ?? 0,
      avail: json['avail'] ?? 0,
      seller: json['seller'] ?? '',
      isOutOfStock: json['isOutOfStock'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
      isInCart: json['isInCart'] ?? false,
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),   
      attributes: (json['attributes'] as List? ?? [])
    .map((e) => ProductAttribute.fromJson(e))
    .toList(),
    );
  }
}
