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

    // Acquire lock for thread-safe updates
    await _acquireLock(oldState);

    try {
      final result = await _taskManager.execute(
        () => updater(oldState),
        annotation: _getAnnotation<Concurrent>(action),
      );

      _state = result;

      // Process cache and stream annotations
      await _processCacheAnnotations(oldState, _state);
      _processStreamAnnotations(oldState, _state);

      if (notify) {
        notifyListeners();
        _stateController.add(_state);
      }
    } finally {
      // Always release lock, even if an error occurred
      _releaseLock();
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

  /// Acquires a lock for thread-safe state updates.
  /// This can be used with @Mutex annotation for critical sections.
  Future<void> _acquireLock(T state) async {
    // Generate a unique lock key based on the state type
    final lockKey = '${T.toString()}_lock';

    // Check if there's a Mutex annotation for this state
    final mutexAnnotation = _getAnnotation<Mutex>('mutex');

    if (mutexAnnotation != null) {
      // Use annotation-specific lock key and timeout
      await _taskManager.acquireLock(
        mutexAnnotation.lockKey,
        timeout: mutexAnnotation.timeout,
      );
    } else {
      // Use default locking with the type-based key
      await _taskManager.acquireLock(lockKey);
    }
  }

  /// Releases the lock acquired during state updates.
  /// This should always be called after _acquireLock to prevent deadlocks.
  void _releaseLock() {
    // Generate a unique lock key based on the state type
    final lockKey = '${T.toString()}_lock';

    // Check if there's a Mutex annotation for this state
    final mutexAnnotation = _getAnnotation<Mutex>('mutex');

    if (mutexAnnotation != null) {
      // Release annotation-specific lock
      _taskManager.releaseLock(mutexAnnotation.lockKey);
    } else {
      // Release default lock
      _taskManager.releaseLock(lockKey);
    }
  }

  /// Processes cache annotations and invalidates caches when state changes.
  /// This is called after state updates to handle cache invalidation.
  Future<void> _processCacheAnnotations(T oldState, T newState) async {
    // Only process if state has actually changed
    if (oldState == newState) return;

    // Clear the in-memory computed cache since state has changed
    // This ensures getCached() always returns fresh computed values
    _computedCache.clear();

    // Check for Cache annotation with tag for selective invalidation
    final cacheAnnotation = _getAnnotation<Cache>('cache');
    if (cacheAnnotation?.tag != null) {
      await _cacheEngine.invalidateByTag(cacheAnnotation!.tag!);
    }

    // Check for ReactiveCache annotation
    final reactiveCacheAnnotation = _getAnnotation<ReactiveCache>(
      'reactiveCache',
    );
    if (reactiveCacheAnnotation != null) {
      // Invalidate caches based on dependencies
      // Dependencies are property names that, when changed, should trigger cache invalidation
      // The CacheEngine doesn't have a direct invalidate method for single keys
      // For now, we rely on the computed cache being cleared above
      // Future enhancement: implement selective invalidation per dependency
    }
  }

  /// Processes stream annotations and emits values to registered streams.
  /// This is called after state updates to notify stream subscribers.
  void _processStreamAnnotations(T oldState, T newState) {
    // Emit to all registered stream controllers
    for (final controller in _streamControllers.values) {
      if (!controller.isClosed) {
        controller.add(newState);
      }
    }
  }

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
