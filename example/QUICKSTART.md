# Quick Start Guide - StateGen Example

This guide will help you get the StateGen example app up and running in minutes.

## Step 1: Install Dependencies

```bash
cd example
flutter pub get
```

## Step 2: Run Code Generation

This is the **most important step**. StateGen uses code generation to create the magic!

```bash
flutter pub run build_runner build
```

**Expected output:**
```
[INFO] Generating build script completed, took 2.1s
[INFO] Creating build script snapshot... completed, took 10.2s
[INFO] Building new asset graph completed, took 1.2s
[INFO] Checking for unexpected pre-existing outputs. completed, took 0s
[INFO] Running build completed, took 5.3s
[INFO] Caching finalized dependency graph completed, took 0.1s
[INFO] Succeeded after 5.4s with 3 outputs
```

This will generate three files:
- `lib/stores/user_store.bindx.dart`
- `lib/stores/api_store.bindx.dart`
- `lib/stores/form_store.bindx.dart`

## Step 3: Uncomment the Code

After code generation, uncomment the following in each demo screen:

### In `lib/screens/user_demo_screen.dart`:
```dart
// Uncomment these lines:
import '../stores/user_store.dart';
late final UserStore _userStore;

// In initState:
_userStore = UserStore(
  name: 'John Doe',
  email: 'john@example.com',
  age: 30,
);
```

### In `lib/screens/api_demo_screen.dart`:
```dart
// Uncomment these lines:
import '../stores/api_store.dart';
late final ApiStore _apiStore;

// In initState:
_apiStore = ApiStore();
```

### In `lib/screens/form_demo_screen.dart`:
```dart
// Uncomment these lines:
import '../stores/form_store.dart';
late final FormStore _formStore;

// In initState:
_formStore = FormStore();
```

## Step 4: Run the App

```bash
flutter run
```

## 🎉 That's It!

You should now see the StateGen example app running with three demo screens:

1. **User Store Demo** - Caching, concurrency, retry, and mutex
2. **API Store Demo** - API operations with advanced features
3. **Form Store Demo** - Validation and reactive forms

## 🔄 Watch Mode (Optional)

For development, you can use watch mode to automatically regenerate code when files change:

```bash
flutter pub run build_runner watch
```

## 🐛 Troubleshooting

### "Part file doesn't exist" error
Run code generation: `flutter pub run build_runner build`

### "Conflicting outputs" error
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean build
```bash
flutter pub run build_runner clean
flutter pub run build_runner build
```

## 📱 What to Try

1. **User Demo**: Click buttons to see debouncing, retry logic, and mutex in action
2. **API Demo**: Watch the activity log to see concurrent operations and retries
3. **Form Demo**: Fill in the form to see real-time validation

## 🚀 Next Steps

- Explore the generated `.bindx.dart` files to see what StateGen created
- Modify the stores to add your own annotations
- Create your own stores with StateGen annotations
- Read the full [README](README.md) for detailed documentation

## 💡 Pro Tips

1. Use `@Cache` for expensive computations
2. Use `@Concurrent` with `debounce: true` for user-triggered actions
3. Use `@Retry` for network operations
4. Use `@Validate` for form fields
5. Use `@Streamed` for reactive UI updates

Happy coding! 🎨
