import '../../../core/cache/cache_manager.dart';
import '../models/product_tag_model.dart';
import '../services/home_product_api_service.dart';

class HomeRepository {
  static const _cacheKey = "home_products";
  static const _cacheTimeKey = "home_products_time";
  static const _ttl = Duration(minutes: 30);

  Future<List<ProductTag>> fetchHomeProducts() async {
    final cache = CacheManager.instance;

    /// 1️⃣ MEMORY CACHE
    final memoryData = cache.getMemory<List<ProductTag>>(_cacheKey);
    if (memoryData != null) {
      // Validate cached memory data has proper codes
      final hasValidCodes = memoryData.every(
        (tag) => tag.products.every((product) => product.code.isNotEmpty),
      );
      if (hasValidCodes) {
        return memoryData;
      }
    }

    /// 2️⃣ HIVE CACHE (if not expired)
    final isExpired = cache.isExpired(_cacheTimeKey, _ttl);
    if (!isExpired) {
      final hiveData = cache.get(_cacheKey);
      if (hiveData != null) {
        try {
          // Hive may return a List<dynamic> (maps) or List<ProductTag>.
          // Normalize to List<ProductTag> to avoid invalid cast errors.
          final List<ProductTag> parsed = hiveData is List<ProductTag>
              ? hiveData
              : (hiveData as List).map<ProductTag>((e) {
                  if (e is ProductTag) return e;
                  if (e is Map)
                    return ProductTag.fromJson(Map<String, dynamic>.from(e));
                  return ProductTag.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  );
                }).toList();

          // Ensure cached data is sorted
          parsed.sort((a, b) => a.order.compareTo(b.order));

          // Validate parsed data has proper codes
          final hasValidCodes = parsed.every(
            (tag) => tag.products.every((product) => product.code.isNotEmpty),
          );
          if (hasValidCodes) {
            cache.setMemory(_cacheKey, parsed);
            return parsed;
          } else {
            // Clear invalid cache
            await cache.clear(_cacheKey);
            await cache.clear(_cacheTimeKey);
          }
        } catch (e) {
          // If parsing fails, clear cache
          await cache.clear(_cacheKey);
          await cache.clear(_cacheTimeKey);
        }
      }
    }

    /// 3️⃣ API FETCH
    final response = await ProductApiService.fetchHomeProducts();
    final List list = (response['data'] is List)
        ? response['data'] as List
        : [];

    final tags = list.map<ProductTag>((e) {
      if (e is ProductTag) return e;
      if (e is Map) return ProductTag.fromJson(Map<String, dynamic>.from(e));
      return ProductTag.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();

    // Sort tags by order as requested
    tags.sort((a, b) => a.order.compareTo(b.order));

    /// 4️⃣ SAVE TO CACHE
    cache.setMemory(_cacheKey, tags);
    await cache.set(_cacheKey, tags);
    await cache.setTimestamp(_cacheTimeKey);

    return tags;
  }
}
