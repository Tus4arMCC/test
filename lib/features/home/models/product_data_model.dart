import 'variation_model.dart';
import 'attribute_model.dart';

class ProductData {
  final Variation product;
  final List<Attribute> attributes;
  final List<Variation> variations;

  ProductData({
    required this.product,
    required this.attributes,
    required this.variations,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      product: Variation.fromJson(json['product'] ?? {}),
      attributes: (json['attributes'] as List? ?? [])
          .map((e) => Attribute.fromJson(e))
          .toList(),
      variations: (json['variations'] as List? ?? [])
          .map((e) => Variation.fromJson(e))
          .toList(),
    );
  }
}
