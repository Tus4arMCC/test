import '../../../core/cache/cache_manager.dart';
import '../../home/models/product_data_model.dart';
import '../../home/services/product_detail_api_service.dart';

class ProductRepository {
  static const _cachePrefix = "product_detail_";

  Future<ProductData> getProduct(String code) async {
    final cacheKey = "$_cachePrefix$code";

    // ✅ MEMORY CACHE ONLY
    final memory = CacheManager.instance.getMemory<ProductData>(cacheKey);
    if (memory != null) return memory;

    // 🌐 API
    final productData = await ProductApiService.fetchProduct(code);

    // ✅ Save to memory only
    CacheManager.instance.setMemory(cacheKey, productData);

    return productData;
  }
}
