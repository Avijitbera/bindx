import 'package:meta/meta.dart';

@immutable
class Concurrent {
  final int maxConcurrent;
  final String? queueKey;
  final int priority;
  final bool debounce;
  final Duration debounceDuration;
  final bool throttle;
  final Duration throttleDuration;

  const Concurrent({
    required this.maxConcurrent,
    this.queueKey,
    this.priority = 0,
    this.debounce = false,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.throttle = false,
    this.throttleDuration = const Duration(milliseconds: 300),
  });
}

class Mutex {
  final String lockKey;
  final Duration timeout;

  const Mutex({
    required this.lockKey,
    this.timeout = const Duration(seconds: 10),
  });
}

class Retry {
  final int maxAttempts;
  final Duration delay;
  final List<Type> retryOn;

  const Retry({
    this.maxAttempts = 3,
    this.delay = const Duration(seconds: 1),
    this.retryOn = const [Exception],
  });
}

class Timeout {
  final Duration duration;

  const Timeout(this.duration);
}
