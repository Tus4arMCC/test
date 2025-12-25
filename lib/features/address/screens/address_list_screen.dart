import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  int _selectedAddressIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "My Addresses",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _buildAddressCard(
                index: 0,
                title: "Jane Doe (Home)",
                address: "123 Fashion Avenue, Apt 4B\nNew York, NY 10012",
                phone: "(555) 123-4567",
                icon: Icons.home_rounded,
                isDefault: true,
              ),
              const SizedBox(height: 16),
              _buildAddressCard(
                index: 1,
                title: "Jane Doe (Work)",
                address: "456 Style Street, Suite 101\nNew York, NY 10018",
                phone: "(555) 987-6543",
                icon: Icons.work_rounded,
                isDefault: false,
              ),
              const SizedBox(height: 16),
              // Skeleton Example
              _buildSkeletonAddressCard(context),
              const SizedBox(height: 16),
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
                    colorScheme.background.withOpacity(0),
                    colorScheme.background,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/address-form'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 24),
                    SizedBox(width: 8),
                    Text("Add New Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      onTap: () => setState(() => _selectedAddressIndex = index),
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
              color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.black.withOpacity(0.02),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4)],
                  ),
                  child: const Text(
                    "DEFAULT",
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
                        color: (isSelected ? AppColors.primary : Colors.grey).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[400]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                            address,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 24)
                    else
                      Icon(Icons.radio_button_unchecked, color: Colors.grey[300], size: 24),
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
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
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
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
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
