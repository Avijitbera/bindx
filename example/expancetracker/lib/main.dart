import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bindx/bindx.dart';
import 'stores/expense_store.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using BindXProvider to provide the ExpenseStore
    // This demonstrates the Provider widget feature of BindX
    return BindXProvider<ExpenseStore>(
      store: ExpenseStore(),
      register: true, // Register in global registry
      name: 'expense-store', // Name for registry lookup
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    ); // BindXProvider
  }
}

/// Demo: How to use MultiBindXProvider for multiple stores
///
/// If you need multiple stores, use this pattern:
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final expenseStore = ExpenseStore();
///     final settingsStore = SettingsStore();
///
///     // First create providers without children
///     final providers = [
///       BindXProvider<ExpenseStore>(
///         store: expenseStore,
///         register: true,
///         name: 'expense-store',
///         child: Container(), // MultiBindXProvider will replace this
///       ),
///       BindXProvider<SettingsStore>(
///         store: settingsStore,
///         register: true,
///         name: 'settings-store',
///         child: Container(), // MultiBindXProvider will replace this
///       ),
///     ];
///
///     return MultiBindXProvider(
///       providers: providers,
///       child: MaterialApp(...),
///     );
///   }
/// }
/// ```

/// Demo: Accessing store from global registry
/// This demonstrates the Registry feature of BindX
class RegistryExample extends StatelessWidget {
  const RegistryExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Access store from global registry by name
    final expenseStore = bindxRegistry.get<ExpenseStore>(name: 'expense-store');

    // Watch for store changes
    bindxRegistry.watch<ExpenseStore>().listen((store) {
      print('Expense store updated: ${store.state.expenses.length} expenses');
    });

    // Check if store exists
    final exists = bindxRegistry.exists<ExpenseStore>(name: 'expense-store');
    print('Store exists: $exists');
    print('Expense store: $expenseStore');

    return const SizedBox.shrink();
  }
}

/// Demo: Using BindXMultiBuilder for multiple stores
/// This demonstrates the multi-store builder feature
class MultiStoreExample extends StatelessWidget {
  const MultiStoreExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BindXMultiBuilder(
      storeTypes: [ExpenseStore],
      builder: (context, stores) {
        final expenseStore = stores[ExpenseStore] as BindXStore;

        return Column(
          children: [
            Text('Store state: ${expenseStore.state}'),
            // Use multiple stores here
          ],
        );
      },
    );
  }
}

/// Demo: Using Future Extensions from BindX
class FutureExtensionsDemo {
  Future<void> demonstrateFutureExtensions() async {
    // 1. Timeout with fallback
    final result =
        await Future.delayed(
          const Duration(seconds: 2),
          () => 'Success',
        ).timeoutAfter(
          const Duration(seconds: 5),
          onTimeout: () => 'Timeout fallback',
        );
    print('Result with timeout: $result');

    // 2. Result type (no exceptions)
    final apiResult = await _simulateApiCall().asResult();
    if (apiResult.isSuccess) {
      print('API Success: ${apiResult.value}');
    } else {
      print('API Error: ${apiResult.error}');
    }

    // 3. Tap for side effects
    await _simulateApiCall().tap(
      onValue: (value) => print('Got value: $value'),
      onError: (error, stack) => print('Got error: $error'),
    );

    // 4. Retry with backoff
    await BindXAsync.executeWithRetry(
      () => _unreliableApiCall(),
      maxRetries: 3,
      timeout: const Duration(seconds: 30),
    );
  }

  Future<String> _simulateApiCall() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'API Response';
  }

  Future<String> _unreliableApiCall() async {
    // Simulates an API that might fail
    await Future.delayed(const Duration(milliseconds: 500));
    if (DateTime.now().millisecond % 2 == 0) {
      throw Exception('Random failure');
    }
    return 'Success';
  }
}

/// Demo: Using Stream Extensions from BindX
class StreamExtensionsDemo {
  void demonstrateStreamExtensions() {
    // 1. Debounce - wait for pause in events
    final searchController = StreamController<String>();
    searchController.stream
        .debounce(const Duration(milliseconds: 300))
        .listen((query) => print('Debounced search: $query'));

    // 2. Throttle - limit event frequency
    final clickController = StreamController<void>();
    clickController.stream
        .throttle(const Duration(seconds: 1))
        .listen((_) => print('Throttled click'));

    // 3. SwitchMap - cancel previous operations
    final queryController = StreamController<String>();
    queryController.stream
        .switchMap((query) => _searchApi(query))
        .listen((results) => print('Search results: $results'));

    // 4. MergeMap - run concurrently
    final itemController = StreamController<int>();
    itemController.stream
        .mergeMap((item) => _processItem(item))
        .listen((processed) => print('Processed: $processed'));

    // 5. Combine streams
    final stream1 = Stream.periodic(const Duration(seconds: 1), (i) => i);
    final stream2 = Stream.periodic(const Duration(seconds: 2), (i) => i * 10);
    stream1
        .combineWith(stream2, (a, b) => a + b)
        .listen((combined) => print('Combined: $combined'));

    // 6. Cache latest value
    final dataStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    dataStream.cacheLatest().listen((value) => print('Cached: $value'));

    // 7. Retry with backoff
    _unreliableStream()
        .retryWithBackoff(maxRetries: 3)
        .listen((value) => print('Retry result: $value'));

    // 8. Group by key
    final itemStream = Stream.fromIterable([
      {'category': 'food', 'value': 100},
      {'category': 'transport', 'value': 50},
      {'category': 'food', 'value': 200},
    ]);
    itemStream
        .groupBy((item) => item['category'] as String)
        .listen((group) => print('Group: $group'));
  }

  Stream<List<String>> _searchApi(String query) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield ['Result 1 for $query', 'Result 2 for $query'];
  }

  Stream<String> _processItem(int item) async* {
    await Future.delayed(const Duration(milliseconds: 100));
    yield 'Processed item $item';
  }

  Stream<int> _unreliableStream() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    if (DateTime.now().millisecond % 2 == 0) {
      throw Exception('Stream error');
    }
    yield 42;
  }
}

/// Demo: All BindX Annotations in use:
///
/// 1. @Cache - Used in ExpenseStore methods:
///    - getTotalExpenses()
///    - getExpensesByCategory()
///    - getMonthlyStatistics()
///    - getBudgetStatus()
///
/// 2. @Concurrent - Used in ExpenseStore methods:
///    - addExpense()
///    - deleteExpense()
///    - bulkAddExpenses()
///    - syncWithCloud()
///
/// 3. @Streamed - Used in ExpenseStore:
///    - totalStream
///    - filteredExpensesStream
///    - categoryStatsStream
///
/// 4. @Validate - Can be added to any method for validation
///    (Not demonstrated in current version but available)

/// Summary of BindX Features Used in This App:
///
/// ✅ 1. BindXStore - Core state management (ExpenseStore)
/// ✅ 2. @Cache - Method result caching with different strategies
/// ✅ 3. @Concurrent - Concurrency control with debounce
/// ✅ 4. @Streamed - Reactive stream properties
/// ✅ 5. Stream Extensions - debounce, throttle, switchMap, etc.
/// ✅ 6. Future Extensions - retry, timeout, asResult, tap
/// ✅ 7. Registry - Global store registration and lookup
/// ✅ 8. BindXProvider - Provider widget for dependency injection
/// ✅ 9. MultiBindXProvider - Multiple store providers
/// ✅ 10. BindXConsumer - Consumer widget for rebuilding on changes
/// ✅ 11. BindXMultiBuilder - Building from multiple stores
