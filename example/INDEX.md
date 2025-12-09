# 🚀 StateGen Example App - Complete Guide

Welcome to the **StateGen Example App**! This comprehensive example demonstrates all features of the StateGen package - an advanced state management code generator for Flutter.

## 📚 Documentation Index

This example includes multiple documentation files to help you get started:

### 1. **[QUICKSTART.md](QUICKSTART.md)** - Start Here! ⚡
**Best for**: Getting the app running in 5 minutes
- Step-by-step setup instructions
- Code generation commands
- Quick troubleshooting
- What to try first

### 2. **[README.md](README.md)** - Complete Reference 📖
**Best for**: Understanding all features in depth
- Comprehensive feature documentation
- Code examples for each annotation
- Project structure
- Best practices
- Detailed troubleshooting

### 3. **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - UI/UX Overview 🎨
**Best for**: Understanding the user interface
- Screen-by-screen breakdown
- Visual elements description
- User flow explanation
- Design principles

### 4. **[SUMMARY.md](SUMMARY.md)** - Quick Overview 📋
**Best for**: Getting a bird's-eye view
- What was created
- File structure
- Features checklist
- Technical details

## 🎯 Quick Navigation

### For First-Time Users
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Run code generation
3. Launch the app
4. Explore the demos

### For Developers
1. Check [README.md](README.md) for code examples
2. Review the store files in `lib/stores/`
3. Examine the generated `.bindx.dart` files
4. Customize for your needs

### For Designers
1. Read [VISUAL_GUIDE.md](VISUAL_GUIDE.md)
2. Run the app to see the UI
3. Explore the Material 3 design

## 📦 What's Inside

### Stores (Data Layer)
- **`user_store.dart`** - User management with caching, concurrency, and validation
- **`api_store.dart`** - API operations with retry, timeout, and throttling
- **`form_store.dart`** - Form validation and reactive fields

### Screens (UI Layer)
- **`home_screen.dart`** - Main navigation and feature overview
- **`user_demo_screen.dart`** - Interactive user store demonstrations
- **`api_demo_screen.dart`** - API operations with activity logging
- **`form_demo_screen.dart`** - Form validation showcase

### Configuration
- **`pubspec.yaml`** - Dependencies including StateGen
- **`build.yaml`** - Code generation configuration

## 🌟 Key Features Demonstrated

### Caching 🔄
```dart
@Cache(duration: Duration(minutes: 10))
String get fullName => '$_name (Age: $_age)';
```
- Memory and disk caching
- Configurable durations
- Multiple strategies
- Tagged caching

### Concurrency ⚡
```dart
@Concurrent(maxConcurrent: 1, debounce: true)
Future<void> updateProfile(String name, int age) async { ... }
```
- Debouncing
- Throttling
- Task queuing
- Priority support

### Validation ✅
```dart
@Validate([Validator.notEmpty, Validator.email])
void setEmail(String value) { ... }
```
- Multiple validators
- Real-time validation
- Custom error messages

### Retry Logic 🔁
```dart
@Retry(maxAttempts: 3, delay: Duration(seconds: 1))
Future<Map<String, dynamic>> fetchUserData() async { ... }
```
- Automatic retries
- Configurable delays
- Exception handling

### Streams 📡
```dart
@Streamed(broadcast: true)
String get usernameStream => _username;
```
- Reactive properties
- Broadcast streams
- Real-time updates

### Mutex 🔒
```dart
@Mutex(lockKey: 'userUpdate')
Future<void> criticalUpdate(String status) async { ... }
```
- Thread-safe operations
- Lock management
- Timeout handling

### Timeout ⏱️
```dart
@Timeout(Duration(seconds: 5))
Future<void> longRunningTask() async { ... }
```
- Operation timeouts
- Automatic cancellation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2

### Installation (3 Steps)

