import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  static final CacheManager instance = CacheManager._internal();
  CacheManager._internal();

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('app_cache');
  }

  T? get<T>(String key) => _box.get(key);

  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  bool isExpired(String timeKey, Duration ttl) {
    final savedTime = _box.get(timeKey);
    if (savedTime == null) return true;

    final saved = DateTime.parse(savedTime);
    return DateTime.now().difference(saved) > ttl;
  }

  Future<void> setTimestamp(String key) async {
    await _box.put(key, DateTime.now().toIso8601String());
  }

  Future<void> clear(String key) async {
    await _box.delete(key);
  }
}
