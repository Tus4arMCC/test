import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Theme Test",
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              isDark
                  ? "Dark mode is active"
                  : "Light mode is active",
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ThemeController.toggleTheme,
                child: Text(
                  isDark
                      ? "Switch to Light Mode"
                      : "Switch to Dark Mode",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
