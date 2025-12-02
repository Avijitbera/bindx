import 'dart:async';
import 'package:collection/collection.dart';

class TaskQueue {
  final int maxConcurrent;
  final PriorityQueue<_TaskWrapper> _queue = PriorityQueue();
  int _running = 0;

  TaskQueue({this.maxConcurrent = 1});

  Future<T> add<T>(FutureOr<T> Function() task, {int priority = 0}) {
    final completer = Completer<T>();
    _queue.add(
      _TaskWrapper(task: task, priority: priority, completer: completer),
    );

    _processQueue();

    return completer.future;
  }

  void _processQueue() {
    while (_running < maxConcurrent && _queue.isNotEmpty) {
      _running++;
      final wrapper = _queue.removeFirst();
      unawaited(
        Future(() async {
          try {
            final result = await wrapper.task();
            wrapper.completer.complete(result);
          } catch (e) {
            wrapper.completer.completeError(e);
          } finally {
            _running--;
            _processQueue();
          }
        }),
      );
    }
  }
}

class _TaskWrapper implements Comparable<_TaskWrapper> {
  final FutureOr Function() task;
  final int priority;
  final Completer completer;
  final DateTime createdAt = DateTime.now();

  _TaskWrapper({
    required this.task,
    required this.priority,
    required this.completer,
  });

  @override
  int compareTo(_TaskWrapper other) {
    if (priority != other.priority) {
      return other.priority.compareTo(priority);
    }
    return createdAt.compareTo(other.createdAt);
  }
}
