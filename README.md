# StateGen - Advanced State Management Code Generator for Flutter

StateGen is a powerful code generation library for Flutter that provides advanced state management capabilities including caching, concurrency control, streaming, and validation through annotations.

## Features

- **🔄 Caching**: Automatic caching of getters and computed values with configurable strategies (memory, disk, hybrid)
- **⚡ Concurrency Control**: Manage concurrent operations with debouncing, throttling, and task queuing
- **📡 Reactive Streams**: Generate reactive streams from properties automatically
- **✅ Validation**: Built-in validation system with multiple validators
- **🔒 Mutex Support**: Thread-safe method execution with mutex locks
- **🔁 Retry Logic**: Automatic retry mechanisms for failed operations
- **⏱️ Timeout Handling**: Configurable timeouts for async operations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stategen: ^0.0.1

dev_dependencies:
  build_runner: ^2.4.0
```

## Usage

### 1. Basic Setup

Annotate your model classes with `@Cache` to enable code generation:

```dart
import 'package:stategen/annotations.dart';

@Cache(duration: Duration(minutes: 5))
class UserStore {
  final String name;
  final int age;
  
  UserStore({required this.name, required this.age});
  
  @Cache(key: 'fullName', duration: Duration(minutes: 10))
  String get fullName => '$name (Age: $age)';
  
  @Concurrent(maxConcurrent: 3, debounce: true)
  Future<void> updateProfile() async {
    // Update logic
  }
  
  @Streamed(broadcast: true)
  String status = 'active';
  
  @Validate([Validator.notEmpty, Validator.email])
  String email = '';
  
  @Retry(maxAttempts: 3, delay: Duration(seconds: 1))
  Future<void> fetchData() async {
    // Fetch logic
  }
  
  @Mutex(lockKey: 'userUpdate')
  Future<void> criticalUpdate() async {
    // Critical section
  }
  
  @Timeout(Duration(seconds: 30))
  Future<void> longRunningTask() async {
    // Long task
  }
}
```

### 2. Run Code Generation

```bash
flutter pub run build_runner build
```

Or for watch mode:

```bash
flutter pub run build_runner watch
```

This will generate a `user_store.bindx.dart` file with extension methods.

### 3. Use Generated Code

```dart
import 'user_store.dart';
import 'user_store.bindx.dart';

void main() async {
  final store = UserStore(name: 'John', age: 30);
  
  // Use cached getter
  final cachedName = store.fullNameCached;
  
  // Use concurrent method
  await store.updateProfileConcurrent();
  
  // Subscribe to stream
  store.statusStream.listen((status) {
    print('Status changed: $status');
  });
  
  // Use validated setter
  store.setEmailValidated('john@example.com');
  
  // Use retry wrapper
  await store.fetchDataWithRetry();
  
  // Use mutex-protected method
  await store.criticalUpdateLocked();
  
  // Use timeout wrapper
  await store.longRunningTaskWithTimeout();
}
```

## Annotations

### @Cache

Enables caching for fields and methods.

```dart
@Cache({
  Duration duration,        // Cache duration (default: 5 minutes)
  String? key,             // Custom cache key
  bool persist,            // Persist to disk (default: false)
  String? tag,             // Cache tag for bulk invalidation
  CacheStrategy strategy,  // memory, disk, memoryFirst, diskFirst
})
```

### @Concurrent

Controls concurrent execution of methods.

```dart
@Concurrent({
  int maxConcurrent,           // Max concurrent executions (default: 1)
  String? queueKey,            // Queue identifier
  int priority,                // Task priority (default: 0)
  bool debounce,               // Enable debouncing (default: false)
  Duration debounceDuration,   // Debounce duration (default: 300ms)
  bool throttle,               // Enable throttling (default: false)
  Duration throttleDuration,   // Throttle duration (default: 300ms)
})
```

### @Streamed

Generates reactive streams from properties.

```dart
@Streamed({
  bool broadcast,    // Broadcast stream (default: true)
  String? streamKey, // Custom stream key
})
```

### @Validate

Adds validation to setters.

```dart
@Validate(List<Validator> validators)

// Available validators:
// - Validator.notEmpty
// - Validator.email
// - Validator.url
// - Validator.minLength
// - Validator.maxLength
// - Validator.minValue
// - Validator.maxValue
// - Validator.pattern
```

### @Retry

Adds retry logic to methods.

```dart
@Retry({
  int maxAttempts,           // Max retry attempts (default: 3)
  Duration delay,            // Delay between retries (default: 1s)
  List<Type> retryOn,        // Exception types to retry on
})
```

### @Mutex

Protects methods with mutex locks.

```dart
@Mutex({
  String lockKey,            // Lock identifier
  Duration timeout,          // Lock timeout (default: 10s)
})
```

### @Timeout

Adds timeout to async methods.

```dart
@Timeout(Duration duration)  // Timeout duration
```

## Architecture

### Core Components

1. **BindXStore**: Base class for state management with built-in caching and concurrency support
2. **CacheEngine**: Multi-strategy caching system (memory/disk)
3. **TaskManager**: Concurrent task execution with queuing, debouncing, and throttling
4. **BindxGenerator**: Code generator that creates extension methods

### Generated Code

For each annotated class, the generator creates:

- **Cached Getters**: `{fieldName}Cached` - Returns cached value
- **Concurrent Methods**: `{methodName}Concurrent` - Executes with concurrency control
- **Streams**: `{fieldName}Stream` - Reactive stream of property changes
- **Validated Setters**: `set{FieldName}Validated` - Setter with validation
- **Retry Wrappers**: `{methodName}WithRetry` - Method with retry logic
- **Mutex Wrappers**: `{methodName}Locked` - Mutex-protected execution
- **Timeout Wrappers**: `{methodName}WithTimeout` - Method with timeout

## Advanced Usage

### Custom Cache Strategy

```dart
@Cache(
  duration: Duration(hours: 1),
  strategy: CacheStrategy.memoryFirst,
  persist: true,
  tag: 'user_data',
)
class UserCache {
  // Your code
}
```

### Concurrent Task Queue

```dart
@Concurrent(
  maxConcurrent: 5,
  queueKey: 'api_calls',
  priority: 10,
  throttle: true,
  throttleDuration: Duration(seconds: 1),
)
Future<void> apiCall() async {
  // API logic
}
```

### Combined Annotations

```dart
@Cache(duration: Duration(minutes: 5))
@Concurrent(maxConcurrent: 1, debounce: true)
@Retry(maxAttempts: 3)
@Timeout(Duration(seconds: 30))
Future<Data> fetchAndCacheData() async {
  // Complex operation
}
```

## Best Practices

1. **Use appropriate cache durations** based on data volatility
2. **Set maxConcurrent** limits to prevent resource exhaustion
3. **Use debouncing** for user-triggered events
4. **Use throttling** for rate-limited APIs
5. **Tag related cache entries** for bulk invalidation
6. **Use mutex** for critical sections only
7. **Set reasonable timeouts** for network operations

## Examples

See the `/example` folder for complete examples:

- Basic state management
- API integration with caching
- Form validation
- Concurrent data processing
- Real-time updates with streams

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests, please use the GitHub issue tracker.
