import 'package:flutter/material.dart';

class BindXConsumer extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final List<Type> storeTypes;

  const BindXConsumer({
    Key? key,
    required this.builder,
    this.storeTypes = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
