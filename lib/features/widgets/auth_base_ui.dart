import 'package:flutter/material.dart';

class AuthBaseUI extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  const AuthBaseUI({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),

                const SizedBox(height: 16),

                /// Top Card
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(subtitle, style: theme.textTheme.bodyMedium),

                const SizedBox(height: 28),

                form,

                const SizedBox(height: 20),

                footer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
