import 'package:flutter/material.dart';
import 'package:bindx/bindx.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../stores/expense_store.dart';
import '../models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BindXConsumer(
      storeTypes: [ExpenseStore],
      builder: (context) {
        final store = BindXProvider.of<ExpenseStore>(context);

        return CustomScrollView(
          slivers: [
            SliverAppBar.large(title: const Text('Statistics')),

            // Month selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedMonth),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              _selectedMonth.month == DateTime.now().month &&
                                  _selectedMonth.year == DateTime.now().year
                              ? null
                              : () {
                                  setState(() {
                                    _selectedMonth = DateTime(
                                      _selectedMonth.year,
                                      _selectedMonth.month + 1,
                                    );
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Monthly statistics using @Cache
            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, dynamic>>(
                future: store.getMonthlyStatistics(_selectedMonth),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final stats = snapshot.data ?? {};
                  final total = stats['total'] ?? 0.0;
                  final count = stats['count'] ?? 0;
                  final average = stats['average'] ?? 0.0;
                  final highest = stats['highest'] ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total',
                                value: '₹${total.toStringAsFixed(2)}',
                                icon: Icons.account_balance_wallet,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                title: 'Count',
                                value: count.toString(),
                                icon: Icons.receipt,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Average',
                                value: '₹${average.toStringAsFixed(2)}',
                                icon: Icons.trending_up,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                title: 'Highest',
                                value: '₹${highest.toStringAsFixed(2)}',
                                icon: Icons.arrow_upward,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Category breakdown with StreamBuilder
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category Breakdown',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<Map<String, double>>(
                          stream: store.categoryStatsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final categoryData = snapshot.data ?? {};
                            if (categoryData.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('No data available'),
                                ),
                              );
                            }

                            return SizedBox(
                              height: 250,
                              child: PieChart(
                                PieChartData(
                                  sections: categoryData.entries.map((entry) {
                                    final category = Categories.getById(
                                      entry.key,
                                    );
                                    final total = categoryData.values.reduce(
                                      (a, b) => a + b,
                                    );
                                    final percentage =
                                        (entry.value / total) * 100;

                                    return PieChartSectionData(
                                      value: entry.value,
                                      title:
                                          '${percentage.toStringAsFixed(1)}%',
                                      color: category.color,
                                      radius: 100,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<Map<String, double>>(
                          stream: store.categoryStatsStream,
                          builder: (context, snapshot) {
                            final categoryData = snapshot.data ?? {};
                            return Column(
                              children: categoryData.entries.map((entry) {
                                final category = Categories.getById(entry.key);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: category.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(category.icon, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(category.name)),
                                      Text(
                                        '₹${entry.value.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Budget status using @Cache
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<Map<String, Map<String, dynamic>>>(
                          future: store.getBudgetStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final budgetData = snapshot.data ?? {};

                            return Column(
                              children: Categories.all.map((category) {
                                final data = budgetData[category.id] ?? {};
                                final spent = data['spent'] ?? 0.0;
                                final limit = data['limit'] ?? 0.0;
                                final percentage = data['percentage'] ?? 0.0;
                                final isOverBudget =
                                    data['isOverBudget'] ?? false;
                                final remaining = data['remaining'] ?? 0.0;

                                if (limit == 0) return const SizedBox.shrink();

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            category.icon,
                                            size: 20,
                                            color: category.color,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(category.name)),
                                          Text(
                                            '₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isOverBudget
                                                  ? Colors.red
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: (percentage / 100).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                        color: isOverBudget
                                            ? Colors.red
                                            : percentage > 80
                                            ? Colors.orange
                                            : category.color,
                                        minHeight: 8,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isOverBudget
                                            ? 'Over budget by ₹${(-remaining).toStringAsFixed(2)}'
                                            : 'Remaining: ₹${remaining.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isOverBudget
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
