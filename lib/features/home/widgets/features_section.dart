import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: theme.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildFeatureItem(
              icon: Icons.local_shipping_outlined,
              title: "Free Shipping",
              subtitle: "For orders above ₹500* (TnC Apply)",
              theme: theme,
            ),
          ),
          Expanded(
            child: _buildFeatureItem(
              icon: Icons.verified_user_outlined,
              title: "Highest Safety Standards",
              subtitle: "Enjoy worry-free shopping",
              theme: theme,
            ),
          ),
          Expanded(
            child: _buildFeatureItem(
              icon: Icons.lock_outline,
              title: "Secured Payments",
              subtitle: "Fast and Secure Checkout",
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
