import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheEngine {
  final Map<String, CacheEntry> _memoryCache = {};
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

class DiskStorage implements CacheStorage {
  final SharedPreferences _prefs;
  static const String _prefix = 'bindx_cache_';

  DiskStorage(this._prefs);

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      _prefs.remove(key);
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    final entryJson = _prefs.getString('$_prefix$key');
    if (entryJson == null) {
      return null;
    }
    final entry = CacheEntry.fromJson(
      jsonDecode(entryJson) as Map<String, dynamic>,
    );
    if (entry.isExpired) {
      await invalidate(key);
      return null;
    }
    return entry.value;
  }

  @override
  Future<void> invalidate(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  @override
  Future<void> invalidateByTag(String tag) async {
    final keys = _prefs.getKeys().where(
      (element) => element.startsWith(_prefix),
    );
    for (final key in keys) {
      final json = _prefs.getString(key);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        if (map['tag'] == tag) {
          await _prefs.remove(key);
        }
      }
    }
  }

  @override
  Future<void> set<T>(String key, CacheEntry<T> entry) async {
    await _prefs.setString('$_prefix$key', jsonEncode(entry.toJson()));
  }
}
