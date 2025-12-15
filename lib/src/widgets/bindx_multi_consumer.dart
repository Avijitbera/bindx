import 'package:bindx/src/core/bindx_registry.dart';

import 'package:bindx/src/core/bindx_store.dart';
import 'package:bindx/src/widgets/bindx_provider.dart';
import 'package:flutter/material.dart';

class BindXMultiConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, Map<Type, BindXStore>) builder;

  final List<Type> storeTypes;

  const BindXMultiConsumer({
    Key? key,
    required this.builder,
    required this.storeTypes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stores = <Type, BindXStore>{};
    for (final type in storeTypes) {
      try {
        final store = _getStoreByType(context, type);
        if (store != null) {
          stores[type] = store;
        }
      } catch (_) {}
    }
    return builder(context, stores);
  }

  BindXStore? _getStoreByType(BuildContext context, Type type) {
    try {
      final provider = context
          .dependOnInheritedWidgetOfExactType<BindXProviderScope<dynamic>>();
      if (provider != null && provider.store.runtimeType == type) {
        return provider.store;
      }
    } catch (e) {}
    if (bindxRegistry.existsByType(type)) {
      return bindxRegistry.getByType(type) as BindXStore?;
    }
    return null;
  }
}
