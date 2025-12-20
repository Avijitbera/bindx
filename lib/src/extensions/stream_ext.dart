import 'dart:async';

/// Extensions for Stream to enhance reactive programming
extension BindXStreamExtensions<T> on Stream<T> {
  Stream<T> distinct([bool Function(T previous, T current)? equals]) {
    equals ??= (a, b) => a == b;
    return transform(_DistinctTransformer(equals));
  }

  Stream<T> debounce(Duration duration) {
    return transform(_DebounceTransformer(duration));
  }

  Stream<T> throttle(Duration duration) {
    return transform(_ThrottleTransformer(duration));
  }

  /// Combines with another stream using a combiner function
  Stream<R> combineWith<U, R>(Stream<U> other, R Function(T, U) combiner) {
    return CombineLatestStream.combine2<T, U, R>(this, other, combiner);
  }

  /// Maps each value to a stream and emits values from the most recent inner stream
  Stream<R> switchMap<R>(Stream<R> Function(T value) mapper) {
    final controller = StreamController<R>();
    StreamSubscription<T>? subscription;
    StreamSubscription<R>? innerSubscription;
    bool isDone = false;

    controller.onListen = () {
      subscription = listen(
        (value) {
          innerSubscription?.cancel();
          innerSubscription = mapper(value).listen(
            (data) => controller.add(data),
            onError: controller.addError,
            onDone: () {
              innerSubscription = null;
              if (isDone) controller.close();
            },
          );
        },
        onError: controller.addError,
        onDone: () {
          isDone = true;
          if (innerSubscription == null) controller.close();
        },
      );
    };

    controller.onCancel = () async {
      await innerSubscription?.cancel();
      await subscription?.cancel();
    };

    return controller.stream;
  }

  /// Maps each value to a stream and merges all streams concurrently
  Stream<R> mergeMap<R>(Stream<R> Function(T value) mapper) {
    final controller = StreamController<R>();
    final subscriptions = <StreamSubscription<R>>[];
    bool isDone = false;

    void checkDone() {
      if (isDone && subscriptions.isEmpty) {
        controller.close();
      }
    }

    StreamSubscription<T>? subscription;
    controller.onListen = () {
      subscription = listen(
        (value) {
          late StreamSubscription<R> innerSub;
          innerSub = mapper(value).listen(
            (data) => controller.add(data),
            onError: controller.addError,
            onDone: () {
              subscriptions.remove(innerSub);
              checkDone();
            },
          );
          subscriptions.add(innerSub);
        },
        onError: controller.addError,
        onDone: () {
          isDone = true;
          checkDone();
        },
      );
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await Future.wait(subscriptions.map((s) => s.cancel()));
    };

    return controller.stream;
  }

  Stream<List<T>> bufferTime(Duration duration) {
    return transform(_BufferTimeTransformer(duration));
  }

  Stream<T> sampleTime(Duration duration) {
    return transform(_SampleTimeTransformer(duration));
  }

  Stream<T> skipWhileInclusive(bool Function(T value) predicate) {
    return transform(_SkipWhileInclusiveTransformer(predicate));
  }

  Stream<T> takeWhileInclusive(bool Function(T value) predicate) {
    return transform(_TakeWhileInclusiveTransformer(predicate));
  }

  /// Caches the latest value and replays it to new subscribers
  Stream<T> cacheLatest() {
    T? latestValue;
    bool hasValue = false;
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>.broadcast(
      onListen: () {
        if (hasValue) {
          controller?.add(latestValue as T);
        }
        subscription ??= listen(
          (data) {
            latestValue = data;
            hasValue = true;
            controller?.add(data);
          },
          onError: controller?.addError,
          onDone: controller?.close,
        );
      },
      onCancel: () {
        // We keep the subscription alive for other broadcast listeners
      },
    );

    return controller.stream;
  }

