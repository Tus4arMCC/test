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
}
