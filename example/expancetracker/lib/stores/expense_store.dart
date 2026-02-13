import 'dart:async';
import 'package:bindx/bindx.dart';
import '../models/expense.dart';
import '../models/expense_state.dart';
import '../models/category.dart';

/// ExpenseStore demonstrates BindX features with the actual API:
/// 1. BindXStore - Core state management
/// 2. @Cache - Method result caching
/// 3. @Concurrent - Concurrency control
/// 4. @Streamed - Reactive streams
/// 5. Stream extensions - debounce, throttle, etc.
/// 6. Future extensions - retry, timeout, etc.
class ExpenseStore extends BindXStore<ExpenseState> {
  final StreamController<String> _searchController = StreamController<String>();
  final StreamController<Expense> _expenseAddedController =
      StreamController<Expense>.broadcast();

  ExpenseStore() : super(ExpenseState.initial()) {
    // Setup search with debounce (Stream Extension feature)
    _searchController.stream
        .debounce(const Duration(milliseconds: 300))
        .distinct()
        .listen((query) {
          update((current) => current.copyWith(searchQuery: query));
        });

    // Example of stream transformation using BindX extensions
    _expenseAddedController.stream
        .throttle(const Duration(milliseconds: 500))
        .listen((expense) {
          print('New expense added: ${expense.title}');
        });
  }

  // ==================== BASIC CRUD OPERATIONS ====================

  /// Add a new expense with concurrent execution control
  @Concurrent(maxConcurrent: 3)
  Future<void> addExpense(Expense expense) async {
    // Simulate API call with retry and timeout (Future Extensions)
    await BindXAsync.executeWithRetry(
      () async {
        await Future.delayed(const Duration(milliseconds: 300));
        await update(
          (current) => current.copyWith(
            expenses: [...current.expenses, expense],
            clearError: true,
          ),
        );
        _expenseAddedController.add(expense);
      },
      maxRetries: 3,
      timeout: const Duration(seconds: 5),
    );
  }

  /// Update an existing expense
  Future<void> updateExpense(String id, Expense updatedExpense) async {
    await update((current) {
      final expenses = current.expenses.map((exp) {
        return exp.id == id ? updatedExpense : exp;
      }).toList();

      return current.copyWith(expenses: expenses);
    });
  }

  /// Delete an expense with debouncing to prevent accidental rapid deletions
  @Concurrent(
    maxConcurrent: 1,
    debounce: true,
    debounceDuration: Duration(milliseconds: 200),
  )
  Future<void> deleteExpense(String id) async {
    await update((current) {
      final expenses = current.expenses.where((exp) => exp.id != id).toList();
      return current.copyWith(expenses: expenses);
    });
  }

  // ==================== CACHED COMPUTATIONS (@Cache Annotation) ====================