  /// Retries the stream on error with exponential backoff
  Stream<T> retryWithBackoff({
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 100),
    double factor = 2.0,
  }) {
    return transform(
      _RetryWithBackoffTransformer(
        maxRetries: maxRetries,
        initialDelay: initialDelay,
        factor: factor,
      ),
    );
  }

  /// Executes [action] for each value without modifying the stream
  Stream<T> tap(void Function(T value) action) {
    return transform(_TapTransformer(action));
  }

  /// Creates a stream that only emits when value is not null
  Stream<T> whereNotNull() {
    return where((value) => value != null);
  }

  /// Maps to a different type, handling null values
  Stream<R> mapNotNull<R>(R? Function(T value) mapper) {
    return map(mapper).where((v) => v != null).cast<R>();
  }

  /// Reduces the stream to a single value using [combine]
  Future<T> reduceWith(T Function(T previous, T current) combine) async {
    return await reduce(combine);
  }

  /// Groups values by [key] and emits groups as maps
  Stream<Map<K, List<T>>> groupBy<K>(K Function(T value) key) {
    return transform(_GroupByTransformer(key));
  }

  /// Creates a stream that shares a single subscription and replays latest values
  Stream<T> shareReplay({int bufferSize = 1}) {
    final buffer = <T>[];
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>.broadcast(
      onListen: () {
        for (final value in buffer) {
          controller?.add(value);
        }
        subscription ??= listen(
          (data) {
            buffer.add(data);
            if (buffer.length > bufferSize) {
              buffer.removeAt(0);
            }
            controller?.add(data);
          },
          onError: controller?.addError,
          onDone: controller?.close,
        );
      },
    );

    return controller.stream;
  }
}

/// Additional stream utilities
extension BindXStreamUtils<T> on Stream<T> {
  /// Converts stream to a Future that completes with the first value
  Future<T> get firstValue => first;

  /// Converts stream to a Future that completes with the last value
  Future<T> get lastValue => last;

  /// Checks if stream contains a value matching [predicate]
  Future<bool> containsWhere(bool Function(T value) predicate) async {
    await for (final value in this) {
      if (predicate(value)) return true;
    }
    return false;
  }

  /// Returns the first value matching [predicate]
  Future<T?> firstWhereOrNull(bool Function(T value) predicate) async {
    await for (final value in this) {
      if (predicate(value)) return value;
    }
    return null;
  }

  Future<List<T>> toListAsync() async {
    final result = <T>[];
    await for (final value in this) {
      result.add(value);
    }
    return result;
  }

  /// Collects values into a map using [key] and [value] selectors
  Future<Map<K, V>> toMap<K, V>(
    K Function(T value) key,
    V Function(T value) value,
  ) async {
    final result = <K, V>{};
    await for (final item in this) {
      result[key(item)] = value(item);
    }
    return result;
  }

  /// Executes [action] for each value and returns a Future that completes when done
  Future<void> forEachAsync(FutureOr<void> Function(T value) action) async {
    await for (final value in this) {
      await action(value);
    }
  }
}

/// Stream combinators for multiple streams
extension BindXStreamCombinators<T> on Iterable<Stream<T>> {
  /// Merges multiple streams into one
  Stream<T> merge() {
    final controller = StreamController<T>();
    final subscriptions = <StreamSubscription<T>>[];
    var completedCount = 0;
    final streams = toList();

    if (streams.isEmpty) {
      return Stream.empty();
    }

    controller.onListen = () {
      for (final stream in streams) {
        subscriptions.add(
          stream.listen(
            (data) => controller.add(data),
            onError: controller.addError,
            onDone: () {
              completedCount++;
              if (completedCount == streams.length) {
                controller.close();
              }
            },
          ),
        );
      }
    };

    controller.onCancel = () async {
      await Future.wait(subscriptions.map((s) => s.cancel()));
    };

    return controller.stream;
  }

  /// Concatenates streams in sequence
  Stream<T> concat() {
    return Stream.fromIterable(this).asyncExpand((stream) => stream);
  }

  /// Combines latest values from all streams
  Stream<List<T>> combineLatest() {
    return CombineLatestStream.list<T>(this);
  }

  /// Emits values from the first stream that emits
  Stream<T> race() {
    final controller = StreamController<T>();
    final subscriptions = <StreamSubscription<T>>[];
    bool hasWinner = false;
    final streams = toList();

    if (streams.isEmpty) {
      return Stream.empty();
    }

    controller.onListen = () {
      for (final stream in streams) {
        late StreamSubscription<T> sub;
        sub = stream.listen(
          (value) {
            if (!hasWinner) {
              hasWinner = true;
              controller.add(value);
              for (final s in subscriptions) {
                if (s != sub) s.cancel();
              }
            }
          },
          onError: (e, s) {
            if (!hasWinner) {
              controller.addError(e, s);
            }
          },
          onDone: () {
            if (!hasWinner && subscriptions.every((s) => s == sub || false)) {
              controller.close();
            }
          },
        );
        subscriptions.add(sub);
      }
    };

    controller.onCancel = () async {
      await Future.wait(subscriptions.map((s) => s.cancel()));
    };

    return controller.stream;
  }
}

