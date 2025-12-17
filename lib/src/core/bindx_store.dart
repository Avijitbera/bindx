import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bindx/src/annotations/cache_annotation.dart';
import 'package:bindx/src/caching/cache_engine.dart';
import 'package:bindx/src/concurrency/task_manager.dart';

import '../annotations/concurrent_annotation.dart';

class BindXStore<T> extends ChangeNotifier {
  final T _initialState;
  late T _state;
  final Map<Symbol, dynamic> _annotations = {};
  final Map<Symbol, StreamController> _streamControllers = {};
  final CacheEngine _cacheEngine;
  final TaskManager _taskManager;
  final Map<String, dynamic> _computedCache = {};

  final StreamController<T> _stateController = StreamController<T>.broadcast();

  BindXStore(
    T initialState, {
    CacheEngine? cacheEngine,
    TaskManager? taskManager,
  }) : _initialState = initialState,
       _state = initialState,
       _cacheEngine = cacheEngine ?? CacheEngine(),
       _taskManager = taskManager ?? TaskManager() {
    _processAnnotations();
  }

  T get state => _state;
  T get initialState => _initialState;
  Stream<T> get stream => _stateController.stream;

  void _processAnnotations() {}

  Future<void> update(
    FutureOr<T> Function(T current) updater, {
    String? action,
    bool notify = true,
  }) async {
    final oldState = _state;

    final result = await _taskManager.execute(
      () => updater(oldState),
      annotation: _getAnnotation<Concurrent>(action),
    );

    _state = result;
    if (notify) {
      notifyListeners();
      _stateController.add(_state);
    }
  }

  @Cache(duration: Duration(minutes: 5))
  Future<R> cachedGet<R>(
    String key,
    Future<R> Function() compute, {
    Duration? duration,
  }) async {
    final cacheKey = '${T.toString()}_$key';
    final cached = await _cacheEngine.get<R>(cacheKey);
    if (cached != null) {
      return cached;
    }
    final result = await compute();
    await _cacheEngine.set(cacheKey, result, duration: duration!);
    return result;
  }

  R getCached<R>(String key, R Function() compute) {
    final cacheKey = '${T.toString()}_$key';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey] as R;
    }
    final result = compute();
    _computedCache[cacheKey] = result;
    return result;
  }

  Stream<R> streamOf<R>(String propertyName) {
    final controller = StreamController<R>.broadcast();
    addListener(() {
      final value = _getProperty<R>(propertyName);
      controller.add(value);
    });
    return controller.stream;
  }

  dynamic _getProperty<R>(String propertyName) {
    return null;
  }

  Future<void> _acquireLock(T state) async {}

  Future<void> _processCacheAnnotations(T oldState, T newState) async {}

  void _processStreamAnnotations(T oldState, T newState) {}

  A? _getAnnotation<A>(String? action) {
    if (action == null) return null;
    return _annotations[Symbol(action)] as A?;
  }

  @override
  void dispose() {
    _stateController.close();
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    super.dispose();
  }
}
