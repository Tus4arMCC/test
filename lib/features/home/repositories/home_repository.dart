import '../../../core/cache/cache_manager.dart';
import '../../product/models/product_tag_model.dart';
import '../../auth/auth_service.dart';

class HomeRepository {
  static const _cacheKey = "home_products";
  static const _cacheTimeKey = "home_products_time";
  static const _ttl = Duration(minutes: 15);

  Future<List<ProductTag>> fetchHomeProducts() async {
    final cache = CacheManager.instance;

    /// 1️⃣ MEMORY CACHE
    final memoryData = cache.getMemory<List<ProductTag>>(_cacheKey);
    if (memoryData != null) {
      return memoryData;
    }

    /// 2️⃣ HIVE CACHE (if not expired)
    final isExpired = cache.isExpired(_cacheTimeKey, _ttl);
    if (!isExpired) {
      final hiveData = cache.get<List<ProductTag>>(_cacheKey);
      if (hiveData != null) {
        cache.setMemory(_cacheKey, hiveData);
        return hiveData;
      }
    }

    /// 3️⃣ API FETCH
    final response = await AuthService.fetchHomeProducts();
    final List list = response['data'];

    final tags = list
        .map<ProductTag>((e) => ProductTag.fromJson(e))
        .toList();

    /// 4️⃣ SAVE TO CACHE
    cache.setMemory(_cacheKey, tags);
    await cache.set(_cacheKey, tags);
    await cache.setTimestamp(_cacheTimeKey);

    return tags;
  }
}
