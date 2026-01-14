import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthStorage.isLoggedIn();
    final userData = await AuthStorage.getUser();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _userData = userData;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthStorage.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return _buildGuestProfile(context);
    }

    return _buildUserProfile(context);
  }

  // ===========================================================================
  // GUEST PROFILE
  // ===========================================================================
  Widget _buildGuestProfile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Guest Avatar & Welcome
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        Colors.purple.withValues(alpha: 0.2),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.person_off,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Welcome, Guest!",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sign in to track your orders, view your wishlist, and manage your profile.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                child: const Text(
                  "Log In",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),

            _buildSectionHeader(context, "Your Activity", "Login to view"),
            const SizedBox(height: 8),
            _buildSkeletonCard(context),

            const SizedBox(height: 24),

            _buildSectionHeader(context, "App Settings", ""),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.language,
                    Colors.green,
                    "Language",
                    "English (US)",
                    showArrow: true,
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildThemeToggleItem(context),
                  const Divider(height: 1, indent: 64),
                  _buildMenuItem(
                    context,
                    Icons.help,
                    Colors.teal,
                    "Help Center",
                    null,
                    showArrow: true,
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildMenuItem(
                    context,
                    Icons.privacy_tip,
                    Colors.indigo,
                    "Privacy Policy",
                    null,
                    showArrow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              "Version 1.0.2",
              style: textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // USER PROFILE
  // ===========================================================================
  Widget _buildUserProfile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final name = _userData?['name'] ?? "User";
    final email = _userData?['userName'] ?? "user@example.com";

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Edit",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      const BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: const NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuB1umkA7zZoXs27SMfZCEJFVYaLstWvfdE79kB6Ojks7mGU7EvZ-zDuy-_IswocfsWHPwNugY8rx0dIX_jNaCY_BrNsBqlB1MTiP92jms22I0ocNp4Jkep6FfaOtDYzI1jau01hdO55Nop2Dxmzg4x7-FyfqGKb-WYR9ZWgqLqHtH5KJoxqGcu58qgJuiesRqq_UoElkNWVilJT8wH2vSCtswp7nhRXHjDClB3ypXCgP7p07IgAyswj-mtPonicyb-1XqkwaAUz_tsx",
                    ),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              name,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              email,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    "VIP FASHIONISTA",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "12", "Orders")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "58", "Wishlist")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "240", "Points")),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(context, "Shopping", ""),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.history,
                    Colors.pink,
                    "Order History",
                    null,
                    showArrow: true,
                    onTap: () => Navigator.pushNamed(context, '/orders'),
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildMenuItem(
                    context,
                    Icons.place,
                    Colors.blue,
                    "My Addresses",
                    null,
                    showArrow: true,
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildMenuItem(
                    context,
                    Icons.credit_card,
                    Colors.orange,
                    "Payment Methods",
                    null,
                    showArrow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(context, "Preferences", ""),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.notifications,
                    Colors.purple,
                    "Notifications",
                    null,
                    badgeContent: "2",
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildMenuItem(
                    context,
                    Icons.language,
                    Colors.green,
                    "Language",
                    "English (US)",
                    showArrow: true,
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildThemeToggleItem(context),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(context, "Support", ""),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.help,
                    Colors.teal,
                    "Help Center",
                    null,
                    showArrow: true,
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildMenuItem(
                    context,
                    Icons.privacy_tip,
                    Colors.indigo,
                    "Privacy Policy",
                    null,
                    showArrow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _logout,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withValues(alpha: 0.05),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Log Out",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text(
              "Version 1.0.2",
              style: textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============== WIDGETS ==============

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
      ],
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildSkeletonRow(),
          const SizedBox(height: 16),
          _buildSkeletonRow(),
          const SizedBox(height: 16),
          _buildSkeletonRow(),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120, height: 12, color: Colors.grey[200]),
              const SizedBox(height: 6),
              Container(width: 60, height: 10, color: Colors.grey[200]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String title,
    String? value, {
    bool showArrow = false,
    String? badgeContent,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (value != null)
                    Text(
                      value,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (badgeContent != null)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeContent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (showArrow) const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleItem(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.blue[300] : Colors.orange[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Dark Mode",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),

          // ANIMATED CUSTOM TOGGLE
          GestureDetector(
            onTap: () {
              ThemeController.toggleTheme();
              // No need to call setState here because ValueListenableBuilder in main.dart handles it
              // But for immediate visual feedback on the button itself if needed:
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? AppColors.primary : Colors.grey[300],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny,
                        key: ValueKey(isDark),
                        size: 14,
                        color: isDark ? AppColors.primary : Colors.orange,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
