import 'package:flutter/material.dart';
import '../common/navigation/app_bottom_navbar.dart';
import '../common/navigation/bottom_nav_item.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Page $_currentIndex"),
      ),

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavItem(icon: Icons.home, label: "Home"),
          BottomNavItem(icon: Icons.search, label: "Explore"),
          BottomNavItem(
            icon: Icons.shopping_bag,
            label: "Cart",
            isBig: true,
            badgeCount: 2,
          ),
          BottomNavItem(icon: Icons.favorite, label: "Saved"),
          BottomNavItem(icon: Icons.person, label: "Profile"),
        ],
      ),
    );
  }
}
