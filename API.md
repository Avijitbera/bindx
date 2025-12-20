# BindX API Documentation

Complete API reference for the BindX state management library.

## Table of Contents

1. [Core Classes](#core-classes)
2. [Annotations](#annotations)
3. [Widgets](#widgets)
4. [Extensions](#extensions)
5. [Utilities](#utilities)
6. [Middleware](#middleware)

---

## Core Classes

### BindXStore<T>

The foundation of state management in BindX.

```dart
class BindXStore<T> extends ChangeNotifier
```

**Type Parameters:**
- `T`: The type of state this store manages

**Constructors:**

```dart
BindXStore(
  T initialState, {
  CacheEngine? cacheEngine,
  TaskManager? taskManager,
})
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `state` | `T` | Current state value (read-only) |
| `initialState` | `T` | Initial state value (read-only) |
| `stream` | `Stream<T>` | Stream of state changes |

**Methods:**

#### update()

Updates the state.

```dart
Future<void> update(
  FutureOr<T> Function(T current) updater, {
  String? action,
  bool notify = true,
})
```

**Parameters:**
- `updater`: Function that receives current state and returns new state
- `action`: Optional action name for middleware/devtools
- `notify`: Whether to notify listeners (default: true)

**Example:**

```dart
await store.update((current) => current.copyWith(count: current.count + 1));
```

#### cachedGet<R>()

Performs a cached async operation.

```dart
Future<R> cachedGet<R>(
  String key,
  Future<R> Function() compute, {
  Duration? duration,
})
```

**Parameters:**
- `key`: Cache key
- `compute`: Function to compute value if not cached
- `duration`: Cache duration

**Example:**

```dart
final data = await store.cachedGet(
  'user-data',
  () => api.fetchUser(),
  duration: Duration(minutes: 5),
);
```

#### getCached<R>()

Synchronous in-memory cache.

```dart
R getCached<R>(String key, R Function() compute)
```

#### streamOf<R>()

Creates a stream for a specific property.

```dart
Stream<R> streamOf<R>(String propertyName)
```

**Example:**

```dart
final countStream = store.streamOf<int>('count');
```

#### dispose()

Cleans up resources. Always call when done.

```dart
@override
void dispose()
```

---

### BindxRegistry

Global singleton for managing store instances.

```dart
class BindxRegistry
```

**Singleton Access:**

```dart
final bindxRegistry = BindxRegistry();
```

**Methods:**

#### register<T>()

Registers a store.

```dart
T register<T>({
  required T store,
  String? name,
  bool override = false,
})
```

**Example:**

```dart
bindxRegistry.register<UserStore>(
  store: UserStore(),
  name: 'main',
);
```

#### get<T>()

Retrieves a registered store.

```dart
T get<T>({String? name})
```

**Example:**

```dart
final store = bindxRegistry.get<UserStore>(name: 'main');
```

#### exists<T>()

Checks if a store exists.

```dart
bool exists<T>({String? name})
```

#### remove<T>()

Removes and disposes a store.

```dart
void remove<T>({String? name, Type? type})
```

#### watch<T>()

Watches for store changes.

```dart
Stream<T> watch<T>({String? name})
```

**Example:**

```dart
bindxRegistry.watch<UserStore>().listen((store) {
  print('Store updated: ${store.state}');
});
```

#### clear()

Removes all stores.

```dart
void clear()
```

---

## Annotations

### @Cache

Caches method results.

```dart
class Cache {
  final Duration duration;
  final String? key;
  final bool persist;
  final String? tag;
  final CacheStrategy strategy;
}
```

**Usage:**

```dart
@Cache(
  duration: Duration(minutes: 10),
  persist: true,
  tag: 'api-calls',
  strategy: CacheStrategy.memoryFirst,
)
Future<User> fetchUser(String id) async {
  return await api.getUser(id);
}
```

**Strategies:**
- `CacheStrategy.memory`: In-memory only
- `CacheStrategy.disk`: Disk only
- `CacheStrategy.memoryFirst`: Check memory, then disk
- `CacheStrategy.diskFirst`: Check disk, then memory

---

### @Concurrent

Controls concurrent execution.

```dart
class Concurrent {
  final int maxConcurrent;
  final String? queueKey;
  final int priority;
  final bool debounce;
  final Duration debounceDuration;
  final bool throttle;
  final Duration throttleDuration;
}
```

**Usage:**

```dart
@Concurrent(
  maxConcurrent: 1,
  debounce: true,
  debounceDuration: Duration(milliseconds: 500),
)
Future<void> search(String query) async {
  // Only one search at a time, debounced
}
```

---

### @Streamed

Converts properties to streams.

```dart
class Streamed {
  final bool broadcast;
  final String? streamKey;
}
```

**Usage:**

```dart
@Streamed(broadcast: true, streamKey: 'count')
Stream<int> get countStream => streamOf<int>('count');
```

---

### @Validate

Validates input.

```dart
class Validate {
  final List<Validator> validators;
}

enum Validator {
  notEmpty,
  email,
  url,
  minLength,
  maxLength,
  minValue,
  maxValue,
  pattern,
}
```

**Usage:**

```dart
@Validate([Validator.notEmpty, Validator.email])
Future<void> setEmail(String email) async {
  await update((current) => current.copyWith(email: email));
}
```

---

### @Mutex

Provides mutual exclusion.

```dart
class Mutex {
  final String lockKey;
  final Duration timeout;
}
```

**Usage:**

```dart
@Mutex(lockKey: 'critical-section', timeout: Duration(seconds: 5))
Future<void> criticalOperation() async {
  // Only one execution at a time
}
```

---

### @Retry

Automatic retry logic.

```dart
class Retry {
  final int maxAttempts;
  final Duration delay;
  final List<Type> retryOn;
}
```

**Usage:**

```dart
@Retry(
  maxAttempts: 3,
  delay: Duration(seconds: 1),
  retryOn: [NetworkException],
)
Future<Data> fetchData() async {
  // Will retry up to 3 times on NetworkException
}
```

---

### @Timeout

Method timeout.

```dart
class Timeout {
  final Duration duration;
}
```

**Usage:**

```dart
@Timeout(Duration(seconds: 30))
Future<Data> fetchLargeData() async {
  // Will timeout after 30 seconds
}
```

---

## Widgets

### BindXProvider<T>

Provides a store to the widget tree.

```dart
class BindXProvider<T extends BindXStore> extends StatefulWidget
```

**Constructor:**

```dart
BindXProvider({
  required T store,
  required Widget child,
  bool register = true,
  String? name,
})
```

**Static Method:**

```dart
static T of<T extends BindXStore>(
  BuildContext context, {
  String? name,
  bool listen = true,
})
```

**Example:**

```dart
BindXProvider<CounterStore>(
  store: CounterStore(),
  register: true,
  child: MyApp(),
)

// Access in widget
final store = BindXProvider.of<CounterStore>(context);
```

---

### MultiBindXProvider

Provides multiple stores.

```dart
MultiBindXProvider({
  required List<BindXProvider> providers,
  required Widget child,
})
```

**Example:**

```dart
MultiBindXProvider(
  providers: [
    BindXProvider<AuthStore>(store: AuthStore()),
    BindXProvider<UserStore>(store: UserStore()),
  ],
  child: MyApp(),
)
```

---

### BindXConsumer

Rebuilds on store changes.

```dart
class BindXConsumer extends StatelessWidget
```

**Constructor:**

```dart
BindXConsumer({
  required Widget Function(BuildContext) builder,
  List<Type> storeTypes = const [],
})
```

---

### BindXMultiBuilder

Builds from multiple stores.

```dart
BindXMultiBuilder({
  required List<Type> storeTypes,
  required Widget Function(
    BuildContext,
    Map<Type, BindXStore>,
  ) builder,
})
```

**Example:**

```dart
BindXMultiBuilder(
  storeTypes: [AuthStore, UserStore],
  builder: (context, stores) {
    final auth = stores[AuthStore] as AuthStore;
    final user = stores[UserStore] as UserStore;
    return Text('${auth.state.isAuth} - ${user.state.name}');
  },
)
```

---

## Extensions

### Stream Extensions

#### debounce()

Debounces stream emissions.

```dart
Stream<T> debounce(Duration duration)
```

#### throttle()

Throttles stream emissions.

```dart
Stream<T> throttle(Duration duration)
```

#### distinct()

Filters distinct values.

```dart
Stream<T> distinct([bool Function(T previous, T current)? equals])
```

#### switchMap()

Maps to stream, cancelling previous.

```dart
Stream<R> switchMap<R>(Stream<R> Function(T value) mapper)
```

#### mergeMap()

Maps to stream, merging all.

```dart
Stream<R> mergeMap<R>(Stream<R> Function(T value) mapper)
```

#### combineWith()

Combines with another stream.

```dart
Stream<R> combineWith<U, R>(Stream<U> other, R Function(T, U) combiner)
```

[... many more stream operators ...]

---

### Future Extensions

#### timeoutAfter()

Timeout with fallback.

```dart
Future<T> timeoutAfter(
  Duration duration, {
  FutureOr<T> Function()? onTimeout,
})
```

#### asResult()

Converts to Result type (no exceptions).

```dart
Future<Result<T>> asResult()
```

#### asCancellable()

Makes future cancellable.

```dart
CancellableFuture<T> asCancellable()
```

[... many more future extensions ...]

---

## Utilities

### Result<T>

Type-safe result handling.

```dart
class Result<T>
```

**Constructors:**

```dart
Result.success(T value)
Result.failure(Object error, [StackTrace? stackTrace])
```

**Properties:**

- `isSuccess`: `bool`
- `isFailure`: `bool`
- `value`: `T` (throws if failure)
- `error`: `Object` (throws if success)

**Methods:**

```dart
Result<R> map<R>(R Function(T) mapper)
Result<T> mapError(Object Function(Object) mapper)
Result<T> recover(T Function(Object) recovery)
R fold<R>({
  required R Function(T) onSuccess,
  required R Function(Object, StackTrace?) onFailure,
})
T getOrElse(T Function() alternative)
T? getOrNull()
T getOrThrow()
```

---

### CancellableFuture<T>

Cancellable future.

```dart
class CancellableFuture<T>
```

**Constructor:**

```dart
CancellableFuture(Future<T> future)
```

**Properties:**

- `future`: `Future<T>`
- `isCancelled`: `bool`

**Methods:**

```dart
void cancel([Object? cancellationError])
```

---

### CancellationToken

Token for cancelling operations.

```dart
class CancellationToken
```

**Properties:**

- `onCancel`: `Stream<void>`

**Methods:**

```dart
void cancel()
void dispose()
```

---

## Middleware

### Middleware<T>

Base interface for middleware.

```dart
abstract class Middleware<T> {
  Future<T> beforeUpdate(T currentState, T Function(T) updater, String action);
  Future<T> afterUpdate(T newState, T oldState, String action);
}
```

**Usage:**

```dart
class MyMiddleware<T> implements Middleware<T> {
  @override
  Future<T> beforeUpdate(T current, T Function(T) updater, String action) {
    print('Before: $action');
    return Future.value(current);
  }

  @override
  Future<T> afterUpdate(T newState, T oldState, String action) {
    print('After: $action');
    return Future.value(newState);
  }
}
```

---

## Best Practices

1. **Always dispose stores** when done
2. **Use immutable state** objects
3. **Prefer update()** for all state changes
4. **Use annotations** for common patterns
5. **Test stores** independently
6. **Use middleware** for cross-cutting concerns

---

## Examples

See [example/](../example/) directory for complete working examples.

---

## Support

- 📖 [Full Documentation](https://github.com/Avijitbera/bindx)
- 🐛 [Report Issues](https://github.com/Avijitbera/bindx/issues)
- 💬 [Discussions](https://github.com/Avijitbera/bindx/discussions)
