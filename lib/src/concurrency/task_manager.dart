import 'dart:async';

import 'package:stategen/src/annotations/concurrent_annotation.dart';
import 'package:stategen/src/concurrency/task_queue.dart';

class TaskManager {
  final Map<String, TaskQueue> _queues = {};

  final Map<String, Completer> _locks = {};
  final Map<String, DateTime> _throttleLastRun = {};
  final Map<String, Timer> _debounceTimers = {};

  Future<T> execute<T>(
    FutureOr<T> Function() task, {
    Concurrent? annotation,
    String? queueKey,
  }) async {
    final config = annotation ?? const Concurrent();
    final key = queueKey ?? config.queueKey ?? 'default';
    if (config.debounce) {
      return _debounce(key, task, config.debounceDuration);
    }

    if (config.throttle) {
      return _throttle(key, task, config.throttleDuration);
    }

    if (config.maxConcurrent > 1) {
      return _executeConcurrent(key, task, config);
    }
    return await task();
  }

  Future<void> acquireLock(
    String localKey, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_locks.containsKey(localKey)) {
      await _locks[localKey]!.future.timeout(timeout);
    }
    _locks[localKey] = Completer();
  }

  void releaseLock(String localKey) {
    final completer = _locks[localKey];
    if (completer != null && !completer.isCompleted) {
      completer.complete();
      _locks.remove(localKey);
    }
  }

  Future<T> _throttle<T>(
    String key,
    FutureOr<T> Function() task,
    Duration duration,
  ) async {
    final now = DateTime.now();
    final lastRun = _throttleLastRun[key];
    if (lastRun == null || now.difference(lastRun) >= duration) {
      _throttleLastRun[key] = now;
      return await task();
    } else {
      final waitTime = duration - now.difference(lastRun);
      await Future.delayed(waitTime);
      _throttleLastRun[key] = DateTime.now().add(waitTime);
      return await task();
    }
  }

  Future<T> _executeConcurrent<T>(
    String queueKey,
    FutureOr<T> Function() task,
    Concurrent config,
  ) async {
    final queue = _queues.putIfAbsent(
      queueKey,
      () => TaskQueue(maxConcurrent: config.maxConcurrent),
    );

    return await queue.add(task, priority: config.priority);
  }

  Future<T> _debounce<T>(
    String key,
    FutureOr<T> Function() task,
    Duration duration,
  ) {
    if (_debounceTimers.containsKey(key)) {
      _debounceTimers[key]!.cancel();
    }

    final completer = Completer<T>();
    _debounceTimers[key] = Timer(duration, () {
      try {
        final result = task();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }
}
