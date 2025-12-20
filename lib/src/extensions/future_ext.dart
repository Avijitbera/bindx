import 'dart:async';

/// Extensions for Future to enhance async operations
extension BindXFutureExtensions<T> on Future<T> {
  /// Times out the future after [duration]
  Future<T> timeoutAfter(
    Duration duration, {
    FutureOr<T> Function()? onTimeout,
  }) {
    return timeout(duration, onTimeout: onTimeout);
  }

  /// Maps the result to a different type
  Future<R> map<R>(R Function(T value) mapper) {
    return then(mapper);
  }

  /// Maps the result to a different type, handling errors
  Future<R> mapOrElse<R>({
    required R Function(T value) mapper,
    required R Function(Object error, StackTrace stackTrace) errorMapper,
  }) {
    return then(mapper).catchError(errorMapper);
  }

  /// Filters the result, throwing if condition not met
  Future<T> filter(
    bool Function(T value) predicate, {
    Object Function()? error,
  }) async {
    final result = await this;
    if (!predicate(result)) {
      throw error?.call() ?? StateError('Filter condition not met');
    }
    return result;
  }

  /// Recovers from error by returning alternative value
  Future<T> recover(T Function(Object error, StackTrace stackTrace) recovery) {
    return catchError(
      (Object error, StackTrace stackTrace) => recovery(error, stackTrace),
    );
  }

  /// Executes side effect without modifying result
  Future<T> tap({
    void Function(T value)? onValue,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onComplete,
  }) async {
    try {
      final value = await this;
      onValue?.call(value);
      onComplete?.call();
      return value;
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      onComplete?.call();
      rethrow;
    }
  }

  /// Combines with another future
  Future<R> combineWith<U, R>(
    Future<U> other,
    R Function(T, U) combiner,
  ) async {
    final results = await Future.wait([this, other]);
    return combiner(results[0] as T, results[1] as U);
  }

  Stream<T> asStream() {
    return Stream.fromFuture(this);
  }

  /// Delays the result by [duration]
  Future<T> delayBy(Duration duration) async {
    await Future.delayed(duration);
    return await this;
  }

  /// Creates a cancellable future
  CancellableFuture<T> asCancellable() {
    return CancellableFuture<T>(this);
  }

  /// Converts to a Result type (success or failure)
  Future<Result<T>> asResult() async {
    try {
      final value = await this;
      return Result.success(value);
    } catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }

  /// Executes [onSuccess] or [onError] based on result
  Future<void> match({
    required void Function(T value) onSuccess,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) async {
    try {
      final value = await this;
      onSuccess(value);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  /// Maps to nullable, catching errors and returning null
  Future<T?> getOrNull() {
    return catchError((_) => null);
  }

  /// Transforms with a mapper that returns a Future
  Future<R> flatMap<R>(Future<R> Function(T value) mapper) {
    return then(mapper);
  }

  /// Validates result with [validator], throwing if invalid
  Future<T> validate(
    bool Function(T value) validator, {
    String message = 'Validation failed',
  }) async {
    final value = await this;
    if (!validator(value)) {
      throw StateError(message);
    }
    return value;
  }
}

class Result<T> {
  final T? _value;
  final Object? _error;
  final StackTrace? _stackTrace;
  final bool _isSuccess;

  Result._(this._value, this._error, this._stackTrace, this._isSuccess);

  factory Result.success(T value) {
    return Result._(value, null, null, true);
  }

  factory Result.failure(Object error, [StackTrace? stackTrace]) {
    return Result._(null, error, stackTrace, false);
  }

  bool get isSuccess => _isSuccess;
  bool get isFailure => !_isSuccess;

  T get value {
    if (_isSuccess) return _value as T;
    throw StateError('Cannot get value from failure result');
  }

  Object get error {
    if (!_isSuccess) return _error!;
    throw StateError('Cannot get error from success result');
  }

  StackTrace? get stackTrace => _stackTrace;

  /// Maps successful value
  Result<R> map<R>(R Function(T value) mapper) {
    if (_isSuccess) {
      try {
        return Result.success(mapper(_value as T));
      } catch (error, stackTrace) {
        return Result.failure(error, stackTrace);
      }
    }
    return Result.failure(_error!, _stackTrace);
  }

  /// Maps error
  Result<T> mapError(Object Function(Object error) mapper) {
    if (!_isSuccess) {
      try {
        return Result.failure(mapper(_error!), _stackTrace);
      } catch (error, stackTrace) {
        return Result.failure(error, stackTrace);
      }
    }
    return this;
  }

  /// Recovers from error
  Result<T> recover(T Function(Object error) recovery) {
    if (!_isSuccess) {
      try {
        return Result.success(recovery(_error!));
      } catch (error, stackTrace) {
        return Result.failure(error, stackTrace);
      }
    }
    return this;
  }

  /// Folds result into a single value
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error, StackTrace? stackTrace) onFailure,
  }) {
    if (_isSuccess) {
      return onSuccess(_value as T);
    }
    return onFailure(_error!, _stackTrace);
  }

  /// Gets value or alternative
  T getOrElse(T Function() alternative) {
    if (_isSuccess) return _value as T;
    return alternative();
  }

  /// Gets value or null
  T? getOrNull() {
    if (_isSuccess) return _value as T;
    return null;
  }

