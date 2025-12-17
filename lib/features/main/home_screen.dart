import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
            debugPrint("Home loaded");

    return const Center(child: Text('Home', style: TextStyle(fontSize: 22)));
  }
}
