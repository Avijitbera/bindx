# BindX Examples

This directory contains example applications demonstrating various features of BindX.

## Examples

### 1. Counter App (`counter_app.dart`)

Basic example showing:
- Creating a store
- Using BindXProvider
- State updates
- Widget rebuilds

**Run:**
```bash
flutter run -t lib/examples/counter_app.dart
```

### 2. Todo App (`todo_app.dart`)

Intermediate example showing:
- Complex state management
- List operations
- Filtering and computed values
- Caching with @Cache annotation

**Run:**
```bash
flutter run -t lib/examples/todo_app.dart
```

### 3. Search App (`search_app.dart`)

Advanced example showing:
- Stream operations
- Debouncing
- API integration
- Error handling

**Run:**
```bash
flutter run -t lib/examples/search_app.dart
```

### 4. Multi-Store App (`multi_store_app.dart`)

Shows:
- Multiple stores
- Store composition
- MultiBindXProvider
- Cross-store communication

**Run:**
```bash
flutter run -t lib/examples/multi_store_app.dart
```

### 5. Async Operations (`async_app.dart`)

Demonstrates:
- Concurrent operations
- Retry logic
- Timeout handling
- Future/Stream extensions

**Run:**
```bash
flutter run -t lib/examples/async_app.dart
```

## Structure

Each example is a standalone Flutter app that you can run independently.

```
examples/
├── counter_app.dart
├── todo_app.dart
├── search_app.dart
├── multi_store_app.dart
└── async_app.dart
```

## Learning Path

1. **Start with Counter App** - Basic concepts
2. **Move to Todo App** - Real-world patterns
3. **Try Search App** - Reactive programming
4. **Explore Multi-Store** - Advanced architecture
5. **Study Async Operations** - Performance optimization

## Common Patterns

### Creating a Store

```dart
class MyStore extends BindXStore<MyState> {
  MyStore() : super(MyState.initial());

  Future<void> updateData(String data) async {
    await update((current) => current.copyWith(data: data));
  }
}
```

### Providing to Widget Tree

```dart
void main() {
  runApp(
    BindXProvider<MyStore>(
      store: MyStore(),
      child: MyApp(),
    ),
  );
}
```

### Consuming in Widgets

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = BindXProvider.of<MyStore>(context);
    return Text(store.state.data);
  }
}
```

## Tips

- Always dispose stores when not needed
- Use const constructors when possible
- Leverage annotations for common patterns
- Test stores independently of UI
- Use middleware for cross-cutting concerns

## Need Help?

- 📖 Read the [main README](../README.md)
- 🐛 Check [issues](https://github.com/yourusername/bindx/issues)
- 💬 Join [discussions](https://github.com/yourusername/bindx/discussions)