class _TapTransformer<T> extends StreamTransformerBase<T, T> {
  final void Function(T value) action;
  _TapTransformer(this.action);

  @override
  Stream<T> bind(Stream<T> stream) {
    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (value, sink) {
          action(value);
          sink.add(value);
        },
      ),
    );
  }
}

class _GroupByTransformer<T, K>
    extends StreamTransformerBase<T, Map<K, List<T>>> {
  final K Function(T value) keySelector;
  _GroupByTransformer(this.keySelector);

  @override
  Stream<Map<K, List<T>>> bind(Stream<T> stream) {
    final Map<K, List<T>> groups = {};
    return stream.transform(
      StreamTransformer<T, Map<K, List<T>>>.fromHandlers(
        handleData: (data, sink) {
          final key = keySelector(data);
          groups.putIfAbsent(key, () => []).add(data);
          sink.add(Map<K, List<T>>.from(groups));
        },
        handleDone: (sink) {
          sink.close();
        },
      ),
    );
  }
}

class _RetryWithBackoffTransformer<T> extends StreamTransformerBase<T, T> {
  final int maxRetries;
  final Duration initialDelay;
  final double factor;

  _RetryWithBackoffTransformer({
    required this.maxRetries,
    required this.initialDelay,
    required this.factor,
  });

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T>? controller;
    int retryCount = 0;
    StreamSubscription<T>? subscription;

    void subscribe() {
      subscription?.cancel();
      subscription = stream.listen(
        (data) {
          controller?.add(data);
          retryCount = 0;
        },
        onError: (error, stackTrace) {
          if (retryCount < maxRetries) {
            retryCount++;
            final delay = Duration(
              milliseconds:
                  (initialDelay.inMilliseconds * (factor * retryCount)).toInt(),
            );
            Future.delayed(delay, subscribe);
          } else {
            controller?.addError(error, stackTrace);
          }
        },
        onDone: () {
          controller?.close();
        },
      );
    }

    controller = StreamController<T>(
      onListen: subscribe,
      onCancel: () => subscription?.cancel(),
      sync: true,
    );
    return controller.stream;
  }
}

class _SampleTimeTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  _SampleTimeTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    final controller = StreamController<T>();
    StreamSubscription<T>? subscription;
    Timer? timer;
    T? latestValue;
    bool hasValue = false;

    void onTick(Timer t) {
      if (hasValue) {
        controller.add(latestValue as T);
        hasValue = false;
      }
    }

    controller.onListen = () {
      subscription = stream.listen(
        (value) {
          latestValue = value;
          hasValue = true;
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          controller.close();
        },
      );
      timer = Timer.periodic(duration, onTick);
    };

    controller.onCancel = () {
      subscription?.cancel();
      timer?.cancel();
    };

    return controller.stream;
  }
}

class _BufferTimeTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final Duration duration;
  _BufferTimeTransformer(this.duration);

  @override
  Stream<List<T>> bind(Stream<T> stream) {
    final controller = StreamController<List<T>>();
    final buffer = <T>[];
    Timer? timer;
    StreamSubscription<T>? subscription;

    void emit() {
      if (buffer.isNotEmpty) {
        controller.add(List<T>.from(buffer));
        buffer.clear();
      }
    }

    controller.onListen = () {
      subscription = stream.listen(
        (data) => buffer.add(data),
        onError: controller.addError,
        onDone: () {
          emit();
          timer?.cancel();
          controller.close();
        },
      );
      timer = Timer.periodic(duration, (_) => emit());
    };

    controller.onCancel = () {
      subscription?.cancel();
      timer?.cancel();
    };

    return controller.stream;
  }
}

class _DebounceTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  _DebounceTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    Timer? timer;
    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (value, sink) {
          timer?.cancel();
          timer = Timer(duration, () {
            sink.add(value);
          });
        },
        handleDone: (sink) {
          timer?.cancel();
          sink.close();
        },
      ),
    );
  }
}

class _ThrottleTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  _ThrottleTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    DateTime? lastEmit;
    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (value, sink) {
          final now = DateTime.now();
          if (lastEmit == null || now.difference(lastEmit!) >= duration) {
            lastEmit = now;
            sink.add(value);
          }
        },
        handleDone: (sink) {
          lastEmit = null;
          sink.close();
        },
      ),
    );
  }
}

