import '../../../core/cache/cache_manager.dart';
import '../models/product_detail_model.dart';
import '../services/product_api_service.dart';

class ProductRepository {
  static const _cachePrefix = "product_detail_";

  Future<ProductDetail> getProduct(String code) async {
    final cacheKey = "$_cachePrefix$code";

    // ✅ MEMORY CACHE ONLY
    ///
    /// Otherwise, a call is made to the ProductApiService to fetch the product and it is saved to the memory cache
    /// before being returned.
    final memory = CacheManager.instance.getMemory<ProductDetail>(cacheKey);
    if (memory != null) return memory;

    // 🌐 API
    final product = await ProductApiService.fetchProduct(code);

    // ✅ Save to memory only
    CacheManager.instance.setMemory(cacheKey, product);

    return product;
  }
}
