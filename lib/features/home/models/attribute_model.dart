class AttributeDetail {
  final String name;
  final int count;

  AttributeDetail({required this.name, required this.count});

  factory AttributeDetail.fromJson(Map<String, dynamic> json) {
    return AttributeDetail(name: json['name'] ?? '', count: json['count'] ?? 0);
  }
}

class Attribute {
  final String name;
  final int count;
  final String attributeCode;
  final List<AttributeDetail> details;

  Attribute({
    required this.name,
    required this.count,
    required this.attributeCode,
    required this.details,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      attributeCode: json['attributeCode'] ?? '',
      details: (json['details'] as List? ?? [])
          .map((e) => AttributeDetail.fromJson(e))
          .toList(),
    );
  }
}
