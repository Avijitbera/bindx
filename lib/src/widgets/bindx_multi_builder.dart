import 'package:bindx/src/core/bindx_registry.dart';
import 'package:bindx/src/core/bindx_store.dart';
import 'package:bindx/src/widgets/bindx_provider.dart';
import 'package:flutter/material.dart';

class BindXMultiBuilder extends StatefulWidget {
  final List<Type> storeTypes;
  final Widget Function(BuildContext context, Map<Type, BindXStore>) builder;
  const BindXMultiBuilder({
    Key? key,
    required this.storeTypes,
    required this.builder,
  }) : super(key: key);

  @override
  State<BindXMultiBuilder> createState() => _BindXMultiBuilderState();
}

class _BindXMultiBuilderState extends State<BindXMultiBuilder> {
  final Map<Type, BindXStore> _stores = {};
  final Map<Type, VoidCallback> _listeners = {};

  void _initializeStores() {
    for (final type in widget.storeTypes) {
      _setupStoreListener(type);
    }
  }

  void _setupStoreListener(Type type) {
    BindXStore? store;
    try {
      store = BindXProvider.of<BindXStore>(context, listen: false);
      if (store.runtimeType != type) {
        store = null;
      }
    } catch (e) {
      if (bindxRegistry.existsByType(type)) {
        store = bindxRegistry.getByType(type);
      }
    }

    if (store != null) {
      _stores[type] = store;

      final listener = () {
        if (mounted) {
          setState(() {});
        }
      };

      _listeners[type] = listener;
      store.addListener(listener);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cleanupListeners();
    _initializeStores();
  }

  void _cleanupListeners() {
    for (final type in _listeners.keys) {
      final store = _stores[type];
      if (store != null) {
        store.removeListener(_listeners[type]!);
      }
    }
    _listeners.clear();
    _stores.clear();
  }

  @override
  void dispose() {
    _cleanupListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _stores);
  }
}
