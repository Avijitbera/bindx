import 'package:flutter/material.dart';
// import '../stores/api_store.dart';
// Uncomment the import above after running code generation

class ApiDemoScreen extends StatefulWidget {
  const ApiDemoScreen({super.key});

  @override
  State<ApiDemoScreen> createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends State<ApiDemoScreen> {
  // Uncomment after code generation:
  // late final ApiStore _apiStore;

  final List<String> _logs = [];
  bool _isLoading = false;
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    // Uncomment after code generation:
    // _apiStore = ApiStore();
    _addLog('API Store initialized');
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} - $message',
      );
      if (_logs.length > 20) {
        _logs.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Store Demo'), elevation: 0),
      body: SafeArea(
        child: ListView(
          children: [
            // Stats Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.api,
                            label: 'API Calls',
                            value: _requestCount.toString(),
                          ),
                          _StatItem(
                            icon: Icons.speed,
                            label: 'Status',
                            value: _isLoading ? 'Loading' : 'Idle',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cached API Data
                  _SectionHeader(
                    icon: Icons.cached,
                    title: 'Cached API Calls',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    _addLog(
                                      'Fetching cached API data (5 min cache)...',
                                    );
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                      _requestCount++;
                                    });
                                    _addLog('✓ Cached data retrieved');
                                  },
                            icon: const Icon(Icons.download),
                            label: const Text('Get Cached Data'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cached for 5 minutes with disk persistence',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Concurrent Operations
                  _SectionHeader(
                    icon: Icons.sync,
                    title: 'Concurrent Operations',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    _addLog(
                                      'Fetching data (debounced, max 3 concurrent)...',
                                    );
                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                      _requestCount++;
                                    });
                                    _addLog('✓ Data fetched from /api/users');
                                  },
                            icon: const Icon(Icons.people),
                            label: const Text('Fetch Users (Debounced)'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    _addLog(
                                      'Throttled API call (max 1 per 2s)...',
                                    );
                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );
                                    setState(() => _requestCount++);
                                    _addLog('✓ Throttled call completed');
                                  },
                            icon: const Icon(Icons.speed),
                            label: const Text('Throttled Call'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Debouncing prevents rapid successive calls',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Retry Logic
                  _SectionHeader(
                    icon: Icons.replay,
                    title: 'Retry Logic',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    _addLog(
                                      'Fetching with retry (max 5 attempts)...',
                                    );

                                    // Simulate retries
                                    for (int i = 1; i <= 3; i++) {
                                      await Future.delayed(
                                        const Duration(milliseconds: 600),
                                      );
                                      if (i < 3) {
                                        _addLog(
                                          '⚠ Attempt $i failed, retrying...',
                                        );
                                      } else {
                                        _addLog('✓ Success on attempt $i');
                                      }
                                    }

                                    setState(() {
                                      _isLoading = false;
                                      _requestCount++;
                                    });
                                  },
                            icon: const Icon(Icons.autorenew),
                            label: const Text('Fetch with Retry'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Automatically retries on failure (500ms delay)',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timeout
                  _SectionHeader(
                    icon: Icons.timer,
                    title: 'Timeout Handling',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    _addLog(
                                      'Calling slow endpoint (3s timeout)...',
                                    );
                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                      _requestCount++;
                                    });
                                    _addLog(
                                      '✓ Slow endpoint responded in time',
                                    );
                                  },
                            icon: const Icon(Icons.hourglass_bottom),
                            label: const Text('Slow Endpoint'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Times out after 3 seconds',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Complex Operation
                  _SectionHeader(
                    icon: Icons.settings,
                    title: 'Combined Features',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    _addLog(
                                      'Complex API call (concurrent + retry + timeout)...',
                                    );
                                    await Future.delayed(
                                      const Duration(milliseconds: 1500),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                      _requestCount++;
                                    });
                                    _addLog('✓ Complex operation completed');
                                  },
                            icon: const Icon(Icons.rocket_launch),
                            label: const Text('Complex API Call'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Combines concurrency, retry, and timeout',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logs Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionHeader(
                          icon: Icons.article,
                          title: 'Activity Log',
                          color: Colors.teal,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _logs.clear());
                            _addLog('Logs cleared');
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Card(
                        child: _logs.isEmpty
                            ? Center(
                                child: Text(
                                  'No activity yet',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                itemCount: _logs.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  final isSuccess = log.contains('✓');
                                  final isWarning = log.contains('⚠');

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          isSuccess
                                              ? Icons.check_circle
                                              : isWarning
                                              ? Icons.warning
                                              : Icons.info,
                                          size: 16,
                                          color: isSuccess
                                              ? Colors.green
                                              : isWarning
                                              ? Colors.orange
                                              : Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            log,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
