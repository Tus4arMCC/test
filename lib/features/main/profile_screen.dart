import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
            debugPrint("Profile loaded");

    return const Center(
      child: Text('ProfileScreen', style: TextStyle(fontSize: 22)),
    );
  }
}
