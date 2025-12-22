class ProductImage {
  final bool primary;
  final String image;
  final int order;

  ProductImage({
    required this.primary,
    required this.image,
    required this.order,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      primary: json['primary'] ?? false,
      image: json['image'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}
