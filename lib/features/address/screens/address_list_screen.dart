import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton.dart';
import '../../checkout/screens/payment_screen.dart';
import '../../home/models/cart_wishlist_models.dart';
import '../models/address_model.dart';
import '../services/address_api_service.dart';

class AddressListScreen extends StatefulWidget {
  final bool isSelectionMode;
  final double? checkoutTotal;
  final List<CartProduct>? checkoutItems;

  const AddressListScreen({
    super.key,
    this.isSelectionMode = false,
    this.checkoutTotal,
    this.checkoutItems,
  });

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  int _selectedAddressIndex = 0;
  bool _loading = true;
  List<AddressModel> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      _addresses = await AddressApiService.fetchAddresses();
    } catch (e) {
      _addresses = [];
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "My Addresses",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              if (_loading) ...[
                _buildSkeletonAddressCard(context),
                const SizedBox(height: 16),
              ] else if (_addresses.isEmpty) ...[
                const SizedBox(height: 24),
                Center(child: Text('No addresses found')),
                const SizedBox(height: 24),
              ] else ...[
                for (var i = 0; i < _addresses.length; i++) ...[
                  _buildAddressCard(
                    index: i,
                    title: _addresses[i].name + (i == 0 ? ' (Home)' : ''),
                    address:
                        '${_addresses[i].houseNo}, ${_addresses[i].addressLine}\n${_addresses[i].city}, ${_addresses[i].state} - ${_addresses[i].pincode}',
                    phone: _addresses[i].phone,
                    icon: Icons.home_rounded,
                    isDefault: _addresses[i].isDefault,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
          // Floating Action Button Style Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/address-form');
                  // refresh list after returning from add
                  await _loadAddresses();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Add New Address",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required int index,
    required String title,
    required String address,
    required String phone,
    required IconData icon,
    bool isDefault = false,
  }) {
    final bool isSelected = _selectedAddressIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedAddressIndex = index);
        if (widget.isSelectionMode) {
          final addressCode = (index < _addresses.length)
              ? _addresses[index].id
              : '';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                totalAmount: widget.checkoutTotal ?? 0,
                items: widget.checkoutItems ?? [],
                addressCode: addressCode,
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isDefault)
              Positioned(
                top: -30,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text(
                    "DEFAULT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isSelected ? AppColors.primary : Colors.grey)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      )
                    else
                      Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey[300],
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildActionButton(Icons.edit, "Edit", () {}),
                    const SizedBox(width: 20),
                    _buildActionButton(Icons.delete, "Delete", () {}),
                    if (!isDefault) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Set as Default",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonAddressCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduledSkeleton(height: 48, width: 48, borderRadius: 12),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScheduledSkeleton(height: 16, width: 120, borderRadius: 4),
                    SizedBox(height: 8),
                    ScheduledSkeleton(height: 12, width: 180, borderRadius: 4),
                    SizedBox(height: 6),
                    ScheduledSkeleton(height: 12, width: 140, borderRadius: 4),
                  ],
                ),
              ),
              ScheduledSkeleton(height: 24, width: 24, borderRadius: 12),
            ],
          ),
          SizedBox(height: 20),
          Divider(height: 1),
          SizedBox(height: 12),
          Row(
            children: [
              ScheduledSkeleton(height: 14, width: 50, borderRadius: 4),
              SizedBox(width: 20),
              ScheduledSkeleton(height: 14, width: 60, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
