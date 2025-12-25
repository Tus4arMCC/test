import 'package:flutter/material.dart';
import '../home/widgets/hero_carousel.dart';
import '../home/widgets/categories_section.dart';
import '../product/widgets/product_card.dart';
import '../home/repositories/home_repository.dart';
import '../product/models/product_tag_model.dart';
import '../product/models/product_model.dart';
import '../product/widgets/product_tag_section.dart';
// import '.././core/cache/cache_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ProductTag>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = HomeRepository().fetchHomeProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        const HeroCarousel(),

        const SizedBox(height: 20),
        const CategoriesSection(),

        const SizedBox(height: 20),

        FutureBuilder<List<ProductTag>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            final tags = snapshot.data ?? [];

            return Column(
              children: tags.map((tag) {
                return ProductTagSection(
                  title: tag.tag,
                  products: tag.products,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
