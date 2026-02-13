# BindX Features Guide - Expense Tracker Implementation

This document provides a detailed guide to all BindX features implemented in the Expense Tracker app.

## Table of Contents

1. [Core State Management](#core-state-management)
2. [Caching with @Cache](#caching-with-cache)
3. [Concurrency with @Concurrent](#concurrency-with-concurrent)
4. [Reactive Streams with @Streamed](#reactive-streams-with-streamed)
5. [Stream Extensions](#stream-extensions)
6. [Future Extensions](#future-extensions)
7. [Widget Integration](#widget-integration)
8. [Global Registry](#global-registry)

---

## Core State Management

### BindXStore Basics

The `ExpenseStore` extends `BindXStore<ExpenseState>` to manage application state:

**Location:** `lib/stores/expense_store.dart`

```dart
class ExpenseStore extends BindXStore<ExpenseState> {
  ExpenseStore() : super(ExpenseState.initial());
}
```

### State Updates

All state updates use the `update()` method:

```dart
Future<void> addExpense(Expense expense) async {
  await update((current) => current.copyWith(
    expenses: [...current.expenses, expense],
  ));
}
```

**Key Points:**
- State updates are asynchronous
- Always use `copyWith` for immutability
- `update()` automatically notifies listeners
- Thread-safe by default

---

## Caching with @Cache

The `@Cache` annotation caches method results to improve performance.

### Example 1: Simple Caching

```dart
@Cache(duration: Duration(seconds: 30), tag: 'statistics')
Future<double> getTotalExpenses() async {
  return state.expenses.fold<double>(0.0, (sum, exp) => sum + exp.amount);
}
```

**What happens:**
- Result is cached for 30 seconds
- Subsequent calls return cached value
- Tagged with 'statistics' for group invalidation

### Example 2: Persistent Caching

```dart
@Cache(duration: Duration(minutes: 5), persist: true, tag: 'category-stats')
Future<Map<String, double>> getExpensesByCategory() async {
  // Heavy computation
  return categoryTotals;
}
```

**What happens:**
- Result is cached for 5 minutes
- Cached to disk (survives app restarts)
- Tagged for selective invalidation

### Cache Invalidation

```dart
await store.invalidateCache('statistics');
```

**When to use caching:**
- ✅ Expensive computations
- ✅ API calls
- ✅ Complex data transformations
- ✅ Frequently accessed data

---

## Concurrency with @Concurrent

The `@Concurrent` annotation controls how many operations can run simultaneously.

### Example 1: Limited Concurrency

```dart
@Concurrent(maxConcurrent: 3)
Future<void> addExpense(Expense expense) async {
  // Only 3 add operations can run at once
}
```

**What happens:**
- Maximum 3 concurrent executions
- Additional calls are queued
- Prevents overwhelming the system

### Example 2: Debounced Operation

```dart
@Concurrent(
  maxConcurrent: 1,
  debounce: true,
  debounceDuration: Duration(milliseconds: 200),
)
Future<void> deleteExpense(String id) async {
  // Debounced to prevent accidental rapid deletions
}
```

**What happens:**
- Only one deletion at a time
- Waits 200ms after last call
- Prevents accidental double-delete

### Example 3: Queued Operations

```dart
@Concurrent(maxConcurrent: 5, queueKey: 'bulk-operations')
Future<void> bulkAddExpenses(List<Expense> expenses) async {
  // Up to 5 concurrent, grouped by queue key
}
```

**When to use:**
- ✅ API rate limiting
- ✅ Preventing race conditions
- ✅ Resource management
- ✅ User input debouncing

---

## Reactive Streams with @Streamed

The `@Streamed` annotation creates reactive streams from properties.

### Example 1: Computed Stream

```dart
@Streamed(broadcast: true)
Stream<double> get totalStream {
  return stream.asyncMap((_) async => await getTotalExpenses());
}
```

**Usage in UI:**
```dart
StreamBuilder<double>(
  stream: store.totalStream,
  builder: (context, snapshot) {
    return Text('Total: ₹${snapshot.data ?? 0}');
  },
)
```

### Example 2: Filtered Stream

```dart
@Streamed(broadcast: true)
Stream<List<Expense>> get filteredExpensesStream {
  return stream.map((state) {
    var filtered = state.expenses;
    // Apply filters...
    return filtered;
  });
}
```

**What happens:**
- Stream emits on every state change
- Automatically filters expenses
- UI rebuilds reactively

### Example 3: Category Stats Stream

```dart
@Streamed(broadcast: true)
Stream<Map<String, double>> get categoryStatsStream {
  return stream.asyncMap((_) async => await getExpensesByCategory());
}
```

**When to use streamed properties:**
- ✅ Reactive UI updates
- ✅ Derived state
- ✅ Multiple listeners
- ✅ Real-time dashboards

---

## Stream Extensions

BindX provides powerful stream operators inspired by RxDart.

### 1. Debounce - Wait for Pause

```dart
_searchController.stream
  .debounce(Duration(milliseconds: 300))
  .listen((query) {
    update((current) => current.copyWith(searchQuery: query));
  });
```

**Use case:** Search input - wait for user to stop typing

### 2. Throttle - Limit Frequency

```dart
_expenseAddedController.stream
  .throttle(Duration(milliseconds: 500))
  .listen((expense) {
    print('New expense added: ${expense.title}');
  });
```

**Use case:** Rate limiting notifications

### 3. SwitchMap - Cancel Previous

```dart
queryController.stream
  .switchMap((query) => searchApi(query))
  .listen((results) => print('Results: $results'));
```

**Use case:** Cancel old API calls when new search starts

### 4. MergeMap - Run Concurrently

```dart
itemController.stream
  .mergeMap((item) => processItem(item))
  .listen((processed) => print('Processed: $processed'));
```

**Use case:** Process multiple items in parallel

### 5. CombineWith - Merge Streams

```dart
stream1.combineWith(stream2, (a, b) => a + b)
  .listen((combined) => print('Combined: $combined'));
```

**Use case:** Combine data from multiple sources

---

## Future Extensions

Enhanced async operations for cleaner error handling.

### 1. Timeout with Fallback

```dart
await future.timeoutAfter(
  Duration(seconds: 5),
  onTimeout: () => 'Timeout fallback',
);
```

### 2. Result Type (No Exceptions)

```dart
final result = await apiCall().asResult();
if (result.isSuccess) {
  print(result.value);
} else {
  print(result.error);
}
```

### 3. Tap for Side Effects

```dart
await apiCall().tap(
  onValue: (value) => print('Got: $value'),
  onError: (error, stack) => logError(error),
);
```

### 4. Retry with Backoff

```dart
await BindXAsync.executeWithRetry(
  () => unreliableApiCall(),
  maxRetries: 3,
  timeout: Duration(seconds: 30),
);
```

**When to use:**
- ✅ Network requests
- ✅ Unreliable operations
- ✅ User-friendly error handling
- ✅ Logging and monitoring

---

## Widget Integration

BindX provides several widgets for easy integration.

### 1. BindXProvider - Provide Store

```dart
BindXProvider<ExpenseStore>(
  store: ExpenseStore(),
  register: true,
  name: 'expense-store',
  child: MyApp(),
)
```

### 2. MultiBindXProvider - Multiple Stores

```dart
MultiBindXProvider(
  providers: [
    BindXProvider<ExpenseStore>(
      store: ExpenseStore(),
      register: true,
      child: SizedBox.shrink(),
    ),
  ],
  child: MyApp(),
)
```

### 3. BindXConsumer - Rebuild on Changes

```dart
BindXConsumer(
  storeTypes: [ExpenseStore],
  builder: (context) {
    final store = BindXProvider.of<ExpenseStore>(context);
    return Text('${store.state.expenses.length}');
  },
)
```

### 4. BindXMultiBuilder - Multiple Stores

```dart
BindXMultiBuilder(
  storeTypes: [ExpenseStore],
  builder: (context, stores) {
    final expenseStore = stores[ExpenseStore];
    return /* widget */;
  },
)
```

---

## Global Registry

Access stores globally without context.

### Register Store

```dart
BindXProvider<ExpenseStore>(
  store: ExpenseStore(),
  register: true,
  name: 'expense-store',
)
```

### Access Store

```dart
final store = bindxRegistry.get<ExpenseStore>(name: 'expense-store');
```

### Check Existence

```dart
final exists = bindxRegistry.exists<ExpenseStore>(name: 'expense-store');
```

### Watch for Changes

```dart
bindx Registry.watch<ExpenseStore>().listen((store) {
  print('Store updated: ${store.state.expenses.length} expenses');
});
```

**When to use registry:**
- ✅ Services and utilities
- ✅ Background tasks
- ✅ Cross-cutting concerns
- ✅ Deep widget trees

---

## Best Practices

### 1. State Management
- Always use immutable state
- Use `copyWith` for updates
- Keep state models simple
- Use factories for initial state

### 2. Caching
- Cache expensive computations
- Use appropriate durations
- Tag related caches
- Invalidate when needed

### 3. Concurrency
- Limit concurrent operations
- Debounce user inputs
- Use queue keys for related operations
- Consider mobile constraints

### 4. Streams
- Use broadcast streams for multiple listeners
- Clean up controllers in dispose
- Handle errors appropriately
- Combine operations with extensions

### 5. Error Handling
- Use `.asResult()` for clean error handling
- Implement retry logic for network calls
- Provide timeout fallbacks
- Log errors appropriately

---

## Performance Tips

1. **Cache Wisely**: Don't over-cache or under-cache
2. **Debounce Inputs**: Reduce unnecessary updates
3. **Limit Concurrency**: Prevent resource exhaustion
4. **Use Streams Efficiently**: Avoid unnecessary rebuilds
5. **Profile Your App**: Use Flutter DevTools

---

## Common Patterns

### Pattern 1: Search with Debounce

```dart
final _searchController = StreamController<String>();

_searchController.stream
  .debounce(Duration(milliseconds: 300))
  .listen((query) {
    update((current) => current.copyWith(searchQuery: query));
  });
```

### Pattern 2: Cached Statistics

```dart
@Cache(duration: Duration(minutes: 1))
Future<Stats> getStatistics() async {
  // Expensive computation
}
```

### Pattern 3: Retry Network Call

```dart
await BindXAsync.executeWithRetry(
  () => api.syncData(),
  maxRetries: 3,
  timeout: Duration(seconds: 30),
);
```

---

## Conclusion

BindX provides a comprehensive set of tools for state management in Flutter:

- **Simple**: Clean API with annotations
- **Powerful**: Advanced async and reactive features
- **Performant**: Built-in caching and concurrency control
- **Flexible**: Works with any architecture

For more examples, explore the Expense Tracker app code!
