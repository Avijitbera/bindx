# Expense Tracker - BindX Feature Showcase 🚀

A comprehensive expense tracking application built with Flutter that demonstrates **ALL** available features of the BindX state management library.

## 📱 Screenshots & Features

### Features Implemented:
- ✅ Add, edit, and delete expenses
- ✅ Categorize expenses with icons and colors
- ✅ Search expenses with debounced input
- ✅ Filter by category
- ✅ View expenses grouped by date
- ✅ Real-time total calculations
- ✅ Monthly statistics dashboard
- ✅ Category breakdown with pie charts
- ✅ Budget tracking per category
- ✅ Cloud sync simulation
- ✅ Sample data generation

## 🎯 BindX Features Demonstrated

This app showcases the following BindX features:

### 1. **Core State Management**
- `BindXStore<T>` - Reactive state container
- Immutable state updates with `copyWith`
- Automatic change notification
- Stream of state changes

### 2. **Annotations**

#### `@Cache` - Result Caching
```dart
@Cache(duration: Duration(seconds: 30), tag: 'statistics')
Future<double> getTotalExpenses() async { ... }
```

#### `@Concurrent` - Concurrency Control
```dart
@Concurrent(maxConcurrent: 3)
Future<void> addExpense(Expense expense) async { ... }
```

#### `@Streamed` - Reactive Streams
```dart
@Streamed(broadcast: true)
Stream<double> get totalStream { ... }
```

### 3. **Stream Extensions**
- `debounce()` - Wait for pause in events
- `throttle()` - Limit event frequency
- `switchMap()` - Cancel previous operations
- `mergeMap()` - Run concurrently
- `combineWith()` - Combine multiple streams
- `cacheLatest()` - Cache latest value
- `retryWithBackoff()` - Retry failed streams
- `groupBy()` - Group stream items

### 4. **Future Extensions**
- `timeoutAfter()` - Timeout with fallback
- `asResult()` - No-exception error handling
- `tap()` - Side effects
- `BindXAsync.executeWithRetry()` - Retry with backoff

### 5. **Widget Integration**
- `BindXProvider` - Provide stores to widget tree
- `MultiBindXProvider` - Multiple store providers
- `BindXConsumer` - Rebuild on store changes
- `BindXMultiBuilder` - Build from multiple stores

### 6. **Global Registry**
- Register stores globally
- Access stores by name
- Watch for store changes

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── expense.dart           # Expense data model
│   ├── category.dart          # Category model with presets
│   └── expense_state.dart     # Application state model
├── stores/
│   └── expense_store.dart     # Main store (ALL BindX features)
├── screens/
│   ├── home_screen.dart       # Expense list with search/filter
│   ├── add_expense_screen.dart # Add/edit expense form
│   ├── statistics_screen.dart  # Charts and statistics
│   └── settings_screen.dart    # Settings and sample data
├── utils/
│   └── sample_data.dart       # Sample data generator
└── main.dart                  # App entry point
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK 3.9.2 or higher

### Installation

1. Navigate to the expense tracker directory:
```bash
cd example/expancetracker
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Loading Sample Data

1. Open the app
2. Go to the **Settings** tab (bottom navigation)
3. Tap **"Load Sample Data"** to generate 50 random expenses
4. Or tap **"Load Balanced Data"** for 5 expenses per category

## 📖 Code Examples

### Creating a BindX Store

```dart
class ExpenseStore extends BindX Store<ExpenseState> {
  ExpenseStore() : super(ExpenseState.initial());

  Future<void> addExpense(Expense expense) async {
    await update((current) => current.copyWith(
      expenses: [...current.expenses, expense],
    ));
  }
}
```

### Using Cached Computations

```dart
@Cache(duration: Duration(minutes: 5), persist: true)
Future<Map<String, double>> getExpensesByCategory() async {
  // Heavy computation, cached for 5 minutes
  return categoryTotals;
}
```

### Reactive UI with Streams

```dart
StreamBuilder<double>(
  stream: store.totalStream,
  builder: (context, snapshot) {
    return Text('Total: ₹${snapshot.data ?? 0}');
  },
)
```

### Debounced Search

```dart
_searchController.stream
  .debounce(Duration(milliseconds: 300))
  .listen((query) {
    update((current) => current.copyWith(searchQuery: query));
  });
```

## 🎓 Learning Path

1. **Start with Models** - Understand the data structure
   - `lib/models/expense.dart`
   - `lib/models/expense_state.dart`
   - `lib/models/category.dart`

2. **Study the Store** - See all BindX features in action
   - `lib/stores/expense_store.dart`
   - Look for `@Cache`, `@Concurrent`, `@Streamed` annotations
   - Study stream extensions usage

3. **Review UI Integration** - Learn widget patterns
   - `lib/screens/home_screen.dart` - BindXConsumer & StreamBuilder
   - `lib/screens/statistics_screen.dart` - Cached computations
   - `lib/main.dart` - Provider setup

4. **Explore Advanced Features** - Extension methods
   - Stream extensions in `expense_store.dart`
   - Future extensions in async operations
   - Registry access examples in `main.dart`

## 💡 Key Takeaways

1. **@Cache** - Reduces redundant expensive computations
2. **@Concurrent** - Prevents race conditions and manages async load
3. **@Streamed** - Creates reactive data flows automatically
4. **Stream Extensions** - Powerful reactive programming patterns
5. **Registry** - Global state access when needed
6. **Immutable State** - Always use `copyWith` for updates

## 🐛 Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Dependency issues?
```bash
flutter pub upgrade
```

## 📝 Notes

- All computations use proper caching
- Search uses debouncing for performance
- Concurrent operations are controlled
- State is immutable throughout
- Clean architecture with separation of concerns

## 🤝 Contributing

This is a reference implementation. You can:
- Add more features
- Improve the UI
- Add more BindX examples
- Report issues
- Suggest improvements

## 📄 License

Part of the BindX package - see main BindX LICENSE

---

**Built with ❤️ using BindX State Management**

For more information about BindX, see the [main README](../../README.md)