class _DistinctTransformer<T> extends StreamTransformerBase<T, T> {
  final bool Function(T previous, T current) equals;
  _DistinctTransformer(this.equals);

  @override
  Stream<T> bind(Stream<T> stream) {
    T? previousValue;
    bool hasPrevious = false;

    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (value, sink) {
          if (!hasPrevious || !equals(previousValue as T, value)) {
            previousValue = value;
            hasPrevious = true;
            sink.add(value);
          }
        },
        handleDone: (sink) {
          previousValue = null;
          sink.close();
        },
      ),
    );
  }
}

class _SkipWhileInclusiveTransformer<T> extends StreamTransformerBase<T, T> {
  final bool Function(T value) predicate;
  _SkipWhileInclusiveTransformer(this.predicate);

  @override
  Stream<T> bind(Stream<T> stream) {
    bool skipping = true;
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          if (skipping) {
            if (!predicate(data)) {
              skipping = false;
              sink.add(data);
            }
          } else {
            sink.add(data);
          }
        },
      ),
    );
  }
}

class _TakeWhileInclusiveTransformer<T> extends StreamTransformerBase<T, T> {
  final bool Function(T value) predicate;
  _TakeWhileInclusiveTransformer(this.predicate);

  @override
  Stream<T> bind(Stream<T> stream) {
    bool done = false;
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          if (done) return;
          sink.add(data);
          if (!predicate(data)) {
            done = true;
          }
        },
      ),
    );
  }
}

class CombineLatestStream {
  static Stream<R> combine2<A, B, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    R Function(A, B) combiner,
  ) {
    final controller = StreamController<R>(sync: true);
    StreamSubscription<A>? subscriptionA;
    StreamSubscription<B>? subscriptionB;
    A? valueA;
    B? valueB;
    bool hasValueA = false;
    bool hasValueB = false;
    bool isDoneA = false;
    bool isDoneB = false;

    void update() {
      if (hasValueA && hasValueB) {
        try {
          controller.add(combiner(valueA as A, valueB as B));
        } catch (e, s) {
          controller.addError(e, s);
        }
      }
    }

    void onDone() {
      if (isDoneA && isDoneB) {
        controller.close();
      }
    }

    controller.onListen = () {
      subscriptionA = streamA.listen(
        (data) {
          valueA = data;
          hasValueA = true;
          update();
        },
        onError: controller.addError,
        onDone: () {
          isDoneA = true;
          onDone();
        },
      );
      subscriptionB = streamB.listen(
        (data) {
          valueB = data;
          hasValueB = true;
          update();
        },
        onError: controller.addError,
        onDone: () {
          isDoneB = true;
          onDone();
        },
      );
    };

    controller.onCancel = () async {
      await Future.wait([
        subscriptionA?.cancel() ?? Future.value(),
        subscriptionB?.cancel() ?? Future.value(),
      ]);
    };

    return controller.stream;
  }

  static Stream<List<T>> list<T>(Iterable<Stream<T>> streams) {
    final controller = StreamController<List<T>>(sync: true);
    final subscriptions = <StreamSubscription<T>>[];
    final streamsList = streams.toList();
    final values = List<T?>.filled(streamsList.length, null);
    final hasValue = List<bool>.filled(streamsList.length, false);
    final isDone = List<bool>.filled(streamsList.length, false);

    void update() {
      if (hasValue.every((v) => v)) {
        try {
          controller.add(List<T>.from(values.whereType<T>()));
        } catch (e, s) {
          controller.addError(e, s);
        }
      }
    }

    void onDone() {
      if (isDone.every((v) => v)) {
        controller.close();
      }
    }

    controller.onListen = () {
      if (streamsList.isEmpty) {
        controller.add([]);
        controller.close();
        return;
      }

      for (var i = 0; i < streamsList.length; i++) {
        final index = i;
        subscriptions.add(
          streamsList[index].listen(
            (data) {
              values[index] = data;
              hasValue[index] = true;
              update();
            },
            onError: controller.addError,
            onDone: () {
              isDone[index] = true;
              onDone();
            },
          ),
        );
      }
    };

    controller.onCancel = () async {
      await Future.wait(subscriptions.map((s) => s.cancel()));
    };

    return controller.stream;
  }
}
