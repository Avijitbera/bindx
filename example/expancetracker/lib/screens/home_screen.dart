import 'package:flutter/material.dart';
import 'package:bindx/bindx.dart';
import 'package:intl/intl.dart';
import '../stores/expense_store.dart';
import '../models/category.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ExpenseListView(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Expenses'),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }
}

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Using BindXConsumer to rebuild when store changes
    return BindXConsumer(
      storeTypes: [ExpenseStore],
      builder: (context) {
        final store = BindXProvider.of<ExpenseStore>(context);
        final state = store.state;

        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Expense Tracker'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () async {
                    final success = await store.syncWithCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Synced successfully' : 'Sync failed',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  hintText: 'Search expenses...',
                  leading: const Icon(Icons.search),
                  onChanged: (query) {
                    store.searchExpenses(query);
                  },
                  trailing: state.searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              store.clearFilters();
                            },
                          ),
                        ]
                      : null,
                ),
              ),
            ),

            // Category filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: Categories.all.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: state.selectedCategory == null,
                          onSelected: (_) {
                            store.filterByCategory(null);
                          },
                        ),
                      );
                    }

                    final category = Categories.all[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 16,
                              color: category.color,
                            ),
                            const SizedBox(width: 4),
                            Text(category.name),
                          ],
                        ),
                        selected: state.selectedCategory == category.id,
                        onSelected: (_) {
                          store.filterByCategory(
                            state.selectedCategory == category.id
                                ? null
                                : category.id,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Total expenses card with StreamBuilder
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<double>(
                  stream: store.totalStream,
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? 0.0;
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Expenses',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const LinearProgressIndicator(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Loading indicator
            if (state.isLoading)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),

            // Error message
            if (state.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => store.clearError(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Expenses list using StreamBuilder for reactive updates
            StreamBuilder<List<Expense>>(
              stream: store.filteredExpensesStream,
              builder: (context, snapshot) {
                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first expense',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Group expenses by date
                final groupedExpenses = <String, List<Expense>>{};
                for (var expense in expenses) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
                  groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
                }

                final sortedDates = groupedExpenses.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final dateKey = sortedDates[index];
                    final dateExpenses = groupedExpenses[dateKey]!;
                    final date = DateTime.parse(dateKey);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _formatDate(date),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        ...dateExpenses.map((expense) {
                          return ExpenseListTile(
                            expense: expense,
                            onDelete: () => store.deleteExpense(expense.id),
                            onTap: () {
                              // Navigate to edit screen or show details
                            },
                          );
                        }),
                      ],
                    );
                  }, childCount: sortedDates.length),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }
}

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = Categories.getById(expense.category);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: category.color.withOpacity(0.2),
            child: Icon(category.icon, color: category.color),
          ),
          title: Text(
            expense.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name),
              if (expense.notes != null && expense.notes!.isNotEmpty)
                Text(
                  expense.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${expense.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(expense.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          isThreeLine: expense.notes != null && expense.notes!.isNotEmpty,
        ),
      ),
    );
  }
}
