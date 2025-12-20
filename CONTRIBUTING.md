# Contributing to BindX

First off, thank you for considering contributing to BindX! It's people like you that make BindX such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide specific examples** with code snippets
* **Describe the behavior you observed** and what you expected
* **Include screenshots** if applicable
* **Specify Flutter and Dart versions**

#### Bug Report Template

```markdown
**Description**
A clear description of the bug.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Code Sample**
```dart
// Your code here
```

**Environment**
- BindX version:
- Flutter version:
- Dart version:
- Platform: [iOS/Android/Web/Desktop]

**Additional Context**
Any other relevant information.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a detailed description** of the suggested enhancement
* **Explain why this enhancement would be useful** to most BindX users
* **List some examples** of how it would be used
* **Provide code samples** if applicable

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding style** (see below)
3. **Write clear commit messages**
4. **Add tests** for new features
5. **Update documentation** if needed
6. **Ensure all tests pass**
7. **Submit your pull request**

#### Pull Request Template

```markdown
**Description**
Brief description of changes.

**Related Issue**
Fixes #(issue number)

**Type of Change**
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

**Checklist**
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where needed
- [ ] I have updated the documentation
- [ ] I have added tests
- [ ] All tests pass locally
- [ ] I have checked my code for any warnings

**Screenshots** (if applicable)

**Additional Notes**
```

## Development Setup

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK 3.9.2 or higher
- Git

### Setup Steps

1. **Clone your fork**

```bash
git clone https://github.com/YOUR_USERNAME/bindx.git
cd bindx
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run tests**

```bash
flutter test
```

4. **Run analyzer**

```bash
flutter analyze
```

### Project Structure

```
bindx/
├── lib/
│   ├── annotations.dart          # Public annotation exports
│   ├── bindx.dart                # Main library file
│   └── src/
│       ├── annotations/          # Annotation definitions
│       ├── caching/              # Cache engine and storage
│       ├── codegen/              # Code generation (if applicable)
│       ├── concurrency/          # Task management
│       ├── core/                 # Core store and registry
│       ├── devtools/             # Developer tools
│       ├── extensions/           # Stream and Future extensions
│       ├── middleware/           # Middleware system
│       ├── reactivity/           # Reactive utilities
│       ├── utils/                # Utility classes
│       └── widgets/              # Flutter widgets
├── test/                         # Unit and widget tests
├── example/                      # Example applications
└── pubspec.yaml
```

## Coding Style

### Dart Style Guide

We follow the [official Dart Style Guide](https://dart.dev/guides/language/effective-dart/style). Key points:

1. **Use `dartfmt`** to format your code:
   ```bash
   dart format .
   ```

2. **Follow naming conventions**:
   - Classes: `UpperCamelCase`
   - Variables/functions: `lowerCamelCase`
   - Constants: `lowerCamelCase`
   - Private members: prefix with `_`

3. **Use meaningful names**:
   ```dart
   // Good
   final userRepository = UserRepository();
   
   // Bad
   final ur = UserRepository();
   ```

4. **Keep functions small and focused**:
   ```dart
   // Good - Single responsibility
   Future<User> fetchUser(String id) async {
     return await api.getUser(id);
   }
   
   Future<void> updateUserProfile(User user) async {
     await api.updateUser(user);
     await cache.invalidate('user-${user.id}');
   }
   ```

5. **Document public APIs**:
   ```dart
   /// Fetches user data from the API.
   ///
   /// Returns a [User] object if found, throws [NotFoundException] if not.
   /// 
   /// Example:
   /// ```dart
   /// final user = await fetchUser('user-123');
   /// ```
   Future<User> fetchUser(String id) async {
     // ...
   }
   ```

### Code Organization

1. **Import ordering**:
   ```dart
   // Dart imports
   import 'dart:async';
   import 'dart:io';
   
   // Flutter imports
   import 'package:flutter/material.dart';
   
   // Package imports
   import 'package:http/http.dart';
   
   // Project imports
   import 'package:bindx/bindx.dart';
   import 'package:bindx/src/core/bindx_store.dart';
   ```

2. **Class member ordering**:
   ```dart
   class MyClass {
     // 1. Static constants
     static const String defaultName = 'Default';
     
     // 2. Static variables
     static int instanceCount = 0;
     
     // 3. Instance fields
     final String name;
     int _counter = 0;
     
     // 4. Constructors
     MyClass(this.name);
     
     // 5. Getters
     int get counter => _counter;
     
     // 6. Setters
     set counter(int value) => _counter = value;
     
     // 7. Public methods
     void increment() => _counter++;
     
     // 8. Private methods
     void _reset() => _counter = 0;
     
     // 9. Overridden methods
     @override
     String toString() => 'MyClass($name)';
   }
   ```

## Testing Guidelines

### Writing Tests

1. **Unit tests** for all business logic
2. **Widget tests** for UI components
3. **Integration tests** for complete workflows

### Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bindx/bindx.dart';

void main() {
  group('CounterStore', () {
    late CounterStore store;

    setUp(() {
      store = CounterStore();
    });

    tearDown(() {
      store.dispose();
    });

    test('initial state is correct', () {
      expect(store.state.count, 0);
      expect(store.state.isLoading, false);
    });

    test('increment increases count', () async {
      await store.increment();
      expect(store.state.count, 1);
      
      await store.increment();
      expect(store.state.count, 2);
    });

    test('stream emits state changes', () async {
      expectLater(
        store.stream.map((s) => s.count),
        emitsInOrder([1, 2, 3]),
      );

      await store.increment();
      await store.increment();
      await store.increment();
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/bindx_store_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Documentation

### Code Documentation

Use Dart doc comments (`///`) for public APIs:

```dart
/// A reactive state container that extends [ChangeNotifier].
///
/// The [BindXStore] provides automatic change notification,
/// stream support, and built-in caching capabilities.
///
/// Type parameter [T] represents the state type.
///
/// Example:
/// ```dart
/// class CounterStore extends BindXStore<int> {
///   CounterStore() : super(0);
///
///   void increment() {
///     update((current) => current + 1);
///   }
/// }
/// ```
class BindXStore<T> extends ChangeNotifier {
  // ...
}
```

### README Updates

When adding features, update:
- README.md with usage examples
- CHANGELOG.md with version notes
- API documentation as needed

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): subject

body

footer
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(cache): add disk caching strategy

Implemented new disk-based caching strategy for persistent storage.
This allows cache to survive app restarts.

Closes #123
```

```
fix(store): resolve state update race condition

Fixed race condition in concurrent state updates by adding proper
mutex locking in the update method.

Fixes #456
```

## Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag v0.0.2`
4. Push tag: `git push origin v0.0.2`
5. Publish to pub.dev: `flutter pub publish`

## Getting Help

- 📧 Email: dev@bindx.dev
- 💬 Discord: [Join our server](https://discord.gg/bindx)
- 📖 Docs: [bindx.dev/docs](https://bindx.dev/docs)

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Special thanks in changelog

Thank you for contributing! 🎉
