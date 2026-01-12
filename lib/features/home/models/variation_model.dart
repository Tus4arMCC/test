import 'product_image_model.dart';

class VariationAttribute {
  final String value;
  final String productAttributeCode;
  final String attributeCode;
  final String variationCode;
  final String variationName;
  final String attributeName;
  final List<dynamic> images; // keeping generic as React says any[]

  VariationAttribute({
    required this.value,
    required this.productAttributeCode,
    required this.attributeCode,
    required this.variationCode,
    required this.variationName,
    required this.attributeName,
    required this.images,
  });

  factory VariationAttribute.fromJson(Map<String, dynamic> json) {
    return VariationAttribute(
      value: json['value'] ?? '',
      productAttributeCode: json['productAttributeCode'] ?? '',
      attributeCode: json['attributeCode'] ?? '',
      variationCode: json['variationCode'] ?? '',
      variationName:
          json['variatioName'] ??
          '', // Note typo in React interface 'variatioName'
      attributeName: json['attributeName'] ?? '',
      images: json['images'] as List? ?? [],
    );
  }
}

class SellerPrice {
  final String productCode;
  final String variationCode;
  final bool isPrimary;
  final double mrp;
  final double price;
  final String seller;
  final double? rating;
  final String? sku;
  final String? mappingCode;

  SellerPrice({
    required this.productCode,
    required this.variationCode,
    required this.isPrimary,
    required this.mrp,
    required this.price,
    required this.seller,
    this.rating,
    this.sku,
    this.mappingCode,
  });

  factory SellerPrice.fromJson(Map<String, dynamic> json) {
    return SellerPrice(
      productCode: json['productCode'] ?? '',
      variationCode: json['variationCode'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      seller: json['seller'] ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      sku: json['sku'],
      mappingCode: json['mappingCode'],
    );
  }
}

class Variation {
  final String variationCode;
  final String product;
  final String variationName;
  final double? mrp;
  final double? price;
  final double rating;
  final int avail;
  final String seller;
  final bool isOutOfStock;
  final List<VariationAttribute> variationAttributes;
  final List<ProductImage> images;
  final bool isFavourite;
  final bool isInCart;
  final bool isDefault;
  final SellerPrice? sellerPrice;
  final List<SellerPrice> sellers;

  Variation({
    required this.variationCode,
    required this.product,
    required this.variationName,
    this.mrp,
    this.price,
    required this.rating,
    required this.avail,
    required this.seller,
    required this.isOutOfStock,
    required this.variationAttributes,
    required this.images,
    required this.isFavourite,
    required this.isInCart,
    required this.isDefault,
    this.sellerPrice,
    required this.sellers,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    final sellerPriceJson = json['sellerPrice'] as Map<String, dynamic>?;
    final sellerPrice = sellerPriceJson != null
        ? SellerPrice.fromJson(sellerPriceJson)
        : null;

    // Use sellerPrice values if top-level values are missing or zero
    // Assuming price 0 means "use seller price"
    final rawMrp = (json['mrp'] as num?)?.toDouble();
    final rawPrice = (json['price'] as num?)?.toDouble();

    final effectiveMrp = (rawMrp != null && rawMrp > 0)
        ? rawMrp
        : (sellerPrice?.mrp ?? 0);

    final effectivePrice = (rawPrice != null && rawPrice > 0)
        ? rawPrice
        : (sellerPrice?.price ?? 0);

    final effectiveSeller = (json['seller'] as String? ?? '').isNotEmpty
        ? (json['seller'] as String)
        : (sellerPrice?.seller ?? '');

    return Variation(
      variationCode: json['variationCode'] ?? '',
      product: json['product'] ?? '',
      variationName: json['variationName'] ?? '',
      mrp: effectiveMrp,
      price: effectivePrice,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      avail: json['avail'] ?? 0,
      seller: effectiveSeller,
      isOutOfStock: json['isOutOfStock'] ?? false,
      variationAttributes: (json['variationAttributes'] as List? ?? [])
          .map((e) => VariationAttribute.fromJson(e))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
      isFavourite: json['isFavourite'] ?? false,
      isInCart: json['isInCart'] ?? false,
      isDefault: json['isDefault'] ?? false,
      sellerPrice: sellerPrice,
      sellers: (json['sellers'] as List? ?? [])
          .map((e) => SellerPrice.fromJson(e))
          .toList(),
    );
  }
}
