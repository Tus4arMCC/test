import 'dart:convert';

/// Model for a variation in cart/wishlist
class CartVariation {
  final String variationId;
  final int quantity;
  final String? mappingCode;

  CartVariation({
    required this.variationId,
    required this.quantity,
    this.mappingCode,
  });

  Map<String, dynamic> toJson() => {
    'variationId': variationId,
    'quantity': quantity,
    if (mappingCode != null) 'mappingCode': mappingCode,
  };

  factory CartVariation.fromJson(Map<String, dynamic> json) => CartVariation(
    variationId: json['variationId'] ?? '',
    quantity: json['quantity'] ?? 1,
    mappingCode: json['mappingCode'],
  );

  @override
  String toString() =>
      'CartVariation(id: $variationId, qty: $quantity, mappingCode: $mappingCode)';
}

/// Model for a product in the cart
class CartProduct {
  final String productId;
  final String variationId;
  final String name;
  final String image;
  final double price;
  final double? oldPrice;
  final int quantity;
  final String? description;
  final bool inStock;
  final bool isFavourite;
  final String? variant; // e.g., "Blue • Size M"

  CartProduct({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.quantity,
    this.description,
    required this.inStock,
    this.isFavourite = false,
    this.variant,
  });

  double get total => price * quantity;
  double get originalTotal => (oldPrice ?? price) * quantity;
  double get discount => originalTotal - total;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variationId': variationId,
    'name': name,
    'image': image,
    'price': price,
    'oldPrice': oldPrice,
    'quantity': quantity,
    'description': description,
    'inStock': inStock,
    'isFavourite': isFavourite,
    'variant': variant,
  };

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
    productId: json['productCode'] ?? json['productId'] ?? '',
    variationId: json['variationCode'] ?? json['variationId'] ?? '',
    name: json['product'] ?? json['name'] ?? 'Unknown',
    image: json['image'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    oldPrice: json['mrp'] != null
        ? (json['mrp']).toDouble()
        : (json['oldPrice'] != null ? (json['oldPrice']).toDouble() : null),
    quantity: json['quantity'] ?? 1,
    description: json['description'],
    inStock: json['isStockOut'] != null
        ? !(json['isStockOut'] as bool)
        : (json['inStock'] ?? true),
    isFavourite: json['isFavourite'] ?? false,
    variant: json['variant'],
  );

  CartProduct copyWith({
    String? productId,
    String? variationId,
    String? name,
    String? image,
    double? price,
    double? oldPrice,
    int? quantity,
    String? description,
    bool? inStock,
    bool? isFavourite,
    String? variant,
  }) {
    return CartProduct(
      productId: productId ?? this.productId,
      variationId: variationId ?? this.variationId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      inStock: inStock ?? this.inStock,
      isFavourite: isFavourite ?? this.isFavourite,
      variant: variant ?? this.variant,
    );
  }

  @override
  String toString() =>
      'CartProduct(id: $productId, qty: $quantity, price: $price)';
}

/// Model for the entire cart
class Cart {
  final List<CartProduct> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double shipping;
  final double total;

  Cart({
    required this.items,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.shipping = 0,
    this.total = 0,
  });

  Cart copyWith({
    List<CartProduct>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? shipping,
    double? total,
  }) {
    return Cart(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.empty() => Cart(items: []);

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'tax': tax,
    'discount': discount,
    'shipping': shipping,
    'total': total,
  };

  factory Cart.fromJson(Map<String, dynamic> json) {
    // Parse items from 'data' (new format) or 'items' (old/fallback format)
    final list = (json['data'] as List?) ?? (json['items'] as List?) ?? [];

    final items = list
        .map((item) => CartProduct.fromJson(item as Map<String, dynamic>))
        .toList();

    // If totals are provided in JSON, use them. Otherwise, calculate them.
    double subtotal = (json['subtotal'] ?? 0).toDouble();
    double total = (json['total'] ?? 0).toDouble();
    double tax = (json['tax'] ?? 0).toDouble();
    double discount = (json['discount'] ?? 0).toDouble();
    double shipping = (json['shipping'] ?? 0).toDouble();

    // Recalculate if missing (common in list-only responses)
    if (total == 0 && items.isNotEmpty) {
      subtotal = items.fold(0, (sum, item) => sum + item.total);
      // Assuming simple total = subtotal for now if not provided
      total = subtotal + tax + shipping - discount;
    }

    return Cart(
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      shipping: shipping,
      total: total,
    );
  }

  @override
  String toString() => 'Cart(items: ${items.length}, total: $total)';
}

/// Model for wishlist item
class WishlistItem {
  final String productId;
  final String variationId;
  final String name;
  final String image;
  final double price;
  final double? oldPrice;
  final bool inStock;
  final String? variant;
  final DateTime addedAt;

  WishlistItem({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.inStock,
    this.variant,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variationId': variationId,
    'name': name,
    'image': image,
    'price': price,
    'oldPrice': oldPrice,
    'inStock': inStock,
    'variant': variant,
    'addedAt': addedAt.toIso8601String(),
  };

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      productId: json['productCode'] ?? json['productId'] ?? '',
      variationId: json['variationCode'] ?? json['variationId'] ?? '',
      name: json['product'] ?? json['name'] ?? 'Unknown',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['mrp'] != null
          ? (json['mrp']).toDouble()
          : (json['oldPrice'] != null ? (json['oldPrice']).toDouble() : null),
      inStock: json['isStockOut'] != null
          ? !(json['isStockOut'] as bool)
          : (json['inStock'] ?? true),
      variant: json['variant'],
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'WishlistItem(id: $productId, name: $name)';
}

/// Model for the entire wishlist
class Wishlist {
  final List<WishlistItem> items;

  Wishlist({required this.items});

  int get itemCount => items.length;

  bool contains(String productId) =>
      items.any((item) => item.productId == productId);

  factory Wishlist.empty() => Wishlist(items: []);

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? (json['items'] as List?) ?? [];
    return Wishlist(
      items: list
          .map((item) => WishlistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => 'Wishlist(items: ${items.length})';
}
