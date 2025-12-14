import 'package:bindx/src/core/bindx_store.dart';
import 'package:bindx/src/widgets/bindx_provider.dart';
import 'package:flutter/material.dart';

class MultiBindXProvider extends StatelessWidget {
  final List<BindXProvider> providers;
  final Widget child;

  const MultiBindXProvider({
    Key? key,
    required this.providers,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    for (final provider in providers.reversed) {
      current = BindXProvider(
        child: current,
        key: provider.key,
        store: provider.store,
      );
    }
    return current;
  }
}
