import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
        debugPrint("Categories loaded");

    return const Center(
      child: Text('Categories', style: TextStyle(fontSize: 22)),
    );
  }
}
