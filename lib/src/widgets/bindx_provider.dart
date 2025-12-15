import 'package:bindx/src/core/bindx_registry.dart';
import 'package:bindx/src/core/bindx_store.dart';
import 'package:flutter/material.dart';

class BindXProvider<T extends BindXStore> extends StatefulWidget {
  final T store;
  final Widget child;
  final bool register;
  final String? name;

  const BindXProvider({
    Key? key,
    required this.store,
    required this.child,
    this.register = true,
    this.name,
  }) : super(key: key);

  static T of<T extends BindXStore>(
    BuildContext context, {
    String? name,
    bool listen = true,
  }) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<BindXProviderScope<T>>()
        : context.getInheritedWidgetOfExactType<BindXProviderScope<T>>();

    if (provider != null) {
      return provider.store;
    }
    if (bindxRegistry.exists<T>(name: name)) {
      return bindxRegistry.get<T>(name: name);
    }
    throw FlutterError('''
BindXProvider<$T> not found.
Make sure you have:
1. Added BindXProvider<$T> to your widget tree.
2. Or registered it with bindxRegistry.register<T>(store: ...)

Expected name: $name

''');
  }

  @override
  State<StatefulWidget> createState() {
    return _BindXProviderState<T>();
  }
}

class _BindXProviderState<T extends BindXStore>
    extends State<BindXProvider<T>> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.register) {
      bindxRegistry.register<T>(
        store: widget.store,
        name: widget.name,
        override: true,
      );
    }
  }

  @override
  void dispose() {
    if (widget.register) {
      bindxRegistry.remove<T>(name: widget.name);
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BindXProviderScope<T>(store: widget.store, child: widget.child);
  }
}

class BindXProviderScope<T extends BindXStore> extends InheritedWidget {
  final T store;

  const BindXProviderScope({
    Key? key,
    required this.store,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant BindXProviderScope oldWidget) {
    return store != oldWidget.store;
  }
}
