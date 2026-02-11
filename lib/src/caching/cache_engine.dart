import 'package:shared_preferences/shared_preferences.dart';
import 'package:bindx/src/annotations/cache_annotation.dart';
import 'package:bindx/src/caching/disk_storage.dart';

class CacheEngine {
  late SharedPreferences _prefs;
  final List<CacheStorage> _storage = [];

  CacheEngine() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _storage.add(MemoryStorage());
    _storage.add(DiskStorage(_prefs));
  }

  Future<void> set<T>(
    String key,
    T value, {
    Duration duration = const Duration(minutes: 30),
    String? tag,
    CacheStrategy strategy = CacheStrategy.memory,
  }) async {
    final entry = CacheEntry(
      value: value,
      expiry: DateTime.now().add(duration),
      tag: tag,
    );
    switch (strategy) {
      case CacheStrategy.memory:
        await _storage[0].set(key, entry);
        break;
      case CacheStrategy.disk:
        await _storage[1].set(key, entry);
        break;
      case CacheStrategy.memoryFirst:
        await _storage[0].set(key, entry);
        await _storage[1].set(key, entry);
        break;
      case CacheStrategy.diskFirst:
        await _storage[1].set(key, entry);
        await _storage[0].set(key, entry);
        break;
    }
  }

  Future<void> invalidateByTag(String tag) async {
    for (final storage in _storage) {
      await storage.invalidateByTag(tag);
    }
  }

  Future<void> clear() async {
    for (final storage in _storage) {
      await storage.clear();
    }
  }

  Future<T?> get<T>(
    String key, {
    CacheStrategy strategy = CacheStrategy.memoryFirst,
  }) async {
    switch (strategy) {
      case CacheStrategy.memoryFirst:
        final memory = await _storage[0].get<T>(key);
        if (memory != null) return memory;
        return await _storage[1].get<T>(key);
      case CacheStrategy.diskFirst:
        final disk = await _storage[1].get<T>(key);
        if (disk != null) return disk;
        return await _storage[0].get<T>(key);
      case CacheStrategy.memory:
        return await _storage[0].get<T>(key);
      case CacheStrategy.disk:
        return await _storage[1].get<T>(key);
    }
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiry;
  final String? tag;

  CacheEntry({required this.value, required this.expiry, this.tag});

  bool get isExpired => DateTime.now().isAfter(expiry);

  Map<String, dynamic> toJson() => {
    'value': value,
    'expiry': expiry,
    'tag': tag,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      expiry: DateTime.parse(json['expiry']),
      tag: json['tag'],
      value: json['value'],
    );
  }
}

abstract class CacheStorage {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, CacheEntry<T> entry);
  Future<void> invalidate(String key);
  Future<void> invalidateByTag(String tag);
  Future<void> clear();
}

class MemoryStorage implements CacheStorage {
  final Map<String, CacheEntry> _cache = {};

  @override
  Future<T?> get<T>(String key) async {
    final entry = _cache[key] as CacheEntry<T>?;
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  Future<void> set<T>(String key, CacheEntry<T> entry) async {
    _cache[key] = entry;
  }

  @override
  Future<void> invalidate(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> invalidateByTag(String tag) async {
    _cache.removeWhere((key, entry) => entry.tag == tag);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }
}
