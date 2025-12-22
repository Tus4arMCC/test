import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Text(
              "Profile",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 24),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login"),
              ),
            ),

            const SizedBox(height: 16),

            // THEME TOGGLE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.brightness_6),
                label: const Text("Toggle Theme"),
                onPressed: () {
                  ThemeController.toggleTheme(); // ✅ FIX
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
