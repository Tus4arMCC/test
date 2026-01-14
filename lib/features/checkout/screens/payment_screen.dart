import 'package:flutter/material.dart';
import '../../home/models/cart_wishlist_models.dart';
import '../../home/services/cart_api_service.dart';
import '../../../core/utils/cookie_utils.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<CartProduct> items;
  final String? addressCode;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.items,
    this.addressCode,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'cod';
  bool _isLoading = false;

  // Form controllers
  @override
  void dispose() {
    super.dispose();
  }

  void _placeOrder() async {
    // Only two payment methods are supported in this screen: 'cod' and 'online'.
    setState(() => _isLoading = true);

    try {
      // Resolve UID (user/guest/random)
      final uid = await CookieUtils.resolveUid();

      // Build variations payload from cart items
      final variations = widget.items
          .map(
            (p) => CartVariation(
              variationId: p.variationId,
              quantity: p.quantity,
              mappingCode: p.mappingCode,
            ),
          )
          .toList();

      // Map selected payment method to allowed modes: 'cod' or 'online'
      final mode = (_selectedMethod == 'cod') ? 'cod' : 'online';

      // Use passed addressCode if available
      final addressCode = widget.addressCode ?? '';

      // Call proceedOrder -> returns full response data (token, orderNo)
      final resp = await CartApiService.proceedOrder(
        uid: uid,
        variations: variations,
        mode: mode,
        addressCode: addressCode,
      );

      if (resp == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to place order. Try again.")),
        );
        return;
      }

      final token = resp['token'] as String?;
      final orderNo = resp['orderNo'] as String?;

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order token missing. Try again.")),
        );
        return;
      }

      // Call success endpoint with token, trnxNo (use orderNo if available)
      final finalized = await CartApiService.finalizeOrder(
        token: token,
        uid: uid,
        trnxNo: orderNo ?? 'string',
      );

      if (!mounted) return;
      if (finalized) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text("Order Placed Successfully!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Order No: $orderNo"),
                const SizedBox(height: 16),
                const Text("Thank you for shopping with us!"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text("Continue Shopping"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to finalize order.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Methods
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Choose a payment method",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentOption(
                          value: 'cod',
                          icon: Icons.money,
                          title: 'Cash on Delivery (COD)',
                          subtitle:
                              'Pay with cash when your order is delivered.',
                        ),
                        _buildPaymentOption(
                          value: 'online',
                          icon: Icons.payment,
                          title: 'Online Payment',
                          subtitle:
                              'Pay online (cards, UPI, netbanking, wallets).',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Summary Block
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Items (${widget.items.length})"),
                            // Calculate simple total based on inputs or just pass widget.totalAmount
                            // Ideally we pass full breakdown but for now just total
                            const Text("-"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Shipping"),
                            Text("Free", style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "₹${widget.totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const StadiumBorder(),
          ),
          child: Text(
            _isLoading
                ? "Processing..."
                : "Place Order • ₹${widget.totalAmount.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == value;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedMethod,
                onChanged: (val) => setState(() => _selectedMethod = val!),
                activeColor: colorScheme.primary,
              ),
              Icon(icon, color: Colors.grey[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
