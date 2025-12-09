import 'package:bindx/bindx.dart';

part 'user_store.bindx.dart';

/// User store demonstrating caching, streaming, and validation
class UserStore with StategenMixin {
  String _name;
  String _email;
  int _age;
  String _status;
  int _loginCount;

  UserStore({required String name, required String email, required int age})
    : _name = name,
      _email = email,
      _age = age,
      _status = 'active',
      _loginCount = 0;

  // Basic getters
  String get name => _name;
  String get email => _email;
  int get age => _age;
  String get status => _status;
  int get loginCount => _loginCount;

  // Cached getter - demonstrates caching with 10 minute duration
  @Cache(
    key: 'fullName',
    duration: Duration(minutes: 10),
    strategy: CacheStrategy.memory,
  )
  String get fullName => '$_name (Age: $_age)';

  // Cached getter with persistence
  @Cache(
    key: 'userProfile',
    duration: Duration(hours: 1),
    persist: true,
    strategy: CacheStrategy.memoryFirst,
    tag: 'user_data',
  )
  String get userProfile =>
      'Name: $_name, Email: $_email, Age: $_age, Status: $_status';

  // Streamed property - generates a reactive stream
  @Streamed(broadcast: true, streamKey: 'statusStream')
  String get streamedStatus => _status;

  // Validated email setter
  @Validate([Validator.notEmpty, Validator.email])
  void setEmail(String value) {
    _email = value;
  }

  // Concurrent method with debouncing
  @Concurrent(
    maxConcurrent: 1,
    debounce: true,
    debounceDuration: Duration(milliseconds: 500),
  )
  Future<void> updateProfile(String name, int age) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    _name = name;
    _age = age;
  }

  // Method with retry logic
  @Retry(maxAttempts: 3, delay: Duration(seconds: 1))
  Future<Map<String, dynamic>> fetchUserData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API call

    // Simulate occasional failures
    if (DateTime.now().millisecond % 3 == 0) {
      throw Exception('Network error');
    }

    return {'name': _name, 'email': _email, 'age': _age, 'status': _status};
  }

  // Method with timeout
  @Timeout(Duration(seconds: 5))
  Future<void> longRunningTask() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate long task
    _loginCount++;
  }

  // Mutex-protected critical section
  @Mutex(lockKey: 'userUpdate', timeout: Duration(seconds: 10))
  Future<void> criticalUpdate(String status) async {
    await Future.delayed(Duration(milliseconds: 500));
    _status = status;
  }

  // Concurrent method with throttling
  @Concurrent(
    maxConcurrent: 3,
    throttle: true,
    throttleDuration: Duration(seconds: 1),
    priority: 10,
  )
  Future<void> incrementLoginCount() async {
    await Future.delayed(Duration(milliseconds: 100));
    _loginCount++;
  }

  // Regular method for comparison
  void updateStatus(String newStatus) {
    _status = newStatus;
  }

  void updateName(String newName) {
    _name = newName;
  }
}
