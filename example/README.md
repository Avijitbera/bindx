# StateGen Example App

A comprehensive example application demonstrating all features of the **StateGen** package - an advanced state management code generator for Flutter.

## 🎯 What This Example Demonstrates

This example app showcases the following StateGen features:

### 1. **Caching** 🔄
- Memory caching with configurable duration
- Disk persistence for cached data
- Multiple cache strategies (memory, disk, memoryFirst, diskFirst)
- Tagged caching for bulk invalidation

### 2. **Reactive Streams** 📡
- Automatic stream generation from properties
- Broadcast streams for multiple listeners
- Real-time UI updates

### 3. **Validation** ✅
- Multiple validators (notEmpty, email, url, minLength, maxLength, minValue, maxValue)
- Real-time form validation
- Custom validation rules

### 4. **Concurrency Control** ⚡
- Debouncing to prevent rapid successive calls
- Throttling for rate-limited operations
- Task queuing with priority support
- Maximum concurrent execution limits

### 5. **Retry Logic** 🔁
- Automatic retry for failed operations
- Configurable retry attempts and delays
- Specific exception handling

### 6. **Mutex Support** 🔒
- Thread-safe method execution
- Lock-based critical sections
- Configurable timeouts

### 7. **Timeout Handling** ⏱️
- Configurable timeouts for async operations
- Automatic timeout exceptions

## 📱 Demo Screens

### 1. User Store Demo
Demonstrates:
- Cached getters with different strategies
- Concurrent operations with debouncing
- Retry logic for API calls
- Timeout handling for long operations
- Mutex-protected critical updates
- Validated email setter

### 2. API Store Demo
Demonstrates:
- Cached API responses with disk persistence
- Concurrent API calls with queuing
- Throttled operations
- Retry logic with multiple attempts
- Timeout for slow endpoints
- Combined features (concurrent + retry + timeout)

### 3. Form Store Demo
Demonstrates:
- Real-time form validation
- Reactive form fields with streams
- Debounced form submission
- Multiple validators per field
- Cached form validation state

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)

### Installation

1. **Navigate to the example directory:**
   ```bash
   cd example
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation:**
   ```bash
   flutter pub run build_runner build
   ```
   
   Or for watch mode (auto-regenerates on file changes):
   ```bash
   flutter pub run build_runner watch
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
example/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── home_screen.dart      # Main navigation screen
│   │   ├── user_demo_screen.dart # User store demonstrations
│   │   ├── api_demo_screen.dart  # API store demonstrations
│   │   └── form_demo_screen.dart # Form validation demonstrations
│   └── stores/
│       ├── user_store.dart       # User state with caching & concurrency
│       ├── api_store.dart        # API operations with retry & timeout
│       └── form_store.dart       # Form validation & streaming
└── pubspec.yaml
```

## 🎨 Features by Store

### UserStore (`stores/user_store.dart`)

```dart
// Cached getter with 10-minute duration
@Cache(key: 'fullName', duration: Duration(minutes: 10))
String get fullName => '$_name (Age: $_age)';

// Concurrent method with debouncing
@Concurrent(maxConcurrent: 1, debounce: true)
Future<void> updateProfile(String name, int age) async { ... }

// Method with retry logic
@Retry(maxAttempts: 3, delay: Duration(seconds: 1))
Future<Map<String, dynamic>> fetchUserData() async { ... }

// Mutex-protected critical section
@Mutex(lockKey: 'userUpdate')
Future<void> criticalUpdate(String status) async { ... }

// Validated email setter
@Validate([Validator.notEmpty, Validator.email])
void setEmail(String value) { ... }
```

### ApiStore (`stores/api_store.dart`)

```dart
// Cached API response with disk persistence
@Cache(
  key: 'apiData',
  duration: Duration(minutes: 5),
  persist: true,
  strategy: CacheStrategy.diskFirst,
)
Future<String> get cachedApiData async { ... }

