import 'dart:async';

import 'package:bindx/src/core/bindx_store.dart';
import 'package:flutter/foundation.dart';

class BindxRegistry {
  static final BindxRegistry _instance = BindxRegistry._internal();
  factory BindxRegistry() => _instance;

  BindxRegistry._internal();

  final Map<Type, Map<String?, dynamic>> _stores = {};
  final Map<String, dynamic> _namedStores = {};
  final Map<Type, List<VoidCallback>> _listeners = {};

  T register<T>({required T store, String? name, bool override = false}) {
    final storeType = T;
    final stores = _stores.putIfAbsent(storeType, () => {});

    if (stores.containsKey(name) && !override) {
      throw StateError(
        "Store of type $storeType with name $name already registered",
      );
    }

    stores[name] = store;

    if (name != null) {
      _namedStores['$storeType#$name'] = store;
    }

    return store;
  }

  T get<T>({String? name}) {
    final stores = _stores[T];
    if (stores == null && !stores!.containsKey(name)) {
      throw StateError("Store of type $T with name $name not found");
    }

    return stores[name] as T;
  }

  dynamic getByType(Type type, {String? name}) {
    final stores = _stores[type];
    if (stores == null || !stores.containsKey(name)) {
      throw StateError("Store of type $type with name $name not found");
    }

    return stores[name];
  }

  bool exists<T>({String? name}) {
    return _stores.containsKey(T) && _stores[T]!.containsKey(name);
  }

  bool existsByType(Type type, {String? name}) {
    return _stores.containsKey(type) && _stores[type]!.containsKey(name);
  }

  void remove<T>({String? name}) {
    final stores = _stores[T];
    if (stores != null) {
      final store = stores.remove(name);
      if (store is BindXStore) {
        store.dispose();
      }
      if (name != null) {
        _namedStores.remove('$T#$name');
      }
      if (stores.isEmpty) {
        _stores.remove(T);
      }
      _notifyListeners(T);
    }
  }

  Stream<T> watch<T>({String? name}) {
    final controller = StreamController<T>.broadcast();
    void update() {
      if (exists<T>(name: name)) {
        controller.add(get<T>(name: name));
      }
    }

    final listener = () => update();
    _addListener(T, listener);
    if (exists<T>(name: name)) {
      controller.add(get<T>(name: name));
    }

    controller.onCancel = () {
      _removeListener(T, listener);
    };

    return controller.stream;
  }

  void _addListener(Type type, VoidCallback listener) {
    _listeners.putIfAbsent(type, () => []).add(listener);
  }

  void _removeListener(Type type, VoidCallback listener) {
    _listeners[type]?.remove(listener);
  }

  void _notifyListeners(Type type) {
    _listeners[type]?.forEach((listener) => listener());
  }

  void clear() {
    for (final stores in _stores.values) {
      for (final store in stores.values) {
        if (store is BindXStore) {
          store.dispose();
        }
      }
    }
    _stores.clear();
    _namedStores.clear();
    _listeners.clear();
  }
}

final bindxRegistry = BindxRegistry();
