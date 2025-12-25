import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  final bool isBig;
  final int? badgeCount;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.isBig = false,
    this.badgeCount,
  });

  Widget build(BuildContext context, bool isSelected) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isBig ? 56 : 40,
              height: isBig ? 56 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBig
                    ? theme.colorScheme.primary
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: isBig ? 28 : 22,
                color: isBig
                    ? Colors.white
                    : isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey,
              ),
            ),

            /// BADGE
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        if (!isBig)
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey,
            ),
          ),
      ],
    );
  }
}
