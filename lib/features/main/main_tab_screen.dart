import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/cart_screen.dart';
import '../wishlist/screens/wishlist_screen.dart';
import '../screens/profile_screen.dart';

import '../../common/navigation/app_bottom_navbar.dart';
import '../../common/navigation/bottom_nav_item.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});
                            
  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(), // ✅ THIS is your profile UI
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // ✅ REAL PAGE, NO PAGE NUMBER

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
          BottomNavItem(
            icon: Icons.favorite, 
            label: "Wishlist",
            badgeCount: 4, 
          ),
          BottomNavItem(icon: Icons.person, label: "Profile"),
        ],
      ),
    );
  }
}
