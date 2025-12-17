import 'dart:async';

import 'package:bindx/src/core/bindx_store.dart';

class CombinedStoreStream extends Stream<List<dynamic>> {
  final List<Stream> _streams;
  final List<dynamic> _latestValues;

  CombinedStoreStream(List<BindXStore> stores)
    : _streams = stores.map((s) => s.stream).toList(),
      _latestValues = List.filled(stores.length, null);

  @override
  StreamSubscription<List<dynamic>> listen(
    void Function(List<dynamic> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<List<dynamic>>(sync: true);
    final List<StreamSubscription> subscriptions = [];
    int completedCount = 0;

    void checkDone() {
      completedCount++;
      if (completedCount == _streams.length) {
        controller.close();
      }
    }

    controller.onListen = () {
      if (_streams.isEmpty) {
        controller.close();
        return;
      }
      for (var i = 0; i < _streams.length; i++) {
        final subscription = _streams[i].listen(
          (data) {
            _latestValues[i] = data;
            controller.add(List.from(_latestValues));
          },
          onError: controller.addError,
          onDone: checkDone,
        );
        subscriptions.add(subscription);
      }
    };

    controller.onPause = () {
      for (final sub in subscriptions) {
        sub.pause();
      }
    };

    controller.onResume = () {
      for (final sub in subscriptions) {
        sub.resume();
      }
    };

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
