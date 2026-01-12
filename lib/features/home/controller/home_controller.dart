import 'package:flutter/material.dart';
import '../repositories/home_repository.dart';
import '../models/product_tag_model.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository _repo = HomeRepository();

  bool isLoading = true;
  List<ProductTag> tags = [];

  Future<void> loadHome() async {
    isLoading = true;
    notifyListeners();

    tags = await _repo.fetchHomeProducts();

    isLoading = false;
    notifyListeners();
  }
}
