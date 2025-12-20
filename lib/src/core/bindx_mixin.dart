import 'dart:async';

import 'package:bindx/src/annotations/concurrent_annotation.dart';
import 'package:bindx/src/concurrency/task_manager.dart';

mixin StategenMixin {
  final _taskManager = TaskManager();
  // final _cacheEngine = CacheEngine();
  final Map<String, dynamic> _computedCache = {};
  final Map<String, StreamController> _streamControllers = {};

  Future<T> executeConcurrent<T>(
    FutureOr<T> Function() task, {
    Concurrent? annotation,
  }) async {
    return _taskManager.execute(task, annotation: annotation);
  }

  Future<void> acquireLock(String key) async {
    await _taskManager.acquireLock(key);
  }

  void releaseLock(String key) {
    _taskManager.releaseLock(key);
  }

  R getCached<R>(String key, R Function() compute) {
    final cacheKey = '${this.runtimeType}_$key';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey] as R;
    }
    final result = compute();
    _computedCache[cacheKey] = result;
    return result;
  }

  Stream<R> streamOf<R>(String propertyName) {
    final key = '${this.runtimeType}_$propertyName';
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] = StreamController<R>.broadcast();
    }
    return (_streamControllers[key] as StreamController<R>).stream;
  }
}
