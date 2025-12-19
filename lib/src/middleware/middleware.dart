abstract class Middleware<T> {
  Future<T> beforeUpdate(T currentState, T Function(T) updater, String action);

  Future<T> afterUpdate(T newState, T oldState, String action);
}
