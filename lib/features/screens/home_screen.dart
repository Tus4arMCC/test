import 'package:flutter/material.dart';
import '../home/widgets/hero_carousel.dart';
import '../home/widgets/categories_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 12),
        HeroCarousel(),
        SizedBox(height: 20),
        CategoriesSection(),
      ],
    );  
}
}