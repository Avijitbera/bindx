import 'package:flutter/material.dart';
import 'package:bindx/bindx.dart';
import '../stores/expense_store.dart';
import '../utils/sample_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Developer Tools Section
          _SectionHeader(
            title: 'Developer Tools',
            icon: Icons.code,
            color: Colors.blue,
          ),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Load Sample Data'),
            subtitle: const Text('Generate 50 random expenses'),
            trailing: const Icon(Icons.add),
            onTap: () async {
              final store = BindXProvider.of<ExpenseStore>(
                context,
                listen: false,
              );
              final expenses = SampleDataGenerator.generateSampleExpenses(50);

              await store.bulkAddExpenses(expenses);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sample data loaded successfully'),
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.balance),
            title: const Text('Load Balanced Data'),
            subtitle: const Text('5 expenses per category'),
            trailing: const Icon(Icons.add),
            onTap: () async {
              final store = BindXProvider.of<ExpenseStore>(
                context,
                listen: false,
              );
              final expenses = SampleDataGenerator.generateBalancedExpenses(5);

              await store.bulkAddExpenses(expenses);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Balanced data loaded successfully'),
                  ),
                );
              }
            },
          ),

          const Divider(),

          // Cache Management Section
          _SectionHeader(
            title: 'Cache Management',
            icon: Icons.storage,
            color: Colors.orange,
          ),

          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Invalidate Statistics Cache'),
            subtitle: const Text('Force refresh cached statistics'),
            trailing: const Icon(Icons.delete_sweep),
            onTap: () async {
              final store = BindXProvider.of<ExpenseStore>(
                context,
                listen: false,
              );
              await store.invalidateCache('statistics');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Statistics cache invalidated')),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Invalidate Category Cache'),
            subtitle: const Text('Force refresh category statistics'),
            trailing: const Icon(Icons.delete_sweep),
            onTap: () async {
              final store = BindXProvider.of<ExpenseStore>(
                context,
                listen: false,
              );
              await store.invalidateCache('category-stats');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category cache invalidated')),
                );
              }
            },
          ),

          const Divider(),

          // Data Management Section
          _SectionHeader(
            title: 'Data Management',
            icon: Icons.data_usage,
            color: Colors.green,
          ),

          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Sync with Cloud'),
            subtitle: const Text('Upload local data to cloud'),
            trailing: const Icon(Icons.sync),
            onTap: () async {
              final store = BindXProvider.of<ExpenseStore>(
                context,
                listen: false,
              );

              // Show loading dialog
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
              }

              final success = await store.syncWithCloud();

              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Synced successfully' : 'Sync failed',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export all expenses to file'),
            trailing: const Icon(Icons.file_download),
            onTap: () async {
              final store = BindXProvider.of<ExpenseStore>(
                context,
                listen: false,
              );

              try {
                final result = await store.exportData();

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Delete all expenses (cannot be undone)'),
            trailing: const Icon(Icons.warning, color: Colors.red),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data?'),
                  content: const Text(
                    'This will delete all expenses. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                final store = BindXProvider.of<ExpenseStore>(
                  context,
                  listen: false,
                );
                await store.update((current) => current.copyWith(expenses: []));

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                  Navigator.pop(context);
                }
              }
            },
          ),

          const Divider(),

          // BindX Features Section
          _SectionHeader(
            title: 'BindX Features',
            icon: Icons.settings,
            color: Colors.purple,
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('BindXStore'),
            subtitle: Text('Core reactive state management'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('@Cache Annotation'),
            subtitle: Text('Method result caching'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('@Concurrent Annotation'),
            subtitle: Text('Concurrency control'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('@Streamed Annotation'),
            subtitle: Text('Reactive stream properties'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Stream Extensions'),
            subtitle: Text('debounce, throttle, switchMap, etc.'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Future Extensions'),
            subtitle: Text('retry, timeout, asResult, etc.'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Middleware'),
            subtitle: Text('Logging & Persistence'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Global Registry'),
            subtitle: Text('Store registration & lookup'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('DevTools'),
            subtitle: Text('Debugging & monitoring'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Provider Widgets'),
            subtitle: Text('BindXProvider, Consumer, etc.'),
          ),

          const SizedBox(height: 16),

          // About Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This app showcases ALL features of the BindX state management library.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
