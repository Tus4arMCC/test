import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/profile_screen.dart';

import '../../common/navigation/app_bottom_navbar.dart';
import '../../common/navigation/bottom_nav_item.dart';
import '../home/services/wishlist_api_service.dart';
import '../home/services/cart_api_service.dart';
import '../../core/storage/auth_storage.dart';
import '../../core/state/wishlist_state_manager.dart';
import '../../core/state/count_state_manager.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final _wishlistManager = WishlistStateManager();
  final _countManager = CountStateManager();

  final List<Widget> _pages = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(showBackButton: false),
    WishlistScreen(showBackButton: false),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize wishlist state when app starts
    _wishlistManager.initialize();
    // Initialize counts
    _countManager.initialize();
    // Listen to count changes
    _countManager.addListener(_onCountChanged);
  }

  void _onCountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _countManager.removeListener(_onCountChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // If clicking the same tab, refresh the page
          if (index == _currentIndex) {
            // Refresh count API
            await _countManager.refresh();

            // Refresh specific page data
            if (index == 2) {
              // Cart page refresh
              final user = await AuthStorage.getUser();
              final uid =
                  user?['uid'] ??
                  user?['id'] ??
                  user?['code'] ??
                  user?['userName'];
              if (uid != null) {
                await CartApiService.fetchBag(
                  uid: uid.toString(),
                  variations: [],
                );
              }
            } else if (index == 3) {
              // Wishlist page refresh
              final user = await AuthStorage.getUser();
              final variationCode = await AuthStorage.getVariationCode();
              final uid =
                  user?['uid'] ??
                  user?['id'] ??
                  user?['code'] ??
                  user?['userName'];
              if (uid != null) {
                await WishlistApiService.syncChecklist(
                  uid: uid.toString(),
                  variationCode: variationCode,
                );
              }
            }
            if (mounted) {
              setState(() {});
            }
            return;
          }

          // Normal tab switching logic
          if (index == 2) {
            final user = await AuthStorage.getUser();
            final uid =
                user?['uid'] ??
                user?['id'] ??
                user?['code'] ??
                user?['userName'];
            if (uid != null) {
              // Call fetchBag with empty variations as requested
              CartApiService.fetchBag(uid: uid.toString(), variations: [])
                  .then((cart) {
                    // Update count manager with new cart count
                    _countManager.refresh();
                  })
                  .catchError((e) {
                    debugPrint("Error fetching bag on tab switch: $e");
                  });
            }
          } else if (index == 3) {
            final user = await AuthStorage.getUser();
            final variationCode = await AuthStorage.getVariationCode();
            final uid =
                user?['uid'] ??
                user?['id'] ??
                user?['code'] ??
                user?['userName'];

            if (uid != null) {
              WishlistApiService.syncChecklist(
                    uid: uid.toString(),
                    variationCode: variationCode,
                  )
                  .then((_) {
                    // Refresh counts after syncing
                    _countManager.refresh();
                  })
                  .catchError((e) {
                    debugPrint("Error syncing checklist: $e");
                  });
            }
          }
          setState(() => _currentIndex = index);
        },
        items: [
          const BottomNavItem(icon: Icons.home, label: "Home"),
          const BottomNavItem(icon: Icons.search, label: "Explore"),
          BottomNavItem(
            icon: Icons.shopping_bag,
            label: "Cart",
            isBig: true,
            badgeCount: _countManager.cartCount > 0
                ? _countManager.cartCount
                : null,
          ),
          BottomNavItem(
            icon: Icons.favorite,
            label: "Wishlist",
            badgeCount: _countManager.wishlistCount > 0
                ? _countManager.wishlistCount
                : null,
          ),
          const BottomNavItem(icon: Icons.person, label: "Profile"),
        ],
      ),
    );
  }
}
