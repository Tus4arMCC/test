import '../../../core/cache/cache_manager.dart';
import '../../../core/cache/cache_keys.dart';
import '../services/category_api_service.dart';

class CategoryRepository {
  static const _ttl = Duration(hours: 24);

  Future<List<String>> getCategories() async {
    final cache = CacheManager.instance;

    // 1️⃣ Memory / Local cache
    final cached = cache.get<List>(CacheKeys.categories);
    final expired = cache.isExpired(CacheKeys.categoriesTime, _ttl);

    if (cached != null && !expired) {
      return List<String>.from(cached);
    }

    // 2️⃣ API call
    final categories = await CategoryApiService.fetchCategories();

    // 3️⃣ Save cache
    await cache.set(CacheKeys.categories, categories);
    await cache.setTimestamp(CacheKeys.categoriesTime);

    return categories;
  }
}