1. **Install dependencies:**
   ```bash
   cd example
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter pub run build_runner build
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

**That's it!** 🎉

## 📱 App Structure

```
example/
├── 📄 Documentation
│   ├── QUICKSTART.md          # Quick start guide
│   ├── README.md              # Complete documentation
│   ├── VISUAL_GUIDE.md        # UI/UX guide
│   ├── SUMMARY.md             # Overview
│   └── INDEX.md               # This file
│
├── 📱 Application Code
│   └── lib/
│       ├── main.dart          # App entry point
│       ├── screens/           # UI screens
│       │   ├── home_screen.dart
│       │   ├── user_demo_screen.dart
│       │   ├── api_demo_screen.dart
│       │   └── form_demo_screen.dart
│       └── stores/            # Data stores
│           ├── user_store.dart
│           ├── api_store.dart
│           └── form_store.dart
│
└── ⚙️ Configuration
    ├── pubspec.yaml           # Dependencies
    └── build.yaml             # Code generation config
```

## 🎓 Learning Path

### Beginner
1. ✅ Run the app (follow QUICKSTART.md)
2. ✅ Explore the home screen
3. ✅ Try the User Demo
4. ✅ Read the generated code

### Intermediate
1. ✅ Study the store implementations
2. ✅ Understand each annotation
3. ✅ Try the API Demo
4. ✅ Modify existing stores

### Advanced
1. ✅ Create your own stores
2. ✅ Combine multiple annotations
3. ✅ Try the Form Demo
4. ✅ Build a real application

## 💡 Pro Tips

1. **Use Watch Mode**: `flutter pub run build_runner watch` for auto-regeneration
2. **Check Generated Code**: Look at `.bindx.dart` files to understand what's created
3. **Combine Annotations**: Stack multiple annotations for powerful features
4. **Read Logs**: The API demo's activity log is very educational
5. **Experiment**: Modify the stores and see what happens

## 🐛 Common Issues

### "Part file doesn't exist"
**Solution**: Run `flutter pub run build_runner build`

### "Conflicting outputs"
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Import errors
**Solution**: Make sure you've uncommented the imports after code generation

### Validation not working
**Solution**: Ensure `.bindx.dart` files are generated and imported

## 📖 Code Examples

### Basic Cache
```dart
@Cache(duration: Duration(minutes: 5))
String get userName => _name;

// Usage
final name = store.userNameCached;
```

### Debounced Operation
```dart
@Concurrent(debounce: true, debounceDuration: Duration(milliseconds: 500))
Future<void> search(String query) async { ... }

// Usage
await store.searchConcurrent('flutter');
```

### Validated Setter
```dart
@Validate([Validator.notEmpty, Validator.email])
void setEmail(String value) { _email = value; }

// Usage
try {
  store.setEmailValidated('user@example.com');
} catch (e) {
  print('Validation failed: $e');
}
```

### Retry Logic
```dart
@Retry(maxAttempts: 3)
Future<Data> fetchData() async { ... }

// Usage
final data = await store.fetchDataWithRetry();
```

## 🎯 What to Build Next

After exploring this example, try building:
- 📝 A todo app with caching
- 🛒 A shopping cart with validation
- 📊 A dashboard with API integration
- 💬 A chat app with streams
- 📱 Your own app idea!

## 🤝 Contributing

Found an issue or have a suggestion? Feel free to:
- Open an issue
- Submit a pull request
- Share your feedback

## 📄 License

This example is part of the StateGen package and follows the same license.

## 🙏 Acknowledgments

Built with ❤️ using:
- Flutter & Dart
- Material Design 3
- StateGen package
- Build Runner

---

## 🚀 Ready to Start?

1. **New to StateGen?** → Start with [QUICKSTART.md](QUICKSTART.md)
2. **Want details?** → Read [README.md](README.md)
3. **Visual learner?** → Check [VISUAL_GUIDE.md](VISUAL_GUIDE.md)
4. **Need overview?** → See [SUMMARY.md](SUMMARY.md)

**Happy coding!** 🎨✨

---

*Last updated: December 2025*
