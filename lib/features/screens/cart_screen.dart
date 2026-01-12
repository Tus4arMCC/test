import 'package:flutter/material.dart';
import '../../core/widgets/app_image.dart';
import '../home/models/cart_wishlist_models.dart';
import '../home/services/cart_logic_service.dart';
import '../address/screens/address_list_screen.dart';
import 'wishlist_screen.dart';

class CartScreen extends StatefulWidget {
  final bool showBackButton;
  const CartScreen({super.key, this.showBackButton = true});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartLogicService _cartLogic;
  final Set<String> _selectedVariationIds = {};

  @override
  void initState() {
    super.initState();
    _cartLogic = CartLogicService();
    _cartLogic.addListener(_updateState);
    _initializeCart();
  }

  void _updateState() {
    if (mounted) {
      if (_cartLogic.cart.items.isNotEmpty && _selectedVariationIds.isEmpty) {
        // Auto-select all on data load if nothing selected (initial load)
        // logic can be improved to exclude out-of-stock if desired, but Web selects all
        _selectAll();
      }
      setState(() {});
    }
  }

  void _initializeCart() {
    _cartLogic.initializeCart();
  }

  void _selectAll() {
    _selectedVariationIds.clear();
    for (var item in _cartLogic.cart.items) {
      _selectedVariationIds.add(item.variationId);
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectAll();
      } else {
        _selectedVariationIds.clear();
      }
    });
  }

  void _toggleItemSelection(String variationId, bool? value) {
    setState(() {
      if (value == true) {
        _selectedVariationIds.add(variationId);
      } else {
        _selectedVariationIds.remove(variationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withOpacity(0.9),
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: RichText(
          text: TextSpan(
            text: "My Bag ",
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: "(${_cartLogic.itemCount})",
                style: TextStyle(color: colorScheme.primary, fontSize: 14),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showCartOptions(context);
            },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: _cartLogic.isLoading
          ? _buildLoadingState(context)
          : _cartLogic.cart.items.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, colorScheme, textTheme),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Loading your cart...'),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text('Your cart is empty', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'Add items to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: const Text('Continue with Wishlist'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final selectedItems = _cartLogic.cart.items
        .where((item) => _selectedVariationIds.contains(item.variationId))
        .toList();

    return Column(
      children: [
        // Select All Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Checkbox(
                value:
                    _selectedVariationIds.length ==
                        _cartLogic.cart.items.length &&
                    _cartLogic.cart.items.isNotEmpty,
                onChanged: _toggleSelectAll,
                activeColor: colorScheme.primary,
              ),
              Text(
                "${_selectedVariationIds.length}/${_cartLogic.cart.items.length} ITEMS SELECTED",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ..._cartLogic.cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCartItem(
                      context,
                      item,
                      colorScheme,
                      textTheme,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPromoCodeInput(colorScheme),
                const SizedBox(height: 24),
                _buildOrderSummary(context, selectedItems, colorScheme),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _buildCheckoutBar(context, selectedItems, colorScheme, textTheme),
      ],
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProduct item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedVariationIds.contains(item.variationId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.inStock ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: isSelected,
            onChanged: (val) => _toggleItemSelection(item.variationId, val),
            activeColor: colorScheme.primary,
          ),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(imageUrl: item.image, fit: BoxFit.cover),
                  if (!item.inStock)
                    Container(
                      color: Colors.white.withOpacity(0.7),
                      alignment: Alignment.center,
                      child: const Text(
                        "OUT OF STOCK",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: item.inStock ? Colors.black : Colors.grey,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.grey,
                      iconSize: 20,
                      onPressed: () {
                        _cartLogic.removeFromCart(item.variationId);
                      },
                    ),
                  ],
                ),
                if (item.variant != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      item.variant!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.oldPrice != null)
                          Text(
                            '₹${item.oldPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (item.inStock)
                      _buildQuantitySelector(
                        colorScheme,
                        item.quantity,
                        onMinus: () {
                          _cartLogic.updateQuantity(
                            variationId: item.variationId,
                            newQuantity: item.quantity - 1,
                          );
                        },
                        onPlus: () {
                          _cartLogic.updateQuantity(
                            variationId: item.variationId,
                            newQuantity: item.quantity + 1,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(
    ColorScheme colorScheme,
    int quantity, {
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMinus,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 1, color: Colors.black12)],
              ),
              child: Icon(Icons.remove, size: 14, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            quantity.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 1, color: Colors.black12)],
              ),
              child: Icon(Icons.add, size: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeInput(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Have a promo code?",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Apply",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    List<CartProduct> selectedItems,
    ColorScheme colorScheme,
  ) {
    double totalMRP = 0;
    double totalDiscount = 0;
    const double platformFee = 20;

    for (var item in selectedItems) {
      final oldPrice = item.oldPrice ?? item.price;
      totalMRP += oldPrice * item.quantity;
      totalDiscount += (oldPrice - item.price) * item.quantity;
    }

    final totalAmount = totalMRP - totalDiscount + platformFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ORDER SUMMARY",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            "subtotal",
            "₹${totalMRP.toStringAsFixed(2)}", // Web uses Total MRP here
            colorScheme,
          ),
          const SizedBox(height: 12),
          if (totalDiscount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSummaryRow(
                "Discount",
                "-₹${totalDiscount.toStringAsFixed(2)}",
                colorScheme,
                valueColor: Colors.green,
              ),
            ),
          _buildSummaryRow(
            "Platform Fee",
            "₹${platformFee.toStringAsFixed(2)}",
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            "Shipping",
            "Free", // Simplified for now
            colorScheme,
            valueColor: Colors.green,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            "Total Amount",
            "₹${totalAmount.toStringAsFixed(2)}",
            colorScheme,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black : Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? Colors.black : Colors.black87),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 20 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    List<CartProduct> selectedItems,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Re-calculate total for the bar
    double totalMRP = 0;
    double totalDiscount = 0;
    const double platformFee = 20;

    for (var item in selectedItems) {
      final oldPrice = item.oldPrice ?? item.price;
      totalMRP += oldPrice * item.quantity;
      totalDiscount += (oldPrice - item.price) * item.quantity;
    }
    final totalAmount = selectedItems.isEmpty
        ? 0.0
        : (totalMRP - totalDiscount + platformFee);
    final hasOutOfStock = selectedItems.any((item) => !item.inStock);
    final canCheckout = selectedItems.isNotEmpty && !hasOutOfStock;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (selectedItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grand Total",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            )
          else
            const Text("Select items to proceed"),

          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: canCheckout
                  ? () {
                      // Navigate to Address Selection
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressListScreen(
                            isSelectionMode: true,
                            checkoutTotal: totalAmount,
                            checkoutItems: selectedItems,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
                elevation: canCheckout ? 4 : 0,
                shadowColor: colorScheme.primary.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasOutOfStock ? "Some items out of stock" : "Checkout",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!hasOutOfStock) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clear Cart'),
              onTap: () {
                Navigator.pop(context);
                _showClearConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _cartLogic.clearCart();
              Navigator.pop(context);
              setState(() {
                _selectedVariationIds.clear();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cartLogic.removeListener(_updateState);
    _cartLogic.dispose();
    super.dispose();
  }
}
