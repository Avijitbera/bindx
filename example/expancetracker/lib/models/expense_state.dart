import 'expense.dart';

class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final String? selectedCategory;
  final String searchQuery;

  ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    this.selectedCategory,
    this.searchQuery = '',
  });

  factory ExpenseState.initial() {
    return ExpenseState(
      expenses: const [],
      isLoading: false,
      selectedDate: DateTime.now(),
      searchQuery: '',
    );
  }

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    String? selectedCategory,
    String? searchQuery,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'selectedDate': selectedDate.toIso8601String(),
      'selectedCategory': selectedCategory,
      'searchQuery': searchQuery,
    };
  }

  factory ExpenseState.fromJson(Map<String, dynamic> json) {
    return ExpenseState(
      expenses:
          (json['expenses'] as List?)
              ?.map((e) => Expense.fromJson(e))
              .toList() ??
          [],
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'])
          : DateTime.now(),
      selectedCategory: json['selectedCategory'],
      searchQuery: json['searchQuery'] ?? '',
    );
  }
}