// Concurrent API call with debouncing
@Concurrent(
  maxConcurrent: 3,
  queueKey: 'api_calls',
  debounce: true,
)
Future<String> fetchData(String endpoint) async { ... }

// Retry with 5 attempts
@Retry(maxAttempts: 5, delay: Duration(milliseconds: 500))
Future<Map<String, dynamic>> fetchWithRetry(String url) async { ... }

// Combined annotations
@Concurrent(maxConcurrent: 2)
@Retry(maxAttempts: 3)
@Timeout(Duration(seconds: 10))
Future<String> complexApiCall(String endpoint) async { ... }
```

### FormStore (`stores/form_store.dart`)

```dart
// Streamed properties for reactive UI
@Streamed(broadcast: true)
String get usernameStream => _username;

// Validated setters
@Validate([Validator.notEmpty, Validator.email])
void setEmailValidated(String value) { ... }

// Cached form validation
@Cache(key: 'formValid', duration: Duration(seconds: 1))
bool get isFormValid { ... }

// Debounced form submission
@Concurrent(maxConcurrent: 1, debounce: true)
Future<bool> submitForm() async { ... }
```

## 🔧 Generated Code

After running `build_runner`, the following files will be generated:

- `stores/user_store.bindx.dart` - Generated extensions for UserStore
- `stores/api_store.bindx.dart` - Generated extensions for ApiStore
- `stores/form_store.bindx.dart` - Generated extensions for FormStore

These files contain:
- Cached getter implementations
- Concurrent method wrappers
- Stream controllers and subscriptions
- Validated setter implementations
- Retry logic wrappers
- Mutex-protected method wrappers
- Timeout wrappers

## 📖 Usage Examples

### Using Cached Getters

```dart
final store = UserStore(name: 'John', email: 'john@example.com', age: 30);

// First call - computes and caches
final name1 = store.fullNameCached;

// Second call - returns cached value
final name2 = store.fullNameCached;
```

### Using Concurrent Methods

```dart
// Debounced - only the last call in 500ms window executes
await store.updateProfileConcurrent('Jane', 25);
await store.updateProfileConcurrent('Jane', 26); // This one executes
```

### Using Streams

```dart
// Subscribe to status changes
store.statusStream.listen((status) {
  print('Status changed: $status');
});

// Update status - triggers stream
store.updateStatus('inactive');
```

### Using Validated Setters

```dart
try {
  store.setEmailValidated('invalid-email'); // Throws ValidationException
} catch (e) {
  print('Validation failed: $e');
}

store.setEmailValidated('valid@example.com'); // Success
```

### Using Retry Logic

```dart
try {
  final data = await store.fetchDataWithRetry();
  print('Data fetched: $data');
} catch (e) {
  print('Failed after 3 retries: $e');
}
```

## 🎯 Interactive Features

The example app includes:

1. **Live Demonstrations**: Interactive buttons to trigger each feature
2. **Activity Logs**: Real-time logging of operations in the API demo
3. **Visual Feedback**: Status indicators and validation messages
4. **Form Validation**: Real-time validation with visual feedback
5. **Statistics**: Request counters and status displays

## 🌟 Best Practices Demonstrated

1. **Cache Duration**: Different durations based on data volatility
2. **Concurrency Limits**: Preventing resource exhaustion
3. **Debouncing**: For user-triggered events
4. **Throttling**: For rate-limited APIs
5. **Validation**: Multiple validators for comprehensive checks
6. **Error Handling**: Proper retry and timeout strategies

## 🐛 Troubleshooting

### Code generation fails
```bash
# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Import errors
Make sure you've run code generation and uncommented the imports in the demo screens.

### Validation not working
Ensure the generated `.bindx.dart` files are imported alongside your store files.

## 📚 Learn More

- [StateGen Documentation](../README.md)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Build Runner](https://pub.dev/packages/build_runner)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This example is part of the StateGen package and follows the same license.
