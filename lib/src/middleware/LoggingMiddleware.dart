import 'dart:async';

import 'middleware.dart';

class LoggingMiddleware<T> implements Middleware<T> {
  final bool logBefore;
  final bool logAfter;
  final void Function(String message, dynamic data)? logger;

  LoggingMiddleware({this.logBefore = true, this.logAfter = true, this.logger});

  @override
  Future<T> beforeUpdate(
    T currentState,
    T Function(T) updater,
    String action,
  ) async {
    if (logBefore) {
      _log('BEFORE $action', {
        'currentState': currentState,
        'action': action,
        'timestamp': DateTime.now(),
      });
    }
    return currentState;
  }

  @override
  Future<T> afterUpdate(T newState, T oldState, String action) async {
    if (logAfter) {
      _log('AFTER $action', {
        'oldState': oldState,
        'newState': newState,
        'action': action,
        'timestamp': DateTime.now(),
        'changed': newState != oldState,
      });
    }
    return newState;
  }

  void _log(String message, Map<String, dynamic> data) {
    if (logger != null) {
      logger!(message, data);
    } else {
      print('[$message] $data');
    }
  }
}
