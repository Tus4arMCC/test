class ProductAttribute {
  final String name;
  final String value;

  ProductAttribute({
    required this.name,
    required this.value,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      name: json['attributeName']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}
