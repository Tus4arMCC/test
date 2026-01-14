import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/skeleton.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

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
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Order #ORD-3920",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Oct 24, 2023 • 2 Items",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Status Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "In Transit",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                const Text(
                                  "Arriving Tomorrow, 2:00 PM",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Timeline
                        _buildTimelineStep(
                          title: "Order Placed",
                          subtitle: "Oct 24, 10:30 AM",
                          isCompleted: true,
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          title: "Packed",
                          subtitle: "Oct 25, 09:15 AM",
                          isCompleted: true,
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          title: "Shipped",
                          subtitle: "Oct 25, 06:45 PM • Frankfurt, DE",
                          isCompleted: false,
                          isCurrent: true,
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          title: "Delivered",
                          subtitle: "Estimated Oct 26",
                          isCompleted: false,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Items Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Items (2)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                _buildOrderItem(
                  context,
                  title: "Oversized Trench",
                  price: "120.00",
                  subtitle: "Size: M • Beige",
                  imageUrl:
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuAlDw--mzkKV9_GAAWaP6KyG9vm8i0MaTlTiwBfTwxTwGiUqQ4M9kHWsY7GbpEHZXCqCQpsh1R_ST8Ozhgr9tl-YDey1Ei1Bp-9GHtH_pdKVtrpkx69dEKA7c8KxxDwNBhAgj2ZVcGj4H4n4cae3FPkQmxjneXWtXZF8MimFbER1Q-mb8t8ZfodEaHVIlYz29itKmF_ARV5ZhRrvGadqG9ujNtH4r6bAzElpRAIFjWjLwin6XPMGK6yvKJVfXT4MID5GwQbzqfIS-55",
                ),
                _buildOrderItem(
                  context,
                  title: "Velvet Pumps",
                  price: "85.00",
                  subtitle: "Size: 38 • Blue",
                  imageUrl:
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuDF3UU9OgkSdZyTBzzoDoWqrQPhz7syO4-_0GMBK6jK29O0RV7HfkBnPEvc2lgYbq-mrwFPTvm6e9ChjM6dgJsO-z787SreucjG5gxMmW2hSi2XJuKZEWYPVinI4xKRmr38ZQdaHZrYzexP1FgVBzMYfjO5rt7LzuFxdQTjhuh7jIyl4AmiijNQiLR8g5nzxrzu2sQxOz2DXP55kl2_kgIySAvbv8Yc2pVSWRQ-Cvr_jGE3m936kmLO9fNGtTaPvSl7ADpkiflawVts",
                ),

                const SizedBox(height: 16),

                // Details Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          icon: Icons.location_on,
                          title: "Shipping",
                          detailBody: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jane Doe",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "123 Fashion Ave,\nNew York, NY 10001",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          icon: Icons.credit_card,
                          title: "Payment",
                          detailBody: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Visa ending 4242",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Exp 12/25",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Order Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow("Subtotal", "₹205.00"),
                        const SizedBox(height: 12),
                        _buildSummaryRow("Shipping", "₹0.00"),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          "Discount (FALL20)",
                          "-₹20.00",
                          isDiscount: true,
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              "₹185.00",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recommendation Skeleton
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "You Might Also Like",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScheduledSkeleton(
                              height: 160,
                              width: 120,
                              borderRadius: 12,
                            ),
                            SizedBox(height: 12),
                            ScheduledSkeleton(
                              height: 14,
                              width: 90,
                              borderRadius: 4,
                            ),
                            SizedBox(height: 8),
                            ScheduledSkeleton(
                              height: 12,
                              width: 60,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Return",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 20),
                          SizedBox(width: 8),
                          Text("Track Order"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isCurrent = false,
    required bool isLast,
  }) {
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 22,
                  )
                else if (isCurrent)
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                    fontSize: 14,
                    color: isCurrent ? AppColors.primary : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context, {
    required String title,
    required String price,
    required String subtitle,
    required String imageUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            AppImage(
              imageUrl: imageUrl,
              width: 70,
              height: 90,
              borderRadius: 10,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "₹$price",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Write a Review",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
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
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget detailBody,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          detailBody,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDiscount ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}
