import 'product_model.dart';

class ProductTag {
  final String tag;
  final int order;
  final List<Product> products;

  ProductTag({
    required this.tag,
    required this.order,
    required this.products,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      tag: json['tag'].toString().trim(),
      order: json['order'] ?? 0,
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}
