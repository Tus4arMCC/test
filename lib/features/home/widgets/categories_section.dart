import 'package:flutter/material.dart';

import '../services/category_api_service.dart';
import 'category_item.dart';
import 'categories_skeleton.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  List<String>? _categories;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await CategoryApiService.fetchCategories();
    setState(() => _categories = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_categories == null) {
      return const CategoriesSkeleton();
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return CategoryItem(
            title: _categories![index],
            isSelected: index == _activeIndex,
            onTap: () {
              setState(() => _activeIndex = index);
            },
          );
        },
      ),
    );
  }
}
