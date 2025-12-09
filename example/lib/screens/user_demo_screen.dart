import 'package:flutter/material.dart';
// import '../stores/user_store.dart';
// Uncomment the import above after running code generation

class UserDemoScreen extends StatefulWidget {
  const UserDemoScreen({super.key});

  @override
  State<UserDemoScreen> createState() => _UserDemoScreenState();
}

class _UserDemoScreenState extends State<UserDemoScreen> {
  // Uncomment after code generation:
  // late final UserStore _userStore;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Uncomment after code generation:
    // _userStore = UserStore(
    //   name: 'John Doe',
    //   email: 'john@example.com',
    //   age: 30,
    // );
    _nameController.text = 'John Doe';
    _ageController.text = '30';
    _emailController.text = 'john@example.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Store Demo'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Code Generation Required',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Run the following command to generate the required code:',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'flutter pub run build_runner build',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Then uncomment the code in this file to see the demo in action.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // User Info Section
              _SectionHeader(
                icon: Icons.person,
                title: 'User Information',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (with validation)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cached Getters Section
              _SectionHeader(
                icon: Icons.cached,
                title: 'Cached Getters',
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: 'Full Name (cached 10 min)',
                        value: 'John Doe (Age: 30)',
                        icon: Icons.badge,
                      ),
                      const Divider(),
                      _InfoRow(
                        label: 'User Profile (cached 1 hour, persisted)',
                        value: 'Name: John Doe, Email: john@example.com...',
                        icon: Icons.account_circle,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Concurrent Operations Section
              _SectionHeader(
                icon: Icons.sync,
                title: 'Concurrent Operations',
                color: Colors.purple,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _statusMessage =
                                      'Updating profile with debouncing...';
                                });
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );
                                setState(() {
                                  _isLoading = false;
                                  _statusMessage =
                                      'Profile updated successfully!';
                                });
                              },
                        icon: const Icon(Icons.update),
                        label: const Text('Update Profile (Debounced)'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _statusMessage =
                                      'Incrementing login count with throttling...';
                                });
                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );
                                setState(() {
                                  _isLoading = false;
                                  _statusMessage = 'Login count incremented!';
                                });
                              },
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Increment Login (Throttled)'),
                      ),
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Retry & Timeout Section
              _SectionHeader(
                icon: Icons.replay,
                title: 'Retry & Timeout',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _statusMessage =
                                      'Fetching user data (with retry)...';
                                });
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );
                                setState(() {
                                  _isLoading = false;
                                  _statusMessage =
                                      'Data fetched successfully after retries!';
                                });
                              },
                        icon: const Icon(Icons.download),
                        label: const Text('Fetch Data (Max 3 Retries)'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _statusMessage =
                                      'Running long task (5s timeout)...';
                                });
                                await Future.delayed(
                                  const Duration(seconds: 3),
                                );
                                setState(() {
                                  _isLoading = false;
                                  _statusMessage =
                                      'Long task completed within timeout!';
                                });
                              },
                        icon: const Icon(Icons.timer),
                        label: const Text('Long Running Task (5s Timeout)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mutex Section
              _SectionHeader(
                icon: Icons.lock,
                title: 'Mutex Protected',
                color: Colors.red,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _statusMessage =
                                      'Performing critical update (mutex locked)...';
                                });
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
                                setState(() {
                                  _isLoading = false;
                                  _statusMessage =
                                      'Critical update completed safely!';
                                });
                              },
                        icon: const Icon(Icons.security),
                        label: const Text('Critical Update (Mutex)'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This operation is protected by a mutex lock to ensure thread-safe execution.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
