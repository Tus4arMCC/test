import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
        debugPrint("Categories loaded");

    return const Center(
      child: Text('Categories', style: TextStyle(fontSize: 22)),
    );
  }
}
