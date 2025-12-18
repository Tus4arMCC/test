import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
        debugPrint("Wishlist loaded");

    return const Center(
      child: Text('Wishlist', style: TextStyle(fontSize: 22)),
    );
  }
}
