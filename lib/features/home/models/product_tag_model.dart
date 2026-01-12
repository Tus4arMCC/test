import 'package:hive/hive.dart';
import 'product_model.dart';

part 'product_tag_model.g.dart';

@HiveType(typeId: 2) // ⚠️ MUST be unique
class ProductTag {
  @HiveField(0)
  final String tag;

  @HiveField(1)
  final List<Product> products;

  @HiveField(2)
  final int order;

  ProductTag({
    required this.tag,
    required this.products,
    required this.order,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      tag: (json['tag'] ?? '').toString().trim(),
      order: json['order'] ?? 0,
      products: (json['products'] as List? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}
