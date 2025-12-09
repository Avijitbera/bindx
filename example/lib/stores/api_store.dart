import 'package:bindx/bindx.dart';

part 'api_store.bindx.dart';

/// API store demonstrating concurrent operations and retry logic
class ApiStore with StategenMixin {
  int _requestCount = 0;
  String _lastResponse = '';
  bool _isLoading = false;

  int get requestCount => _requestCount;
  String get lastResponse => _lastResponse;
  bool get isLoading => _isLoading;

  // Cached API response with disk persistence
  @Cache(
    key: 'apiData',
    duration: Duration(minutes: 5),
    persist: true,
    strategy: CacheStrategy.diskFirst,
    tag: 'api_cache',
  )
  Future<String> get cachedApiData async {
    await Future.delayed(Duration(seconds: 1));
    return 'Cached API Data: ${DateTime.now()}';
  }

  // Concurrent API call with debouncing
  @Concurrent(
    maxConcurrent: 3,
    queueKey: 'api_calls',
    debounce: true,
    debounceDuration: Duration(milliseconds: 500),
    priority: 5,
  )
  Future<String> fetchData(String endpoint) async {
    _isLoading = true;
    await Future.delayed(Duration(seconds: 2));
    _requestCount++;
    _lastResponse = 'Response from $endpoint at ${DateTime.now()}';
    _isLoading = false;
    return _lastResponse;
  }

  // Throttled API call
  @Concurrent(
    maxConcurrent: 1,
    throttle: true,
    throttleDuration: Duration(seconds: 2),
  )
  Future<void> throttledApiCall() async {
    await Future.delayed(Duration(milliseconds: 500));
    _requestCount++;
  }

  // Retry with specific exception handling
  @Retry(maxAttempts: 5, delay: Duration(milliseconds: 500))
  Future<Map<String, dynamic>> fetchWithRetry(String url) async {
    await Future.delayed(Duration(seconds: 1));

    // Simulate random failures
    if (DateTime.now().millisecond % 2 == 0) {
      throw Exception('API Error: Failed to fetch from $url');
    }

    return {
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
      'data': 'Success',
    };
  }

  // Timeout for slow endpoints
  @Timeout(Duration(seconds: 3))
  Future<String> slowEndpoint() async {
    await Future.delayed(Duration(seconds: 2));
    return 'Slow endpoint response';
  }

  // Combined: Concurrent + Retry + Timeout
  @Concurrent(maxConcurrent: 2)
  @Retry(maxAttempts: 3)
  @Timeout(Duration(seconds: 10))
  Future<String> complexApiCall(String endpoint) async {
    await Future.delayed(Duration(seconds: 1));
    return 'Complex API response from $endpoint';
  }
}
