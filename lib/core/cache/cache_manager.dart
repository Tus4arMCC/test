import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  static final CacheManager instance = CacheManager._internal();
  CacheManager._internal();

  static const String _boxName = 'app_cache';
  late Box<dynamic> _box;

  // In-memory cache (fast)
  static final Map<String, dynamic> _memoryCache = {};

  /// MUST be called before app starts
  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  /// ---------- MEMORY CACHE ----------
  T? getMemory<T>(String key) => _memoryCache[key] as T?;

  void setMemory(String key, dynamic value) {
    _memoryCache[key] = value;
  }

  bool containsMemory(String key) => _memoryCache.containsKey(key);

  void clearMemory() => _memoryCache.clear();

  /// ---------- HIVE CACHE ----------
  T? get<T>(String key) => _box.get(key) as T?;

  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  Future<void> clear(String key) async {
    await _box.delete(key);
  }

  /// ---------- TTL SUPPORT ----------
  bool isExpired(String timeKey, Duration ttl) {
    final savedTime = _box.get(timeKey);
    if (savedTime == null) return true;

    final saved = DateTime.parse(savedTime);
    return DateTime.now().difference(saved) > ttl;
  }

  Future<void> setTimestamp(String key) async {
    await _box.put(key, DateTime.now().toIso8601String());
  }
}