  /// Get total expenses - cached for 30 seconds
  @Cache(duration: Duration(seconds: 30), tag: 'statistics')
  Future<double> getTotalExpenses() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simulate computation
    return state.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }

  /// Get expenses by category - cached with disk persistence
  @Cache(duration: Duration(minutes: 5), persist: true, tag: 'category-stats')
  Future<Map<String, double>> getExpensesByCategory() async {
    await Future.delayed(const Duration(milliseconds: 150));

    final Map<String, double> categoryTotals = {};
    for (var expense in state.expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  /// Get monthly statistics - cached for 1 minute
  @Cache(duration: Duration(minutes: 1), tag: 'monthly-stats')
  Future<Map<String, dynamic>> getMonthlyStatistics(DateTime month) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final monthExpenses = state.expenses.where((exp) {
      return exp.date.year == month.year && exp.date.month == month.month;
    }).toList();

    return {
      'total': monthExpenses.fold<double>(0.0, (sum, exp) => sum + exp.amount),
      'count': monthExpenses.length,
      'average': monthExpenses.isEmpty
          ? 0.0
          : monthExpenses.fold<double>(0.0, (sum, exp) => sum + exp.amount) /
                monthExpenses.length,
      'highest': monthExpenses.isEmpty
          ? 0.0
          : monthExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b),
    };
  }

  /// Get budget status per category - memory first cache strategy
  @Cache(duration: Duration(seconds: 45), tag: 'budget-status')
  Future<Map<String, Map<String, dynamic>>> getBudgetStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final categoryExpenses = await getExpensesByCategory();
    final Map<String, Map<String, dynamic>> budgetStatus = {};

    for (var category in Categories.all) {
      final spent = categoryExpenses[category.id] ?? 0;
      final limit = category.budgetLimit;
      final percentage = limit > 0 ? (spent / limit) * 100 : 0.0;

      budgetStatus[category.id] = {
        'spent': spent,
        'limit': limit,
        'percentage': percentage,
        'isOverBudget': spent > limit && limit > 0,
        'remaining': limit - spent,
      };
    }

    return budgetStatus;
  }

  // ==================== STREAMED PROPERTIES (@Streamed Annotation) ====================

  /// Stream of total expenses that updates reactively
  @Streamed(broadcast: true)
  Stream<double> get totalStream {
    return stream.asyncMap((_) async => await getTotalExpenses());
  }

  /// Stream of filtered expenses based on search and category
  @Streamed(broadcast: true)
  Stream<List<Expense>> get filteredExpensesStream {
    return stream.map((state) {
      var filtered = state.expenses;

      // Apply search filter
      if (state.searchQuery.isNotEmpty) {
        filtered = filtered.where((exp) {
          return exp.title.toLowerCase().contains(
                state.searchQuery.toLowerCase(),
              ) ||
              (exp.notes?.toLowerCase().contains(
                    state.searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }

      // Apply category filter
      if (state.selectedCategory != null) {
        filtered = filtered
            .where((exp) => exp.category == state.selectedCategory)
            .toList();
      }

      return filtered;
    });
  }

  /// Stream of category statistics
  @Streamed(broadcast: true)
  Stream<Map<String, double>> get categoryStatsStream {
    return stream.asyncMap((_) async => await getExpensesByCategory());
  }

  // ==================== SEARCH & FILTER ====================

  /// Search expenses with debouncing
  void searchExpenses(String query) {
    _searchController.add(query);
  }

  /// Filter by category
  Future<void> filterByCategory(String? categoryId) async {
    await update(
      (current) => current.copyWith(
        selectedCategory: categoryId,
        clearCategory: categoryId == null,
      ),
    );
  }

  /// Filter by date range
  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    await update((current) {
      final filtered = current.expenses.where((exp) {
        return exp.date.isAfter(start.subtract(const Duration(days: 1))) &&
            exp.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();

      return current.copyWith(expenses: filtered);
    });
  }

  /// Set selected date
  Future<void> setSelectedDate(DateTime date) async {
    await update((current) => current.copyWith(selectedDate: date));
  }

  // ==================== ADVANCED ASYNC OPERATIONS ====================

  /// Bulk add expenses with concurrent execution control
  @Concurrent(maxConcurrent: 5, queueKey: 'bulk-operations')
  Future<void> bulkAddExpenses(List<Expense> expenses) async {
    await update((current) => current.copyWith(isLoading: true));

    try {
      // Process in batches with Future extensions
      for (var expense in expenses) {
        await addExpense(expense);
      }

      await update(
        (current) => current.copyWith(isLoading: false, clearError: true),
      );
    } catch (e) {
      await update(
        (current) => current.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Export data with timeout
  Future<String> exportData() async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => 'Export completed',
    ).timeoutAfter(
      const Duration(seconds: 5),
      onTimeout: () => 'Export timed out',
    );
  }

  /// Sync with cloud using retry with backoff
  @Concurrent(maxConcurrent: 1)
  Future<bool> syncWithCloud() async {
    await update((current) => current.copyWith(isLoading: true));

    try {
      final result = await BindXAsync.executeWithRetry(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          // Simulate API call
          return true;
        },
        maxRetries: 3,
        timeout: const Duration(seconds: 10),
      );

      await update((current) => current.copyWith(isLoading: false));
      return result;
    } catch (e) {
      await update(
        (current) =>
            current.copyWith(isLoading: false, error: 'Sync failed: $e'),
      );
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all filters
  Future<void> clearFilters() async {
    await update(
      (current) => current.copyWith(searchQuery: '', clearCategory: true),
    );
    _searchController.add('');
  }

  /// Clear error
  Future<void> clearError() async {
    await update((current) => current.copyWith(clearError: true));
  }

  /// Get expenses for a specific month
  List<Expense> getExpensesForMonth(DateTime month) {
    return state.expenses.where((exp) {
      return exp.date.year == month.year && exp.date.month == month.month;
    }).toList();
  }

  /// Get recent expenses (last N days)
  List<Expense> getRecentExpenses(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return state.expenses.where((exp) => exp.date.isAfter(cutoffDate)).toList();
  }

  /// Invalidate specific cache tag
  Future<void> invalidateCache(String tag) async {
    // This would invalidate caches with the specified tag
    print('Invalidating cache with tag: $tag');
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _searchController.close();
    _expenseAddedController.close();
    super.dispose();
  }
}
