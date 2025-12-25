import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/skeleton.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final List<String> _filters = ['All', 'Processing', 'Shipped', 'Delivered', 'Returns'];
  String _activeFilter = 'All';

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
          "My Orders",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final bool isActive = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _activeFilter = filter),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? AppColors.primary : colorScheme.outline.withOpacity(0.1),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isActive ? Colors.white : colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOrderCard(
            context,
            id: "#849321",
            date: "Oct 26, 2023",
            status: "Processing",
            amount: "156.00",
            statusColor: Colors.amber,
            images: [
              "https://lh3.googleusercontent.com/aida-public/AB6AXuDKB0hu-olHnAfPpEG5iMLa7-jEoXYQq-Pnf4mtQSnKrUP9TX_z8GOcnPzmaAC7XEVkOJOuqmJsSCOv_Ggl81T2sZ6pVKHlE9f0RKjexOFeiExQMtvdbfy_zRtUOhGA_stCpep6sQpsn2NP9kxOoHwpEhTHwbWJvcA60snRh-8j0zxHbbYY_kNXJNSiPpbGtJUXurZLvj_RB6ZT7BB3QefEboj1sSD8Y5K3rFECY0wNr8Crx5Z7xvNpJSiygX86gOyU-zMp9e0sla7-",
              "https://lh3.googleusercontent.com/aida-public/AB6AXuByUrQ98-9qcfmynzHvE21ZzKbOjFyVOv0vioreveUjWUXOwgIk3fNulBU2YgSjTOhYfkr9enAmodROA0cIo-gNYWExtTZKcyhB9j0kfYv5s_4tAZPFSX_2GhmAOU8nEEx5nY4hOUkAy2Ue4DdZMJhp3Ut0HAz6jtw4VO4sFb27bd-pjqaM6LxJngKKyEF1ShrLH8mApwLQtt4BssjeOZp6luXgzZCZioJo2fxxpPeAvWjV5OfQAxRoPt43e_RDrtvVEXcGmtDkpZdt",
            ],
            moreCount: 1,
            onTap: () => Navigator.pushNamed(context, '/order-detail'),
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            context,
            id: "#849320",
            date: "Oct 24, 2023",
            status: "Shipped",
            amount: "124.50",
            statusColor: Colors.blue,
            images: [
              "https://lh3.googleusercontent.com/aida-public/AB6AXuCC2l7CSSevJyMx-ZAq6Qv-FCbqVP46NpXYiSjhL3wPhXiKYWAFJ4snxzunhFQCJeRnnVuR4GUF9TmEY0OPU5IrXKtdyWYdOUMepcsjnv2EGmehV4JY7mNU58irdUOi82h1hhqn3tO6ARCnU4u4yVSN7zCKCyEA4qbFEhu6YaIIz48_LB8VtvxwWy2Q9J8q_nslkdRha53Qi3XHTckPXYREPFplhAuTUoNegkVxQ5q686yyVIRSvr05i9PfNLkGYbIIb-ZdLGawJyTq",
            ],
            onTap: () => Navigator.pushNamed(context, '/order-detail'),
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            context,
            id: "#849319",
            date: "Sep 15, 2023",
            status: "Delivered",
            amount: "89.00",
            statusColor: Colors.green,
            isFaded: true,
            images: [
              "https://lh3.googleusercontent.com/aida-public/AB6AXuCwBG1ZBhycKZHuNnUmjfqnCdvomZy-9l4OgGJY-mz3xQXL3piIpbtRs4R60EpMYA8Ly3I5ElpB92RLU1OBpEx7ycBhQ5arKaeIZCJ4erU-whrbyJrHZk9No-NwSvZ_xKKVbTpAbVo7h84Oo-Zh4jhLBj1MDmpshaYsds1ex0YedesD62d62Bbh1Tvv96X81QF8n8tnfIp83IVNwE_dS1MgpAYmiu6KPW5mCFTgENq8i1QwPblG0ZSDOoyAzln4UeT9DReve4HYhG6T",
              "https://lh3.googleusercontent.com/aida-public/AB6AXuDZlwXTGwMcPxRwq_QcSKvYmPFo2dBeuPJFKp-6Ny1-ezaigjsWkTxS36D4tucRRycTvIgKU9VGffFsb6pJ53FXSqrzC9c1_8lyGAFfVEvLpMUIHhCrq_me6KPKz0hlrdGMtNjAEBoH4NsFMgxrG8TAzpTvMSjkjbnY-IKIn672ERuTxe12hoxS5YWzvez2gGs7F0bL3p3N4lNJcagsrDx3USYcMPRb7FwoVa38_ZVYHKEiUMAWkCqOsIfVjOZ2dV1NaXbwyxPX9JwH",
            ],
            onTap: () => Navigator.pushNamed(context, '/order-detail'),
          ),
          const SizedBox(height: 16),
          // Skeleton Loader
          _buildSkeletonOrderCard(context),
          const SizedBox(height: 24),
          // Empty State
          _buildEmptyState(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String id,
    required String date,
    required String status,
    required String amount,
    required Color statusColor,
    required List<String> images,
    int moreCount = 0,
    bool isFaded = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: isFaded ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order $id",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Placed on $date",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == "Processing")
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        )
                      else if (status == "Shipped")
                        Icon(Icons.local_shipping, color: statusColor, size: 14)
                      else
                        Icon(Icons.check_circle, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ...images.map((url) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AppImage(
                    imageUrl: url,
                    width: 64,
                    height: 64,
                    borderRadius: 8,
                  ),
                )).toList(),
                if (moreCount > 0)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline.withOpacity(0.1), style: BorderStyle.none),
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surface,
                    ),
                    child: Center(
                      child: Text(
                        "+$moreCount",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      "₹$amount",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                    side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        status == "Processing" || status == "Shipped" ? "Track Order" : "View Details",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonOrderCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "LOADING PREVIEW",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScheduledSkeleton(height: 12, width: 80, borderRadius: 4),
                      SizedBox(height: 8),
                      ScheduledSkeleton(height: 14, width: 120, borderRadius: 4),
                    ],
                  ),
                  ScheduledSkeleton(height: 24, width: 70, borderRadius: 8),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: ScheduledSkeleton(height: 60, width: 60, borderRadius: 8),
                )),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScheduledSkeleton(height: 10, width: 60, borderRadius: 4),
                      SizedBox(height: 6),
                      ScheduledSkeleton(height: 20, width: 100, borderRadius: 4),
                    ],
                  ),
                  ScheduledSkeleton(height: 36, width: 110, borderRadius: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1), style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          const Text(
            "No older orders",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Looking for something specific? Check your returns or cancelled orders.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("View Returns"),
          ),
        ],
      ),
    );
  }
}
