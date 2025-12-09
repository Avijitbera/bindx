import 'package:flutter/material.dart';
// import '../stores/form_store.dart';
// Uncomment the import above after running code generation

class FormDemoScreen extends StatefulWidget {
  const FormDemoScreen({super.key});

  @override
  State<FormDemoScreen> createState() => _FormDemoScreenState();
}

class _FormDemoScreenState extends State<FormDemoScreen> {
  // Uncomment after code generation:
  // late final FormStore _formStore;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isSubmitting = false;
  String? _validationError;
  bool _formValid = false;

  @override
  void initState() {
    super.initState();
    // Uncomment after code generation:
    // _formStore = FormStore();

    // Add listeners to validate form
    _usernameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _ageController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _formValid =
          _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _ageController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _showValidationError(String message) {
    setState(() => _validationError = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _validationError = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Store Demo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _usernameController.clear();
              _emailController.clear();
              _passwordController.clear();
              _websiteController.clear();
              _ageController.clear();
              setState(() {
                _validationError = null;
                _formValid = false;
              });
            },
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Status Card
              Card(
                color: _formValid
                    ? Colors.green.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _formValid ? Icons.check_circle : Icons.edit_document,
                        color: _formValid
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formValid ? 'Form Valid' : 'Fill in the form',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formValid
                                  ? 'All fields are valid and ready to submit'
                                  : 'Complete all required fields with valid data',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Validation Error
              if (_validationError != null) ...[
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Form Fields
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username with validation
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username *',
                          hintText: 'Enter your username',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person_outline),
                          suffixIcon: _usernameController.text.isNotEmpty
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _showValidationError('Username cannot be empty');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Validated: Not empty',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email with validation
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          hintText: 'user@example.com',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon: _emailController.text.contains('@')
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (value.isNotEmpty && !value.contains('@')) {
                            _showValidationError('Invalid email format');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Validated: Not empty, Email format',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password with validation
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          hintText: 'Minimum 6 characters',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: _passwordController.text.length >= 6
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          if (value.isNotEmpty && value.length < 6) {
                            _showValidationError(
                              'Password must be at least 6 characters',
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Validated: Not empty, Min length (6)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Age with validation
                      TextField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'Age *',
                          hintText: 'Must be 18 or older',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon:
                              (_ageController.text.isNotEmpty &&
                                  int.tryParse(_ageController.text) != null &&
                                  int.parse(_ageController.text) >= 18)
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final age = int.tryParse(value);
                          if (age != null && age < 18) {
                            _showValidationError('Age must be 18 or older');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Validated: Min value (18)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Optional Fields
              _SectionHeader(
                icon: Icons.web,
                title: 'Optional Information',
                color: Colors.purple,
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _websiteController,
                        decoration: InputDecoration(
                          labelText: 'Website (Optional)',
                          hintText: 'https://example.com',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.language),
                          suffixIcon: _websiteController.text.startsWith('http')
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (value) {
                          if (value.isNotEmpty && !value.startsWith('http')) {
                            _showValidationError('Website must be a valid URL');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Validated: URL format',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reactive Streams Info
              _SectionHeader(
                icon: Icons.stream,
                title: 'Reactive Streams',
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
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
                            ).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Streamed Properties',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Username, Email, and Password fields are streamed properties. '
                        'After code generation, you can subscribe to their streams for reactive UI updates.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: (_formValid && !_isSubmitting)
                    ? () async {
                        setState(() => _isSubmitting = true);

                        // Simulate form submission with debouncing
                        await Future.delayed(const Duration(seconds: 2));

                        if (mounted) {
                          setState(() => _isSubmitting = false);

                          // Show success dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                              title: const Text('Success!'),
                              content: const Text(
                                'Form submitted successfully with debouncing to prevent multiple submissions.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Reset form
                                    _usernameController.clear();
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _websiteController.clear();
                                    _ageController.clear();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Form (Debounced)',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Form submission is debounced (1 second) to prevent multiple submissions',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Features Info
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Features Demonstrated',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.check,
                        text: 'Real-time validation with multiple validators',
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                      _FeatureItem(
                        icon: Icons.check,
                        text: 'Reactive streams for form fields',
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                      _FeatureItem(
                        icon: Icons.check,
                        text: 'Debounced form submission',
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                      _FeatureItem(
                        icon: Icons.check,
                        text: 'Cached form validation state',
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
