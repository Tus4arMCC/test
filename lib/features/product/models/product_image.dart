class ProductImage {
  final String image;
  final bool primary;

  ProductImage({required this.image, required this.primary});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      image: json['image'],
      primary: json['primary'] ?? false,
    );
  }
}
