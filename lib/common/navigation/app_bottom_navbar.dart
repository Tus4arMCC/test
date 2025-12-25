// lib/common/navigation/app_bottom_navbar.dart

import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black26,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Transform.translate(
                // 🔥 THIS IS THE MAGIC
                offset: item.isBig ? const Offset(0, -14) : Offset.zero,
                child: item.build(context, isSelected),
              ),
            ),
          );
        }),
      ),
    );
  }
}
