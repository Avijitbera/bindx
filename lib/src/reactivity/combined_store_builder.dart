import 'dart:async';

import 'package:bindx/src/core/bindx_store.dart';
import 'package:bindx/src/reactivity/combined_store_stream.dart';
import 'package:flutter/material.dart';

class CombinedStoreBuilder extends StatefulWidget {
  final List<BindXStore> stores;
  final Widget Function(
    BuildContext context,
    List<dynamic> values,
    List<BindXStore> stores,
  )
  builder;
  final Widget? loading;
  final Widget Function(Object error)? errorBuilder;
  const CombinedStoreBuilder({
    super.key,
    required this.stores,
    required this.builder,
    this.loading,
    this.errorBuilder,
  });

  @override
  State<CombinedStoreBuilder> createState() => _CombinedStoreBuilderState();
}

class _CombinedStoreBuilderState extends State<CombinedStoreBuilder> {
  late List<dynamic> _states;
  late StreamSubscription _subscription;
  Object? _error;
  bool _hasData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _states = widget.stores.map((s) => s.state).toList();
    _subscribe();
  }

  void _subscribe() {
    final combinedStream = CombinedStoreStream(widget.stores);

    _subscription = combinedStream.listen(
      (states) {
        if (mounted) {
          _states = states;
          _hasData = true;
          _error = null;
          setState(() {});
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(_error!);
    }
    if (!_hasData && widget.loading != null) {
      return widget.loading!;
    }
    return widget.builder(context, _states, widget.stores);
  }
}