  /// Throws if failure
  T getOrThrow() {
    if (_isSuccess) return _value as T;
    final error = _error!;
    if (_stackTrace != null) {
      Error.throwWithStackTrace(error, _stackTrace);
    }
    throw error;
  }
}

class CancellableFuture<T> {
  final Completer<T> _completer = Completer<T>();
  bool _isCancelled = false;

  CancellableFuture(Future<T> future) {
    future.then(
      (value) {
        if (!_isCancelled && !_completer.isCompleted) {
          _completer.complete(value);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!_isCancelled && !_completer.isCompleted) {
          _completer.completeError(error, stackTrace);
        }
      },
    );
  }

  Future<T> get future => _completer.future;

  void cancel([Object? cancellationError]) {
    if (!_isCancelled && !_completer.isCompleted) {
      _isCancelled = true;
      if (cancellationError != null) {
        _completer.completeError(cancellationError, StackTrace.current);
      } else {
        _completer.completeError(CancellationException(), StackTrace.current);
      }
    }
  }

  bool get isCancelled => _isCancelled;
}

class CancellationException implements Exception {
  final String message = 'Operation was cancelled';
  @override
  String toString() => 'CancellationException: $message';
}

/// Future combinators for multiple futures
extension BindXFutureCombinators<T> on Iterable<Future<T>> {
  /// Waits for all futures to complete
  Future<List<T>> waitAll() => Future.wait(this);

  /// Waits for all futures to complete, preserving order
  Future<List<T>> waitAllInOrder() async {
    final results = <T>[];
    for (final future in this) {
      results.add(await future);
    }
    return results;
  }

  /// Returns the first future that completes
  Future<T> race() => Future.any(this);

  /// Executes futures sequentially
  Future<List<T>> sequence() async {
    final results = <T>[];
    for (final future in this) {
      results.add(await future);
    }
    return results;
  }

  /// Executes futures with limited concurrency
  Future<List<T>> withConcurrency(int maxConcurrent) async {
    final futures = toList();
    if (futures.isEmpty) return [];

    final results = List<T?>.filled(futures.length, null);
    final completer = Completer<List<T>>();
    int nextIndex = 0;
    int completedCount = 0;
    int activeCount = 0;

    void runNext() {
      if (completedCount == futures.length) {
        if (!completer.isCompleted) {
          completer.complete(results.cast<T>());
        }
        return;
      }

      while (activeCount < maxConcurrent && nextIndex < futures.length) {
        final index = nextIndex++;
        activeCount++;
        futures[index].then(
          (value) {
            results[index] = value;
            activeCount--;
            completedCount++;
            runNext();
          },
          onError: (Object e, StackTrace s) {
            if (!completer.isCompleted) {
              completer.completeError(e, s);
            }
          },
        );
      }
    }

    runNext();
    return completer.future;
  }

  /// Maps each future and waits for all
  Future<List<R>> mapAll<R>(Future<R> Function(T value) mapper) async {
    final futures = map((future) => future.then(mapper));
    return await Future.wait(futures);
  }
}

extension BindXFutureUtils<T> on Future<T> {
  /// Creates a future that completes with a default value on timeout
  Future<T> orDefault(
    T defaultValue, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return this.timeout(timeout, onTimeout: () => defaultValue);
  }

  /// Creates a future that never rejects (errors become null)
  Future<T?> safe() {
    return catchError((_) => null);
  }

  /// Creates a future that can be cancelled by a token
  Future<T> withCancellationToken(CancellationToken token) {
    final completer = Completer<T>();

    final subscription = token.onCancel.listen((_) {
      if (!completer.isCompleted) {
        completer.completeError(CancellationException());
      }
    });

    then(
      (value) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    return completer.future;
  }
}

/// Cancellation token for cancelling futures
class CancellationToken {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get onCancel => _controller.stream;

  void cancel() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }
}

class BindXAsync {
  /// Creates a periodic timer that can be cancelled
  static Stream<T> periodic<T>(
    Duration duration,
    T Function(int count) generator, {
    CancellationToken? token,
  }) {
    final controller = StreamController<T>();
    int count = 0;

    final timer = Timer.periodic(duration, (_) {
      if (!controller.isClosed) {
        controller.add(generator(count++));
      }
    });

    token?.onCancel.listen((_) {
      timer.cancel();
      if (!controller.isClosed) {
        controller.close();
      }
    });

    controller.onCancel = () {
      timer.cancel();
    };

    return controller.stream;
  }

  /// Creates a delayed future that can be cancelled
  static Future<void> delayed(Duration duration, {CancellationToken? token}) {
    final completer = Completer<void>();

    final timer = Timer(duration, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    token?.onCancel.listen((_) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(CancellationException());
      }
    });

    return completer.future;
  }

  /// Executes an async function with timeout and retry
  static Future<T> executeWithRetry<T>(
    Future<T> Function() task, {
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
    Duration retryDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    bool Function(Object error)? retryIf,
  }) async {
    for (int i = 0; i <= maxRetries; i++) {
      try {
        return await task().timeout(timeout);
      } catch (error) {
        if (i == maxRetries || (retryIf != null && !retryIf(error))) {
          rethrow;
        }
        final delay = retryDelay * (i == 0 ? 1 : backoffFactor * i);
        await Future.delayed(delay);
      }
    }
    throw StateError('Execution failed after $maxRetries retries');
  }
}
