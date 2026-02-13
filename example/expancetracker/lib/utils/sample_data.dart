import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/category.dart';

/// Sample data generator for demonstration purposes
class SampleDataGenerator {
  static final _random = Random();
  static const _uuid = Uuid();

  /// Generate random expenses for testing
  static List<Expense> generateSampleExpenses(int count) {
    final expenses = <Expense>[];
    final now = DateTime.now();

    final titles = {
      Categories.food.id: [
        'Breakfast at cafe',
        'Lunch with team',
        'Dinner at restaurant',
        'Grocery shopping',
        'Coffee break',
        'Snacks',
        'Pizza delivery',
        'Burger meal',
      ],
      Categories.transport.id: [
        'Uber ride',
        'Fuel refill',
        'Metro card recharge',
        'Parking fee',
        'Bus ticket',
        'Auto fare',
        'Bike maintenance',
      ],
      Categories.shopping.id: [
        'Clothes shopping',
        'Electronics purchase',
        'Books',
        'Gadget accessories',
        'Home decor',
        'Shoes',
        'Online shopping',
      ],
      Categories.entertainment.id: [
        'Movie tickets',
        'Concert',
        'Gaming subscription',
        'Streaming service',
        'Sports event',
        'Theme park',
        'Weekend trip',
      ],
      Categories.bills.id: [
        'Electricity bill',
        'Water bill',
        'Internet bill',
        'Mobile recharge',
        'Rent payment',
        'Gas bill',
        'Credit card payment',
      ],
      Categories.health.id: [
        'Medicine',
        'Doctor consultation',
        'Gym membership',
        'Vitamins',
        'Health checkup',
        'Dental care',
        'Medical tests',
      ],
      Categories.education.id: [
        'Course fee',
        'Books purchase',
        'Online course',
        'Certification exam',
        'Workshop',
        'Tutoring',
        'Study materials',
      ],
      Categories.other.id: [
        'Miscellaneous',
        'Gift',
        'Donation',
        'Pet care',
        'Repairs',
        'Maintenance',
        'Emergency',
      ],
    };

    for (int i = 0; i < count; i++) {
      final category = Categories.all[_random.nextInt(Categories.all.length)];
      final categoryTitles = titles[category.id]!;
      final title = categoryTitles[_random.nextInt(categoryTitles.length)];

      // Generate random date within last 60 days
      final daysAgo = _random.nextInt(60);
      final date = now.subtract(
        Duration(
          days: daysAgo,
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ),
      );

      // Generate amount based on category typical ranges
      final amount = _generateAmountForCategory(category);

      final expense = Expense(
        id: _uuid.v4(),
        title: title,
        amount: amount,
        category: category.id,
        date: date,
        notes: _random.nextBool() ? _generateNotes() : null,
        isRecurring: _random.nextInt(10) == 0, // 10% chance of recurring
      );

      expenses.add(expense);
    }

    // Sort by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));

    return expenses;
  }

  static double _generateAmountForCategory(ExpenseCategory category) {
    // Different categories have different typical price ranges
    final ranges = {
      Categories.food.id: (50.0, 500.0),
      Categories.transport.id: (30.0, 300.0),
      Categories.shopping.id: (200.0, 2000.0),
      Categories.entertainment.id: (100.0, 1000.0),
      Categories.bills.id: (500.0, 5000.0),
      Categories.health.id: (100.0, 2000.0),
      Categories.education.id: (500.0, 10000.0),
      Categories.other.id: (50.0, 1000.0),
    };

    final range = ranges[category.id] ?? (50.0, 500.0);
    final amount = range.$1 + _random.nextDouble() * (range.$2 - range.$1);

    // Round to 2 decimal places
    return (amount * 100).round() / 100;
  }

  static String _generateNotes() {
    final notes = [
      'Paid by credit card',
      'Cash payment',
      'Split with friend',
      'Business expense',
      'Personal',
      'Urgent purchase',
      'On sale',
      'Monthly subscription',
      'One-time payment',
      'Shared expense',
    ];

    return notes[_random.nextInt(notes.length)];
  }

  /// Generate expenses for a specific month
  static List<Expense> generateMonthExpenses(DateTime month, int count) {
    final expenses = <Expense>[];

    for (int i = 0; i < count; i++) {
      final category = Categories.all[_random.nextInt(Categories.all.length)];

      // Random day in the month
      final day = 1 + _random.nextInt(28); // Safe for all months
      final date = DateTime(
        month.year,
        month.month,
        day,
        _random.nextInt(24),
        _random.nextInt(60),
      );

      final expense = Expense(
        id: _uuid.v4(),
        title: 'Sample ${category.name} expense',
        amount: _generateAmountForCategory(category),
        category: category.id,
        date: date,
      );

      expenses.add(expense);
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  /// Generate a specific number of expenses per category
  static List<Expense> generateBalancedExpenses(int expensesPerCategory) {
    final expenses = <Expense>[];
    final now = DateTime.now();

    for (final category in Categories.all) {
      for (int i = 0; i < expensesPerCategory; i++) {
        final daysAgo = _random.nextInt(30);
        final date = now.subtract(
          Duration(days: daysAgo, hours: _random.nextInt(24)),
        );

        final expense = Expense(
          id: _uuid.v4(),
          title: '${category.name} expense ${i + 1}',
          amount: _generateAmountForCategory(category),
          category: category.id,
          date: date,
        );

        expenses.add(expense);
      }
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }
}
