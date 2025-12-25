import 'package:hive/hive.dart';

part 'product_image_model.g.dart';

@HiveType(typeId: 3)
class ProductImage {
  @HiveField(0)
  final String image;

  @HiveField(1)
  final bool primary;

  ProductImage({
    required this.image,
    required this.primary,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      image: json['image'] ?? '',
      primary: json['primary'] ?? false,
    );
  }
}
