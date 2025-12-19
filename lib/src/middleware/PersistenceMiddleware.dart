import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'middleware.dart';

class PersistenceMiddleware<T> implements Middleware<T> {
  final String storageKey;
  final Duration? debounceDuration;
  final Future<void> Function(T state)? customSave;
  final Future<T?> Function()? customLoad;

  Timer? _debounceTimer;
  SharedPreferences? _prefs;

  PersistenceMiddleware({
    required this.storageKey,
    this.debounceDuration,
    this.customSave,
    this.customLoad,
  });

  @override
  Future<T> afterUpdate(T newState, T oldState, String action) async {
    if (debounceDuration != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceDuration!, () {
        _save(newState);
      });
    } else {
      await _save(newState);
    }

    return newState;
  }

  @override
  Future<T> beforeUpdate(
    T currentState,
    T Function(T p1) updater,
    String action,
  ) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      final saved = await _load();
      if (saved != null) {
        return saved;
      }
    }

    return currentState;
  }

  Future<void> _save(T state) async {
    try {
      if (customSave != null) {
        await customSave!(state);
      } else {
        final json = jsonEncode(state);
        await _prefs?.setString(storageKey, json);
      }
    } catch (e) {
      print('Failed to persist state: $e');
    }
  }

  Future<T?> _load() async {
    try {
      if (customLoad != null) {
        return await customLoad!();
      } else {
        final json = _prefs?.getString(storageKey);
        if (json != null) {
          // Note: This requires state to be serializable
          return jsonDecode(json) as T;
        }
      }
    } catch (e) {
      print('Failed to load persisted state: $e');
    }
    return null;
  }

  Future<void> clear() async {
    await _prefs?.remove(storageKey);
  }
}
