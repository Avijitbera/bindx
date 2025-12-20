# BindX

**BindX** is a powerful, annotation-based state management library for Flutter that brings reactive programming and advanced async features to your applications with minimal boilerplate.

[![pub package](https://img.shields.io/pub/v/bindx.svg)](https://pub.dev/packages/bindx)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🚀 Features

- **📦 Reactive State Management**: Built on top of `ChangeNotifier` with Stream support
- **🎯 Annotation-based**: Use simple annotations for caching, validation, streaming, and concurrency
- **⚡ Advanced Async**: Built-in retry, timeout, debounce, throttle, and cancellation support
- **🔄 Stream Extensions**: Rich set of RxDart-like stream operators
- **🎨 Widget Integration**: Provider-style widgets for easy integration
- **🛠️ Developer Tools**: Built-in debugging overlay and DevTools integration
- **💾 Persistence**: Automatic state persistence with middleware
- **🔒 Thread-safe**: Mutex locks and concurrent execution control
- **📊 Registry System**: Global store registry for dependency injection

## 📦 Installation

Add BindX to your `pubspec.yaml`:

```yaml
dependencies:
  bindx: ^0.0.1

dev_dependencies:
  build_runner: ^2.4.0
  source_gen: ^1.5.0
```

Then run:

```bash
flutter pub get
```

## 🎯 Quick Start

### 1. Create a Store

```dart
import 'package:bindx/bindx.dart';

class CounterState {
  final int count;
  final bool isLoading;

  CounterState({this.count = 0, this.isLoading = false});

  CounterState copyWith({int? count, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CounterStore extends BindXStore<CounterState> {
  CounterStore() : super(CounterState());

  Future<void> increment() async {
    await update((current) => current.copyWith(count: current.count + 1));
  }

  @Cache(duration: Duration(minutes: 5))
  Future<int> getExpensiveData() async {
    // This result will be cached for 5 minutes
    await Future.delayed(Duration(seconds: 2));
    return state.count * 2;
  }
}
```

### 2. Provide the Store

```dart
void main() {
  runApp(
    BindXProvider<CounterStore>(
      store: CounterStore(),
      child: MyApp(),
    ),
  );
}
```

### 3. Consume the Store

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = BindXProvider.of<CounterStore>(context);

    return Column(
      children: [
        Text('Count: ${store.state.count}'),
        ElevatedButton(
          onPressed: () => store.increment(),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

## 📚 Core Concepts

### BindXStore

The foundation of BindX. Extend `BindXStore<T>` to create your state container:

```dart
class TodoStore extends BindXStore<List<Todo>> {
  TodoStore() : super([]);

  Future<void> addTodo(String title) async {
    await update((current) => [...current, Todo(title: title)]);
  }

  Future<void> removeTodo(String id) async {
    await update((current) => current.where((t) => t.id != id).toList());
  }
}
```

**Key Features:**
- Automatic change notification
- Built-in stream of state changes
- Async state updates with `update()` method
- Caching and computed values support

### Annotations

BindX provides powerful annotations for common patterns:

#### @Cache

Cache expensive computations or API calls:

```dart
@Cache(
  duration: Duration(minutes: 10),
  persist: true, // Persist to disk
  tag: 'user-data', // Tag for cache invalidation
)
Future<UserData> fetchUserData(String userId) async {
  return await api.getUser(userId);
}
```

**Options:**
- `duration`: How long to cache (required)
- `persist`: Save to disk storage
- `tag`: Group related caches
- `strategy`: `memory`, `disk`, `memoryFirst`, `diskFirst`

#### @Concurrent

Control concurrent execution of methods:

```dart
@Concurrent(
  maxConcurrent: 1, // Only one execution at a time
  debounce: true,
  debounceDuration: Duration(milliseconds: 300),
)
Future<void> search(String query) async {
  await performSearch(query);
}
```

**Options:**
- `maxConcurrent`: Maximum simultaneous executions
- `queueKey`: Group related operations
- `priority`: Execution priority
- `debounce`: Debounce rapid calls
- `throttle`: Throttle executions

#### @Streamed

Create reactive streams from properties:

```dart
@Streamed(broadcast: true)
Stream<int> get countStream => streamOf<int>('count');
```

#### @Validate

Validate state updates:

```dart
@Validate([
  Validator.notEmpty,
  Validator.email,
])
Future<void> setEmail(String email) async {
  await update((current) => current.copyWith(email: email));
}
```

### Stream Extensions

BindX includes powerful stream operators:

```dart
// Debounce
searchStream.debounce(Duration(milliseconds: 300));

// Throttle
clickStream.throttle(Duration(seconds: 1));

// SwitchMap (cancel previous)
queryStream.switchMap((query) => searchApi(query));

// MergeMap (run concurrently)
itemStream.mergeMap((item) => processItem(item));

// Combine streams
stream1.combineWith(stream2, (a, b) => a + b);

// Cache latest value
dataStream.cacheLatest();

// Retry with backoff
apiStream.retryWithBackoff(maxRetries: 3);

// Group by key
itemStream.groupBy((item) => item.category);
```

### Future Extensions

Enhanced async operations:

```dart
// Timeout with fallback
future.timeoutAfter(
  Duration(seconds: 5),
  onTimeout: () => defaultValue,
);

// Result type (no exceptions)
final result = await future.asResult();
if (result.isSuccess) {
  print(result.value);
} else {
  print(result.error);
}

// Tap for side effects
await future.tap(
  onValue: (value) => print('Got: $value'),
  onError: (error, stack) => logError(error),
);

// Cancellable
final cancellable = future.asCancellable();
cancellable.cancel(); // Cancel if needed

// Retry with backoff
await BindXAsync.executeWithRetry(
  () => apiCall(),
  maxRetries: 3,
  timeout: Duration(seconds: 30),
);
```

## 🧩 Widgets

### BindXProvider

Provide a store to the widget tree:

```dart
BindXProvider<MyStore>(
  store: MyStore(),
  register: true, // Auto-register in global registry
  name: 'main-store', // Optional name
  child: MyApp(),
)
```

### MultiBindXProvider

Provide multiple stores:

```dart
MultiBindXProvider(
  providers: [
    BindXProvider<AuthStore>(store: AuthStore()),
    BindXProvider<UserStore>(store: UserStore()),
    BindXProvider<SettingsStore>(store: SettingsStore()),
  ],
  child: MyApp(),
)
```

### BindXConsumer

Rebuild on store changes:

```dart
BindXConsumer(
  storeTypes: [CounterStore],
  builder: (context) {
    final store = BindXProvider.of<CounterStore>(context);
    return Text('${store.state.count}');
  },
)
```

### BindXMultiBuilder

Build from multiple stores:

```dart
BindXMultiBuilder(
  storeTypes: [AuthStore, UserStore],
  builder: (context, stores) {
    final authStore = stores[AuthStore] as BindXStore<AuthState>;
    final userStore = stores[UserStore] as BindXStore<UserState>;
    
    return Column(
      children: [
        Text('Authenticated: ${authStore.state.isAuthenticated}'),
        Text('User: ${userStore.state.name}'),
      ],
    );
  },
)
```

## 🔧 Advanced Features

### Registry

Global store management:

```dart
// Register
bindxRegistry.register<MyStore>(store: MyStore(), name: 'main');

// Get
final store = bindxRegistry.get<MyStore>(name: 'main');

// Check existence
if (bindxRegistry.exists<MyStore>()) {
  // ...
}

// Watch for changes
bindxRegistry.watch<MyStore>().listen((store) {
  print('Store updated');
});

// Remove
bindxRegistry.remove<MyStore>(name: 'main');

// Clear all
bindxRegistry.clear();
```

### Middleware

Intercept and modify state updates:

```dart
class LoggingMiddleware<T> implements Middleware<T> {
  @override
  Future<T> beforeUpdate(T currentState, T Function(T) updater, String action) async {
    print('Before: $action');
    return currentState;
  }

  @override
  Future<T> afterUpdate(T newState, T oldState, String action) async {
    print('After: $action, New: $newState');
    return newState;
  }
}

// Apply middleware
class MyStore extends BindXStore<MyState> with BindXMixin<MyState> {
  MyStore() : super(MyState()) {
    addMiddleware(LoggingMiddleware<MyState>());
  }
}
```

### Persistence

Auto-save state to disk:

```dart
class PersistentStore extends BindXStore<AppState> with BindXMixin<AppState> {
  PersistentStore() : super(AppState()) {
    addMiddleware(PersistenceMiddleware<AppState>(
      key: 'app-state',
      fromJson: (json) => AppState.fromJson(json),
      toJson: (state) => state.toJson(),
    ));
  }
}
```

### DevTools

Debug overlay for development:

```dart
void main() {
  BindXDevTools.enable(); // Enable dev tools
  
  runApp(
    BindXDevToolsOverlay(
      child: MyApp(),
    ),
  );
}
```

**Features:**
- View all registered stores
- Inspect current state
- View state history
- Time-travel debugging
- Performance monitoring

## 📖 Examples

### Todo App

```dart
class TodoState {
  final List<Todo> todos;
  final bool isLoading;

  TodoState({this.todos = const [], this.isLoading = false});

  TodoState copyWith({List<Todo>? todos, bool? isLoading}) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TodoStore extends BindXStore<TodoState> {
  TodoStore() : super(TodoState());

  @Concurrent(maxConcurrent: 1)
  Future<void> fetchTodos() async {
    await update((current) => current.copyWith(isLoading: true));
    
    final todos = await api.getTodos();
    
    await update((current) => current.copyWith(
      todos: todos,
      isLoading: false,
    ));
  }

  Future<void> addTodo(String title) async {
    final newTodo = Todo(id: uuid(), title: title);
    await update((current) => current.copyWith(
      todos: [...current.todos, newTodo],
    ));
  }

  Future<void> toggleTodo(String id) async {
    await update((current) => current.copyWith(
      todos: current.todos.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(completed: !todo.completed);
        }
        return todo;
      }).toList(),
    ));
  }

  @Cache(duration: Duration(seconds: 30))
  Future<int> getCompletedCount() async {
    return state.todos.where((t) => t.completed).length;
  }
}
```

### Search with Debounce

```dart
class SearchStore extends BindXStore<SearchState> {
  final StreamController<String> _searchController = StreamController();

  SearchStore() : super(SearchState()) {
    _searchController.stream
      .debounce(Duration(milliseconds: 300))
      .distinct()
      .switchMap((query) => _performSearch(query))
      .listen((results) {
        update((current) => current.copyWith(results: results));
      });
  }

  void search(String query) {
    _searchController.add(query);
  }

  Stream<List<SearchResult>> _performSearch(String query) async* {
    yield await api.search(query);
  }

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }
}
```

## 🎨 Best Practices

1. **Single Responsibility**: Each store should manage a specific domain
2. **Immutable State**: Always use immutable state objects with `copyWith`
3. **Async Updates**: Use `update()` for all state modifications
4. **Dispose Resources**: Override `dispose()` to clean up subscriptions
5. **Use Annotations**: Leverage annotations for common patterns
6. **middleware for Cross-cutting**: Use middleware for logging, persistence, etc.
7. **Testing**: Stores are easy to test - just create instance and call methods

## 🧪 Testing

```dart
void main() {
  test('Counter increment', () async {
    final store = CounterStore();
    
    await store.increment();
    
    expect(store.state.count, 1);
    
    store.dispose();
  });

  test('Counter stream', () async {
    final store = CounterStore();
    
    expectLater(
      store.stream.map((s) => s.count),
      emitsInOrder([1, 2, 3]),
    );
    
    await store.increment();
    await store.increment();
    await store.increment();
    
    store.dispose();
  });
}
```

## 📊 Performance

- **Lazy Evaluation**: Streams and computed values are lazy
- **Efficient Updates**: Only notifies when state actually changes
- **Caching**: Built-in caching reduces redundant computations
- **Concurrency Control**: Prevents unnecessary duplicate operations
- **Memory Management**: Automatic cleanup with `dispose()`

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by MobX, Redux, and RxDart
- Built with ❤️ for the Flutter community

## 📞 Support

- 📧 Email: support@bindx.dev
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/bindx/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/bindx/discussions)
- 📖 Documentation: [bindx.dev](https://bindx.dev)

---

Made with ❤️ by [Your Name]
