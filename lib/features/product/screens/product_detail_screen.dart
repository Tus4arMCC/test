import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/wishlist_button.dart';
import '../../home/models/product_data_model.dart';
import '../../home/models/variation_model.dart';
import '../repository/product_repository.dart';
import '../../home/services/product_detail_api_service.dart';

import '../../home/services/cart_logic_service.dart';
import '../../../core/state/count_state_manager.dart';
import '../../screens/cart_screen.dart';
import '../../screens/wishlist_screen.dart';
import '../widgets/seller_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productCode;

  const ProductDetailScreen({super.key, required this.productCode});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // State
  bool _isLoading = true;
  String? _error;
  ProductData? _productData;
  Variation? _selectedVariation;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  String _activeTab = "about";
  final Map<String, String> _selectedAttributes = {};
  bool _localLiked = false;
  bool _localIsInCart = false;
  bool _isCartActionRunning = false;
  late CartLogicService _cartLogic;
  late CountStateManager _countManager;
  late String _currentProductCode;

  // Seller Selection
  SellerPrice? _selectedSeller;

  // Constants
  static const int MAX_ORDER_QTY =
      10; // Could probably pull from .env if needed

  @override
  void initState() {
    super.initState();
    _currentProductCode = widget.productCode;
    _cartLogic = CartLogicService();
    _countManager = CountStateManager();

    // Listen to count changes to update badge
    _countManager.addListener(_onCountChanged);

    // Initialize count manager to get cart/wishlist counts for badges
    _countManager.initialize();
    _loadProduct();
  }

  void _onCountChanged() {
    if (mounted) {
      setState(() {}); // Rebuild to update badges
    }
  }

  @override
  void dispose() {
    _countManager.removeListener(_onCountChanged);
    _cartLogic.dispose();
    super.dispose();
  }

  Future<void> _loadProduct([String? code]) async {
    final targetCode = code ?? _currentProductCode;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Always fetch fresh data from API (no caching) to get latest price, stock, etc.
      final data = await ProductApiService.fetchProduct(targetCode);
      _currentProductCode = targetCode;
      _productData = data;
      _selectedVariation = data.product;
      _localLiked = data.product.isFavourite;
      _localIsInCart = data.product.isInCart;

      // Initialize selected attributes based on current variation
      _selectedAttributes.clear();
      for (var attr in data.product.variationAttributes) {
        _selectedAttributes[attr.attributeName] = attr.value;
      }

      // Initialize Selected Seller (Lowest Price)
      if (data.product.sellers.isNotEmpty) {
        final sortedSellers = List<SellerPrice>.from(data.product.sellers);
        sortedSellers.sort((a, b) => a.price.compareTo(b.price));
        _selectedSeller = sortedSellers.first;
      } else {
        _selectedSeller = data.product.sellerPrice;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleQuantityChange(String type) {
    if (type == "increment") {
      if (_quantity >= MAX_ORDER_QTY) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Maximum order quantity is $MAX_ORDER_QTY")),
        );
        return;
      }
      setState(() => _quantity++);
    } else if (type == "decrement") {
      if (_quantity > 1) {
        setState(() => _quantity--);
      }
    }
  }

  bool _isAttributeDisabled(String attrName, String attrValue) {
    if (_productData == null) return false;

    // RULE 1: First attribute of the list is ALWAYS enabled
    if (_productData!.attributes.isNotEmpty &&
        _productData!.attributes.first.name == attrName) {
      return false;
    }

    // RULE 2: If nothing selected, enable all (conceptually only happens for first attr)
    if (_selectedAttributes.isEmpty) return false;

    // RULE 3: Filter based on selected attributes
    // Check if ANY variation exists that matches this specific attribute value AND all other current selections
    return !_productData!.variations.any((v) {
      // 1. Check if this variation has the target attribute value
      final hasTargetAttr = v.variationAttributes.any(
        (va) => va.attributeName == attrName && va.value == attrValue,
      );
      if (!hasTargetAttr) return false;

      // 2. Check if this variation matches all other currently selected attributes
      return _selectedAttributes.entries.every((entry) {
        if (entry.key == attrName)
          return true; // Ignore the attribute group we are validating
        return v.variationAttributes.any(
          (va) => va.attributeName == entry.key && va.value == entry.value,
        );
      });
    });
  }

  void _handleAttributeSelect(String name, String value) {
    if (_productData == null || _isAttributeDisabled(name, value)) return;

    final newSelectedAttributes = Map<String, String>.from(_selectedAttributes);
    newSelectedAttributes[name] = value;

    // UI Update immediately
    setState(() {
      _selectedAttributes[name] = value;
    });

    // Strategy 1: Find Exact Match
    Variation? matchingVariation = _productData!.variations
        .cast<Variation?>()
        .firstWhere(
          (v) => v!.variationAttributes.every(
            (attr) => newSelectedAttributes[attr.attributeName] == attr.value,
          ),
          orElse: () => null,
        );

    // Strategy 2: Partial Match (if exact not found, find first valid one for this new selection)
    if (matchingVariation == null) {
      matchingVariation = _productData!.variations
          .cast<Variation?>()
          .firstWhere(
            (v) => v!.variationAttributes.any(
              (attr) => attr.attributeName == name && attr.value == value,
            ),
            orElse: () => null,
          );
    }

    if (matchingVariation != null) {
      _loadProduct(matchingVariation.variationCode);
    }
  }

  void _handleSellerSelect(SellerPrice seller) {
    setState(() {
      _selectedSeller = seller;
    });
    // Optional: Show toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Seller changed to ${seller.seller}")),
    );
  }

  String _getSortedVariationString(Variation v) {
    if (_productData == null) return "";

    // Create a map for fast lookup of attribute order
    final attributeOrder = {
      for (var i = 0; i < _productData!.attributes.length; i++)
        _productData!.attributes[i].name: i,
    };

    // Sort variation attributes based on the master list
    final sortedAttrs = List.of(v.variationAttributes);
    sortedAttrs.sort((a, b) {
      final orderA = attributeOrder[a.attributeName] ?? 999;
      final orderB = attributeOrder[b.attributeName] ?? 999;
      return orderA.compareTo(orderB);
    });

    return sortedAttrs.map((a) => a.value).join(", ");
  }

  Future<void> _addToCart() async {
    if (_selectedVariation == null) return;

    setState(() {
      _isCartActionRunning = true;
    });

    try {
      final message = await _cartLogic.addToCart(
        variationId: _selectedVariation!.variationCode,
        quantity: _quantity,
        mappingCode:
            _selectedSeller?.mappingCode ??
            _selectedVariation!.sellerPrice?.mappingCode,
      );

      if (mounted) {
        setState(() {
          _localIsInCart = true;
          // Remove from wishlist when adding to cart (mutually exclusive)
          _localLiked = false;
          _isCartActionRunning = false;
        });

        // Refresh global count
        await CountStateManager().refresh();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCartActionRunning = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _removeFromCart() async {
    if (_selectedVariation == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Cart?'),
        content: const Text('Do you want to remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCartActionRunning = true;
    });

    try {
      final message = await _cartLogic.removeFromCart(
        _selectedVariation!.variationCode,
      );

      if (mounted) {
        // Reload product to refresh cart/wishlist status from API
        // This prevents empty screen and ensures fresh state
        await _loadProduct();

        setState(() {
          _isCartActionRunning = false;
        });

        // Refresh global count
        await CountStateManager().refresh();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCartActionRunning = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  /// Build badge icon with count
  Widget _buildBadgeIcon({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.black),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFDC3545),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showShareModal() {
    if (_selectedVariation == null) return;

    final productUrl =
        "https://pksoft.com/product/${_selectedVariation!.variationCode}";
    final text =
        "Check out ${_selectedVariation!.product} on PkSoft!\n$productUrl";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Share Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // QR Code
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: productUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Scan to view on web",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Share.share(text);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.share),
                label: const Text("Share via..."),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _productData == null || _selectedVariation == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? "Product not found")),
      );
    }

    final product = _selectedVariation!;
    final otherVariations = _productData!.variations
        .where((v) => v.variationCode != product.variationCode)
        .toList();
    final images = product.images;
    final primaryImage = images.isNotEmpty
        ? (images.length > _selectedImageIndex
              ? images[_selectedImageIndex].image
              : images[0].image)
        : "";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.black),
            onPressed: _showShareModal,
          ),
          _buildBadgeIcon(
            icon: Icons.favorite_outline,
            count: _countManager.wishlistCount,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
          _buildBadgeIcon(
            icon: Icons.shopping_cart_outlined,
            count: _countManager.cartCount,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. IMAGE GALLERY
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Main Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: AppImage(
                      imageUrl: resolveImageUrl(primaryImage),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thumbnails
                  if (images.length > 1)
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedImageIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImageIndex = index),
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AppImage(
                                  imageUrl: resolveImageUrl(
                                    images[index].image,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            /// 2. TITLE & RATING
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand / Seller
                  Text(
                    (_selectedSeller?.seller ?? product.seller).toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Name
                  Text(
                    product.variationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating & Wishlist
                  Row(
                    children: [
                      if (product.rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.rating < 2.6
                                ? Colors.red
                                : product.rating < 3.6
                                ? Colors.amber
                                : Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Text(
                        "0 Reviews",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const Spacer(),

                      // Wishlist Button (disabled if in cart)
                      Opacity(
                        opacity: _localIsInCart ? 0.5 : 1.0,
                        child: IgnorePointer(
                          ignoring: _localIsInCart,
                          child: WishlistButton(
                            variationId: product.variationCode,
                            isInWishlist: _localLiked,
                            iconSize: 24,
                            showBackground: true,
                            backgroundColor: Colors.grey[100],
                            onWishlistChanged: (isInWishlist) {
                              setState(() {
                                _localLiked = isInWishlist;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 2.5 SELLERS SECTION
            if (product.sellers.length > 1)
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Available from Other Sellers",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160, // Height for SellerCard
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: product.sellers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          // Sort so selected is first? Or just list them?
                          // React code: getSortedSellers() puts selected first.
                          // Let's replicate that sorting.
                          List<SellerPrice> sortedSellers = List.from(
                            product.sellers,
                          );
                          sortedSellers.sort(
                            (a, b) => a.price.compareTo(b.price),
                          );

                          if (_selectedSeller != null) {
                            final selectedIndex = sortedSellers.indexWhere(
                              (s) =>
                                  s.mappingCode == _selectedSeller!.mappingCode,
                            );
                            if (selectedIndex > 0) {
                              final selected = sortedSellers.removeAt(
                                selectedIndex,
                              );
                              sortedSellers.insert(0, selected);
                            }
                          }

                          final seller = sortedSellers[index];
                          return SellerCard(
                            seller: seller,
                            variationName: product.variationName,
                            isSelected:
                                _selectedSeller?.mappingCode ==
                                seller.mappingCode,
                            onSelect: _handleSellerSelect,
                            productImage: primaryImage,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            /// 3. VARIATIONS INLINE LIST
            if (otherVariations.isNotEmpty)
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Available Variations",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100, // Card height
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: otherVariations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final v = otherVariations[index];
                          final img = v.images.isNotEmpty
                              ? v.images.first.image
                              : null;

                          return GestureDetector(
                            onTap: () {
                              _loadProduct(v.variationCode);
                            },
                            child: Container(
                              width: 250,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: AppImage(
                                      imageUrl: resolveImageUrl(img),
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          v.product,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getSortedVariationString(v),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹${(v.price ?? 0).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            /// 4. PRICE & ATTRIBUTES
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${(_selectedSeller?.price ?? product.price ?? 0).toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC3545), // Replaced generic red
                        ),
                      ),
                      const SizedBox(width: 12),
                      if ((_selectedSeller?.mrp ?? product.mrp ?? 0) >
                          (_selectedSeller?.price ?? product.price ?? 0)) ...[
                        Text(
                          "₹${(_selectedSeller?.mrp ?? product.mrp ?? 0).toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${((1 - ((_selectedSeller?.price ?? product.price ?? 0) / (_selectedSeller?.mrp ?? product.mrp ?? 1))) * 100).round()}% OFF",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Text(
                    "(Inclusive of all taxes)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const Divider(height: 32),

                  // Attributes Grid
                  ..._productData!.attributes.map((attr) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${attr.name}:",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: attr.details.map((detail) {
                            final isSelected =
                                _selectedAttributes[attr.name] == detail.name;
                            final isDisabled = _isAttributeDisabled(
                              attr.name,
                              detail.name,
                            );

                            return GestureDetector(
                              onTap: isDisabled
                                  ? null
                                  : () => _handleAttributeSelect(
                                      attr.name,
                                      detail.name,
                                    ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : (isDisabled
                                            ? Colors.grey[100]
                                            : Colors.white),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  detail.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDisabled
                                              ? Colors.grey[400]
                                              : Colors.black),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  /// Quantity
                  Row(
                    children: [
                      const Text(
                        "Quantity:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () =>
                                  _handleQuantityChange("decrement"),
                            ),
                            Text(
                              "$_quantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () =>
                                  _handleQuantityChange("increment"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 5. DELIVERY INFO
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Check Delivery & COD Options at your Area",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),

            /// 6. FEATURES ICONS (Grid)
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeature(
                    Icons.local_shipping_outlined,
                    "Free Shipping",
                    "On orders > ₹1500",
                  ),
                  _buildFeature(
                    Icons.verified_user_outlined,
                    "Safe",
                    "Highest Standards",
                  ),
                  _buildFeature(
                    Icons.payment_outlined,
                    "Secure",
                    "Fast Checkout",
                  ),
                ],
              ),
            ),

            /// 7. TABS (About / Warranty / Info)
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildTabBtn("about", "About"),
                      _buildTabBtn("warranty", "Warranty"),
                      _buildTabBtn("info", "Info"),
                    ],
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),

            /// 8. REVIEWS
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 100,
              ), // padding for bottom bar
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ratings & Reviews",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Mock Reviews
                  _buildReviewItem(
                    "Romin",
                    5,
                    "Fast Delivery",
                    "Arrived securely packed.",
                  ),
                  _buildReviewItem(
                    "Sarah",
                    5,
                    "Excellent",
                    "Beautiful glass top.",
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text("View All Reviews"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                child: OutlinedButton(
                  onPressed: (product.isOutOfStock || _isCartActionRunning)
                      ? null
                      : () {
                          if (_localIsInCart) {
                            _removeFromCart();
                          } else {
                            _addToCart();
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: _localIsInCart
                          ? Colors.grey
                          : theme.colorScheme.primary,
                    ),
                    backgroundColor: _localIsInCart
                        ? Colors.grey[200]
                        : Colors.transparent,
                  ),
                  child: _isCartActionRunning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _localIsInCart ? "REMOVE FROM CART" : "ADD TO CART",
                          style: TextStyle(
                            color: _localIsInCart
                                ? Colors.black87
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Buy Now
              Expanded(
                child: ElevatedButton(
                  onPressed: (product.isOutOfStock || _isCartActionRunning)
                      ? null
                      : () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    product.isOutOfStock ? "OUT OF STOCK" : "BUY NOW",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String sub) {
    return Column(
      children: [
        Icon(icon, color: Colors.red, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _buildTabBtn(String key, String label) {
    final isActive = _activeTab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final v = _selectedVariation!;
    switch (_activeTab) {
      case "about":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${v.product} - ${v.variationAttributes.map((a) => a.value).join(", ")}",
            ),
            const SizedBox(height: 8),
            const Text(
              "Experience high performance and sleek design with this premium product.",
            ),
          ],
        );
      case "warranty":
        return const Text("Warranty information unavailable for this product.");
      case "info":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Brand: ${v.seller}"),
            Text("Availability: ${v.avail}"),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildReviewItem(
    String name,
    int rating,
    String title,
    String comment,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < rating ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            comment,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
