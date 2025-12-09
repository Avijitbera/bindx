import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:bindx/src/caching/cache_engine.dart';

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
